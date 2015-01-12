# coding: utf-8
# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

$LOAD_PATH << "."
require 'flash-var'
require 'exif-var'
require 'ifd-var'
require 'time'

$DDEBUG = false

# Overload String class to add helpful stuff
class String
  def to_num(endianess) # endianess convertion
    case endianess
    when :big
      self.unpack("n*").join.hex
    when :little
      self.unpack("v*").first
    end
  end
  def convert(endianess) # endianess convertion
    case endianess
    when :big
      self.unpack("N*").join.hex
    when :little
      self.unpack("V*").first
    end
  end
end

# Overload Fixnum class to add helpful stuff
class Fixnum
  def to_hexa; self.to_s(16) end
end

# REXIF module
module REXIF
  class IMG
    def initialize(filename)
      init_var(filename)
      dputs "Analysing: %s" % filename
      File.open(filename, "rb") do |io|
        @io = io
        analyze()
        handle_embedded()
        set_functions()
      end
    end


    # self explained
    def has_thumbnail?
      @thumbnail
    end

    def has_small_preview?
      @small_preview
    end

    def has_lossless_preview?
      @lossless_preview
    end

    def has_rgb_uncompress_preview?
      @rgb_uncompress_preview
    end

    def extract_all(path="./")
      ret = []
      ret << extract_thumbnail(path) if defined? extract_thumbnail
      ret << extract_small_preview(path) if defined? extract_small_preview
      ret << extract_lossless_preview(path) if defined? extract_lossless_preview
      ret << extract_rgb_uncompress_preview(path) if defined? extract_rgb_uncompress_preview
      ret
    end

  private

    def puts(str)
      STDOUT.write("%s\n" % str)
    end
    def ddputs(str)
      puts "[D] %s" % str if $DDEBUG
    end
    def dputs(str)
      puts "[+] %s" % str
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
      @TIFF_header_offset ||= nil
      @io = nil
      @thumbnail = false
      @small_preview = false
      @lossless_preview = false
      @rgb_uncompress_preview = false
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
      case endian.join
      when BIG_ENDIAN_.map{|c| c.chr}.join #MM
        @endianess = :big
      when LITTLE_ENDIAN_.map{|c| c.chr}.join #II
        @endianess = :little
      else
        eputs "Unrecognized endianess. Exiting"
        exit(2)
      end
      # move back to the previous position in case we read more bytes than
      # expected
      @io.seek( -tmp.length, IO::SEEK_CUR) if tmp.length != 0
      # we compute the tiff_header position (-4) (endianess x 2 + identifier)
      # in order to seek from here to the IFD0 offset
      @TIFF_header_offset = @io.pos - 4
      # we get the IFD0_ENTRIES offset by reading the next 4 bytes taking care
      # to the endianess
      tmp = ""
      4.times{tmp << @io.readchar}
      @first_ifd_offset = tmp.to_num(@endianess)
    end

    # Get the count of IFD entries (Read and convert 2 bytes)
    def expected_entries?
      expected_size = ""
      2.times{expected_size << @io.readchar}
      expected_entries = expected_size.to_num(@endianess)
      dputs "Expected %d IFD entries" % expected_entries
      return expected_entries
    end

    def seek_IFD0_entries
      dputs "IFD0_entries offset: %s" % @first_ifd_offset.to_s(16)
      # and seek to the target offset given by the 4 bytes after tiff header
      @io.seek(@TIFF_header_offset + @first_ifd_offset, IO::SEEK_SET)
    end

    # Analyze the file:
    # - detect endianess
    # - get the offset data
    # - get the value data
    # - get raw image data if thumbnail is detected
    def analyze
      if not @endianess
        detect_endianess()
        dputs "Endianess: " + @endianess.to_s
        seek_IFD0_entries()
      end

      next_IFD, @@DATA[0] = get_offset(expected_entries?, IFD)
      next_IFD = next_IFD.convert(@endianess)
      i = 1
      # Each IFD (IFD0 to IFD3) has potential pointer to the next one
      # last one is 0x0000
      while next_IFD != 0
        ddputs " -- Jumping to the next hop (%04s) --" % next_IFD.to_s(16)
        @io.seek(@TIFF_header_offset + next_IFD , IO::SEEK_SET)
        next_IFD, @@DATA[i] = get_offset(expected_entries?, IFD)
        next_IFD = next_IFD.convert(@endianess)
        i += 1
      end
      # Usually the ExifOffset is present in the first part
      if @@DATA[0].has_key? "ExifOffset"
        # if yes, seek to the given offset
        @io.seek(@TIFF_header_offset + @@DATA[0]["ExifOffset"][:value], IO::SEEK_SET)
        next_IFD, @@DATA[i] = get_offset(expected_entries?, EXIF)
      end

      @@DATA.each do |c|
        get_values(c)
      end
    end

    # Get and convert the entries offset
    # Depends on the previously detected endianess
    def get_offset(expected_content, entries)
      data = Hash.new
      while expected_content > 0
        expected_content -= 1
        id, type, size, _data = readblock()
        key = entries.find{|k, v| v[:id] == id}
        if not key
          ddputs "Don't know this id '%s'. Next" % id.to_s(16)
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
          when ASCII[:id]
            ret = ""
            _data.each_byte{|c| ret << c.chr }
            _data = ret.to_i
          end
          ddputs "%s: Direct value detected" % _data
          data[key][:value] = (entries[key].has_key?(:exec)) ? entries[key][:exec].call(_data) : _data
        else
        # _data is a pointer to the value
          ddputs "Get Pointer: %s" % _data.unpack("H*").first.to_s
          _data = _data.convert(@endianess)
          data[key][:pointer] = _data
        end
        ddputs "%s : (type: %s, size: %s) 0x%s" % [key, type, size, _data.to_hexa]
      end
      return @io.readchar<<@io.readchar<<@io.readchar<<@io.readchar, data
    end

    # Read and convert info at the offset (see :pointer)
    # Depends on the previously detected endianess
    def get_values(entries)
      entries.each do |k, v|
        if not entries[k][:pointer]
          next
        end
        if @io.pos != entries[k][:pointer]
          @io.seek(@TIFF_header_offset + entries[k][:pointer] - @io.pos, IO::SEEK_CUR)
        end
        tmp = ""
        ddputs "Position: %d" % @io.pos
        case entries[k][:type]
        when ASCII[:id]
          entries[k][:size].times{tmp << @io.readchar}
          entries[k][:value] = tmp.strip
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
            puts "-> #{k} <-"
            puts "num: %s" % num.unpack("H*").first.scan(/../).map{|c| "\\x"+c}.join(" ")
            puts "denum: %s" % denum.unpack("H*").first.scan(/../).map{|c| "\\x"+c}.join(" ")
            puts "num %d" % num.convert(@endianess)
            puts "denum %d" % denum.convert(@endianess)
          end
          case entries[k][:size]
          when 1
            r_f = Rational(num.convert(@endianess),denum.convert(@endianess)).to_f
            r = r_f.to_i
            entries[k][:value] = "%0.2f (%s)" % [r_f, r]
          else
            lensSpec = num.unpack("L*")
            if lensSpec[0] == lensSpec[1]
              entries[k][:value] = "%dmm F%d-%d" % lensSpec
            else
              entries[k][:value] = "%d-%dmm F%d-%d" % lensSpec
            end
          end
        else
          eputs "%s Unknown type" % entries[k][:type]
          eputs entries[k][:type].to_s(16)
          eputs entries[k].inspect
        end
      end
    end

    # Detect if thumbnail has been found and define function to extract
    # thumbnail if available
    def handle_embedded
      data = [["ThumbnailOffset","ThumbnailLength"],["PreviewImageStart","PreviewImageLength"]]
      data.map{|offset, length|
        @@DATA.each_with_index do |c, index|
          if c.has_key?(offset)
            # ThumbnailOffset -> thumbnail
            # PreviewImageStart -> preview
            ext = ".jpeg"
            case index
            when 0 # IFD0
              kind = "small_preview"
            when 1 # IFD1
              kind = "thumbnail"
            when 2 # IFD2
              kind = "rgb_uncompress_preview"
              ext = ".raw"
            when 3 # IFD3
              kind = "lossless_preview"
              ext = ".raw"
            end
            instance_variable_set("@#{kind}", true)
            # dynamically create method to extract preview/thumbnail
            self.class.instance_eval {
              define_method ("extract_%s" % kind).to_sym do |path=nil|
                path ||= File.dirname(@filename)
                extract_name = File.basename(@filename)
                extract_name.gsub!(File.extname(extract_name), ext)
                extract_name = File.join(path, "#{kind}_%s_#{extract_name}" % Time.now.strftime("%Y-%m-%d_%H%M%S"))
                _offset = c[offset][:value]
                _length = c[length][:value]
                File.open(@filename, "rb") do |io|
                  io.seek(@TIFF_header_offset + _offset, IO::SEEK_SET)
                  extracted_f = File.open(extract_name, "wb")
                  _length.times {
                    extracted_f << io.readchar
                  }
                end
                extract_name
              end
            }
          end
        end
      }
    end


    # Read block (12 bytes)
    # return id, type, size, data
    def readblock()
      size = 12
      block = ""
      size.times{block << @io.readchar}
      if $DDEBUG
        puts "Current block:"
        block.unpack("H*").first.scan(/../).map{|c| print "\\x"+c}
        puts ""
      end

      # Exif2.2:
      # Each of the 12-byte field Interoperability consists of the following
      # four elements respectively:
      # Bytes 0-1 Tag
      # Bytes 2-3 Type
      # Bytes 4-7 Count
      # Bytes 8-11 Value Offset
      return block[0..1].to_num(@endianess),
        block[2..3].to_num(@endianess),
        block[4..7].to_num(@endianess),
        block[8..11]
    end

    # Generate method name for each info available in the picture
    def set_functions
      self.class.instance_eval do
        methods = []
        @@DATA.each_with_index do |c, index|
          txt = "IFD"
          if index == 1
            txt = "EXIF"
          elsif index > 1
            index -= 1
          end
          c.each do |k, v|
            method = txt + index.to_s + k
            methods << method
            define_method method.to_sym do
              v[:value]
            end
          end
        end
        define_method 'help' do
          methods.join(', ')
        end
      end
    end

  end
end
