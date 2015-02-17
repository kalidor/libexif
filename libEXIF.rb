# This file is part of libEXIF, a library to access stored data in picture.
# coding: utf-8
# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

$LOAD_PATH << "lib"
require 'time'
%w[helper flash-var exif-var ifd-var gps-var].map{|f|
  require f
}

# REXIF module
module REXIF
  class IMG
    include IFD
    include EXIF
    include GPS
    attr_reader :gps, :ifd0, :ifd1, :ifd2, :ifd3, :exif
    attr_reader :verbose, :filename, :endianess
    def initialize(filename, verbose=false)
      [true, false, nil].include?(verbose) ? @verbose = verbose : @verbose = false
      init_var(filename)
      init_methods()
    end

    # Analyze the file:
    # - detect endianess
    # - get the offset data
    # - get the value data
    # - get raw image data if thumbnail is detected
    def analyze
      vputs "Analysing: %s" % filename
      File.open(@filename, "rb") do |io|
        @io = io
        offset = detect_endianess()
        vputs "Endianess: " + @endianess.to_s
        get_all_offsets(offset)
        @@DATA.each do |k, v|
          get_values(v)
        end
        handle_embedded()
        gen_instance_variables()
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

    def infos
      %w[ifd0? ifd1?  ifd2?  ifd3? exif? gps?].map{|c| c.to_sym}
    end
  private

    def method_missing(m)
      raise NoMethodError, "Unknown method '%s'.\
\nSee 'infos' instance variable to see what is available." % m.to_s
    end

    def init_var(filename)
      @@DATA = Hash.new
      @filename = filename
      @endianess ||= nil
      @TIFF_header_offset ||= nil
      @io = nil
      @thumbnail = false
      @small_preview = false
      @lossless_preview = false
      @rgb_uncompress_preview = false
    end

    def init_methods
      %w[ifd0 ifd1 ifd2 ifd3 exif gps].map{|f|
        self.class.instance_eval {
          define_method(("%s?" % f.to_s).to_sym) do
            false
          end
        }
      }
    end

    def detect_endianess
      index = nil
      block = 8
      until @io.pos > 100 or @endianess
        c = @io.read(block)
        if index = c.index(LITTLE_ENDIAN)
          @endianess = :little
        elsif index = c.index(BIG_ENDIAN)
          @endianess = :big
        end
      end
      if @endianess
        # move back to the previous position in case we read more bytes than
        # expected
        @io.seek(-block+index+4, IO::SEEK_CUR)
      else
        raise "Cannot detect endianess"
      end
      @packspec = PackSpec.new(@endianess)
      # we compute the tiff_header position (-4) (endianess x 2 + identifier)
      # in order to seek from here to the IFD0 offset
      @TIFF_header_offset = @io.pos - 4
      # we return the IFD0_ENTRIES offset by reading the next 4 bytes taking care
      # to the endianess
      @io.read(4).convert(@packspec, 0).first
    end

    # Get the count of IFD entries (Read and convert 2 bytes)
    def expected_entries?
      expected_size = @io.read(2)
      expected_entries = expected_size.convert(@packspec, 3).first
      vputs "Expected %d IFD entries" % expected_entries
      return expected_entries
    end

    def get_all_offsets(offset)
      vputs "IFD0_entries offset: %s" % offset.to_s(16)
      i = ifd_analyze(offset, @@DATA)
      # Usually the ExifOffset is present in the first part
      exif_analyze(offset, @@DATA) if @@DATA["IFD0"].has_key? "ExifOffset"
      gps_analyze(offset, @@DATA) if @@DATA["IFD0"].has_key? "GPSInfo"
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
        # if size > 4, it's a pointer to the data
        if size <= 0x04
          case
          when type == BYTE[:id] #1
            _data = _data.convert(@packspec, type).delete_if{|v| v==0}.join(".")
            set_value(entries[key], key, data, _data)
          when type == ASCII[:id] #2
            _data.each_byte{|c| c.chr }
            set_value(entries[key], key, data, _data)
          when [INT16U[:id], INT32U[:id]].include?(type) && size > 0x01 # 3 and 4
            set_ptr(entries[key], key, data, _data)
          when [INT16U[:id], INT32U[:id]].include?(type) # 3 and 4
            _data = _data.convert(@packspec, type).first.to_i
            set_value(entries[key], key, data, _data)
          when type == UNDEF[:id] # fuck exif version type... # 7
            _data = _data.to_i
            set_value(entries[key], key, data, _data)
          else
            # If type was not found, this means it's a pointer
            # Some pointer has size of 1...
            set_ptr(entries[key], key, data, _data)
          end
        else
          # _data is a pointer to the value
          set_ptr(entries[key], key, data, _data)
        end
        ddputs "%s : (type: %s, size: %s) %s" % [key, type, size, _data]
      end
      return @io.read(4), data
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
        ddputs "#{k}"
        ddputs "\tPosition: %d" % @io.pos
        ddputs "\tType : %d" % entries[k][:type]
        case entries[k][:type]
        when ASCII[:id]
          entries[k][:value] = @io.read(entries[k][:size]).strip
        when INT16U[:id]
          entries[k][:value] = @io.read(entries[k][:size] * INT16U[:unit]).convert(@packspec, 3).join(" ")
          #entries[k][:value] = @io.read(entries[k][:size]).convert(@packspec, 3).join(" ")
        when RATIONAL64U[:id], RATIONAL64S[:id]
          case entries[k][:size]
          when 1
            num = @io.read(entries[k][:size] * 4).convert(@packspec, entries[k][:type]).first
            denum = @io.read(entries[k][:size] * 4).convert(@packspec, entries[k][:type]).first
            r_f = Rational(num,denum).to_f
            r = r_f.to_i
            entries[k][:value] = "%0.2f (%d)" % [r_f, r]
          when 3
            d = @io.read(8).convert(@packspec, entries[k][:type])
            m = @io.read(8).convert(@packspec, entries[k][:type])
            s = @io.read(8).convert(@packspec, entries[k][:type])
            if entries.include?(k + "Ref")
              entries[k][:value] = entries[k][:exec].call(d, m, s, entries[k+"Ref"][:value])
            else
              entries[k][:value] = entries[k][:exec].call(d, m, s)
            end
          when 4
            foc = @io.read(entries[k][:size] * 4)
            depth = @io.read(entries[k][:size] * 4)
            entries[k][:value] = entries[k][:exec].call(foc, depth)
          end
        #else
        #  eputs "%s Unknown type" % entries[k][:type]
        #  eputs "%s Unknown type" % entries[k][:type].class
        #  eputs "0x%04x" % entries[k][:type].to_s(16)
        #  eputs entries[k].inspect.to_s
        end
      end
    end

    # Detect if thumbnail has been found and define function to extract
    # thumbnail if available
    def handle_embedded
      data = [["ThumbnailOffset","ThumbnailLength"],["PreviewImageStart","PreviewImageLength"]]
      data.map{|offset, length|
        @@DATA.map do |k,v|
          if v.has_key?(offset)
            # ThumbnailOffset -> thumbnail
            # PreviewImageStart -> preview
            ext = ".jpeg"
            case k
            when "IFD0"
              kind = "small_preview"
            when "IFD1"
              kind = "thumbnail"
            when "IFD2"
              kind = "rgb_uncompress_preview"
              ext = ".raw"
            when "IFD3"
              kind = "lossless_preview"
              ext = ".raw"
            end
            instance_variable_set("@#{kind}", true)
            # dynamically create methods to extract preview/thumbnail
            self.class.instance_eval {
              define_method(("extract_%s" % kind).to_sym) do |path=nil|
                path ||= File.dirname(@filename)
                extract_name = File.basename(@filename)
                extract_name.gsub!(File.extname(extract_name), ext)
                extract_name = File.join(path, "#{kind}_%s_#{extract_name}" % Time.now.strftime("%Y-%m-%d_%H%M%S"))
                _offset = v[offset][:value]
                _length = v[length][:value]
                File.open(@filename, "rb") do |io|
                  io.seek(@TIFF_header_offset + _offset, IO::SEEK_SET)
                  extracted_f = File.open(extract_name, "wb")
                  extracted_f << io.read(_length)
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
      block = @io.read(12)
      puts_debug "current_block", block

      # Exif2.2:
      # Each of the 12-byte field Interoperability consists of the following
      # four elements respectively:
      # Bytes 0-1 Tag
      # Bytes 2-3 Type
      # Bytes 4-7 Count
      # Bytes 8-11 Value Offset
      return block[0..1].convert(@packspec, 3).first,
        block[2..3].convert(@packspec, 3).first,
        block[4..7].convert(@packspec, 3).first,
        block[8..11]
    end

    # Generate instance variables name for each kind of info available in the picture
    def gen_instance_variables
      @@DATA.keys.map do |key|
        instance_variable_set("@#{key.downcase}", Object.const_get(key.capitalize).new(@@DATA[key]))
        self.class.instance_eval {
          define_method(("%s?" % key.downcase).to_sym) do
            true
          end
        }
      end
    end
  end
end
