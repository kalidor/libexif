# coding: utf-8
# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

$LOAD_PATH << "."
require 'flash-var'
require 'exif-var'
require 'thumb-var'
require 'ifd-var'
require 'time'

$DEBUG = false
$DDEBUG = false

# Overload String class to add helpful stuff
class String
  def to_id(endianess = false)
    if endianess # big endian
      self[0..1].unpack('H*').join.hex
    else # little endian
      self[0..1].reverse.unpack('H*').join.hex
    end
  end
  def to_size; self.unpack('H*').join.hex end
  def to_type; to_size end
  def to_num(endianess = :little)
    if endianess == :little
      self.reverse.unpack('H*').join.to_i(16)
    else
      self.unpack('H*').join.to_i(16)
    end
  end
end

# Overload Fixnum class to add helpful stuff
class Fixnum
  def to_hexa; self.to_s(16) end
end

# REXIF module
module REXIF
  class JPG
    @thumbnail = false
    def initialize(filename)
      init_var(filename)
      dputs "Analysing: %s" % filename
      File.open(filename, "rb") do |io|
        @io = io
        analyze()
        init_thumbnail()
        set_functions()
      end
    end

    def puts(str)
      STDOUT.write("%s\n" % str)
    end
    def ddputs(str)
      puts "[D] %s" % str if $DDEBUG
    end
    def dputs(str)
      puts "[+] %s" % str if $DEBUG
    end
    def dprint(str)
      print "[+] %s" % str if $DEBUG
    end
    def eputs(str)
      puts "[-] %s" % str
    end

    def method_missing(m, *args, &block)
      puts "There's no method called #{m} here."
    end

    def init_var(filename)
      @@DATA ||= Array.new
      @filename = filename
      @endianess ||= nil
      @tiff_header_offset ||= nil
    end

    def detect_endianess
      endian = []
      tmp = []
      found = false
      look_for = 0
      begin
        while not found do
          4.times{ tmp << @io.readchar}
          while (l=tmp.shift or not tmp.empty?) do
            _l = l.unpack('C*').first
            if LITTLE_ENDIAN_[look_for] == _l or BIG_ENDIAN_[look_for] == _l
              look_for += 1
              endian << l
              if endian.length == LITTLE_ENDIAN_.length
                dputs "Endianess: "
                endian.each{|c| dprint "0x"+ c.unpack('H*').first+" "}
                dputs ""
                found = true
                break
              end
            else
              look_for = 0
              endian.clear
            end
          end
        end
      rescue
        eputs "Cannot detect endianess. Exiting..."
        exit(2)
      end
      case endian[0..1].join
      when STR_BIG_ENDIAN #MM big-endian
        @endianess = :big
      when STR_LITTLE_ENDIAN #II little-endian
        @endianess = :little
      end
      # move back to the previous position in case we read more bytes than
      # expected
      @io.seek( -tmp.length, IO::SEEK_CUR) if tmp.length != 0
      # we compute the tiff_header position (-4) (endianess x 2 + identifier)
      # in order to seek from here to the IFD0 offset
      @tiff_header_offset = @io.pos - 4
    end

    # Get the count of IFD entries (rRead and convert 2 bytes)
    def expected_entries?
      expected_size = Array.new
      2.times{expected_size << @io.readchar}
      expected_entries = expected_size.join.to_num(@endianess)
      dputs "Expected %d IFD entries" % expected_entries
      return expected_entries
    end

    def seek_IFD0_entries
      # we get the IFD0_ENTRIES offset by reading the next 4 bytes taking care
      # to the endianess
      tmp_offset = ""
      4.times{tmp_offset << @io.readchar}
      tmp_offset = tmp_offset.to_num(@endianess)
      dputs "IFD0_entries offset: %s" % tmp_offset.to_s(16)
      # and seek to the target offset given by the 4 bytes after tiff header
      @io.seek(@tiff_header_offset + tmp_offset, IO::SEEK_SET)
    end

    # Analyze the file:
    # - detect endianess
    # - get the offset data
    # - get the value data
    # - get raw image data if thumbnail is detected
    def analyze
      if not @endianess
        detect_endianess()
        dputs "Endianess detected: " + @endianess.to_s
        seek_IFD0_entries()
      end

      @@TAG = Hash.new
      @@TAG.merge!(EXIF)
      @@TAG.merge!(THUMBNAIL)
      # need to separated IFD from the two others because
      # JpegIFOffset and ThumbnailOffset have the same ID...
      next_IFD, @@DATA[0] = get_offset(expected_entries?, IFD)
      next_IFD = next_IFD.to_num(@endianess)
      i = 1
      while next_IFD != 0
        dputs " -- Jumping to the next hop --"
        @io.seek(@tiff_header_offset + next_IFD , IO::SEEK_SET)
        next_IFD, @@DATA[i] = get_offset(expected_entries?, @@TAG)
        next_IFD = next_IFD.to_num(@endianess)
        i += 1
      end
      # Usually the ExifOffset is present in the first part
      if @@DATA[0].has_key? "ExifOffset"
        # if yes, seek to the given offset
        @io.seek(@tiff_header_offset + @@DATA[0]["ExifOffset"][:value], IO::SEEK_SET)
        dev_null, @@DATA[i] = get_offset(expected_entries?, @@TAG)
      end
      @@DATA.each do |c|
        get_values(c)
      end
    end

    # Define function to extract thumbnail if available
    def init_thumbnail
      # We need to save the content, because the file will be close
      # after the analysis
      @@DATA.each do |c|
        if c.has_key?("ThumbnailOffset")
          @thumbnail = true
          # dynamically create method to extract thumbnail instead keeping thumbnail data in memory
          # path: nil or output directory
          def extract_thumbnail(path=nil)
            path ||= File.dirname(@filename)
            thumbname = File.join(path, "%s_#{File.basename(@filename)}" % Time.now.strftime("%Y-%m-%d_%H%M%S"))
            c = @@DATA.select{|item| item.has_key?("ThumbnailOffset")}
            thumb_offset = c.first["ThumbnailOffset"][:value]
            thumb_length = c.first["ThumbnailLength"][:value]
            File.open(@filename, "rb") do |io|
              io.seek(@tiff_header_offset + thumb_offset, IO::SEEK_SET)
              io_thumb = File.open(thumbname, "wb")
              thumb_length.times {
                io_thumb << io.readchar
              }
            end
            thumbname
          end
        end
      end
    end

    # self explained
    def has_thumbnail?
      @thumbnail
    end


    # Generate method name for each info available in the picture
    # Generate help() methods to display them <- maybe useless...
    # but some picture could miss some exif info
    def set_functions
      self.class.instance_eval do
        methods = []
        @@DATA.each_with_index do |c, index|
          txt = "IFD%d"
          if index == 1
            txt = "EXIF"
          elsif index > 1
            index -= 1
          end
          c.each do |k, v|
            methods << (txt % index) + k
            define_method ((txt % index) + k).to_sym do
              v[:value]
            end
          end
        end
        define_method "help".to_sym do
            methods.join(", ")
        end
      end
    end

  private
    # Get and convert the entries offset
    # Depends on the previously detected endianess
    def get_offset(expected_content, entries)
      data = Hash.new
      while expected_content > 0
        expected_content -= 1
        id, type, size, _data = readblock()
        key = entries.find{|k, v| v[:id] == id}
        if not key
          dputs "Don't know this id '%s'. Next" % id.to_s(16)
          next
        end
        key = key[0]
        data[key] = {:size => size, :pointer => nil, :value => nil, :type => type}
        if [0x02, 0x03, 0x04, 0x07].include?(type) and size <= 0x04
          case type
          when UNDEF[:id] # fuck exif version type...
            _data = _data.to_i
          when INT16U[:id]
            _data = _data.unpack('v*').first.to_i if @endianess == :little
            _data = _data.unpack('n*').first.to_i if @endianess == :big
          when INT32U[:id]
            _data = _data.unpack('V*').first.to_i if @endianess == :little
            _data = _data.unpack('N*').first.to_i if @endianess == :big
          when RATIONAL64U[:id]
            _data = _data.unpack('Q*').first.to_i
          when ASCII[:id]
            ret = ""
            _data.each_byte{|c| ret << c.chr }
            _data = ret.to_i
          else
            # _data is the direct value
            _data = _data.to_num(@endianess)
          end
          dputs "%s: Direct value detected" % _data
          data[key][:value] = (entries[key].has_key?(:exec)) ? entries[key][:exec].call(_data) : _data
        else
        # _data is a pointer to the value
          dputs "Get Pointer: %s" % _data.unpack("H*").first.to_s
          _data = _data.to_num(@endianess)
          data[key][:pointer] = _data
        end
        dputs "%s : (type: %s, size: %s) 0x%s" % [key, type, size, _data.to_hexa]
      end
      return @io.readchar<<@io.readchar<<@io.readchar<<@io.readchar, data
    end

    # Read and convert info at the offset (see :pointer)
    # Depends on the previously detected endianess
    def get_values(entries)
      entries.keys.each{|c| dputs c}
      entries.each do |k, v|
        if not entries[k][:pointer]
          next
        end
        if @io.pos != entries[k][:pointer]
          @io.seek(@tiff_header_offset + entries[k][:pointer] - @io.pos, IO::SEEK_CUR)
        end
        tmp = ""
        ddputs "Position: %d" % @io.pos
        case entries[k][:type]
        when ASCII[:id]
          entries[k][:size].times{tmp << @io.readchar}
          entries[k][:value] = tmp.strip
          dputs tmp
        when INT16U[:id] # direct value, not used here
        when INT32U[:id] # direct value, not used here
        when UNDEF[:id] # EXIF version, direct value
        when RATIONAL64U[:id], RATIONAL64S[:id]
          num = ""
          denum = ""
          entries[k][:size].times{
            4.times{num << @io.readchar}
            4.times{denum << @io.readchar}
          }
          if $DDEBUG
            num.each_char{|c| print c.unpack('H*')}
            puts ""
            denum.each_char{|c| print c.unpack('H*')}
            puts ""
          end
          r_f = Rational(num.to_num(@endianess), denum.to_num(@endianess)).to_f
          r = Rational(num.to_num(@endianess), denum.to_num(@endianess))
          entries[k][:value] = "%0.2f (%s)" % [r_f, r]
        else
          eputs "%s Unknown type" % entries[k][:type]
        end
      end
    end

    # Read block (12 bytes)
    # return id, type, size, data
    def readblock()
      size = 12
      block = ""
      size.times{block << @io.readchar}
      if $DDEBUG
        puts "Current block:"
        block.each_char{|c| print c.unpack('H*')}
        puts ""
      end

      # if big endian, we pass true to to_id function
      return block[0..1].to_id(@endianess == :big ? true : false),
      block[ENDIAN_STRUCTURE[@endianess][:type]].to_type,
      block[ENDIAN_STRUCTURE[@endianess][:size]].to_size,
      block[8..11]
    end
  end
end
