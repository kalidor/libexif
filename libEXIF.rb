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
        if not @endianess
          detect_endianess()
          vputs "Endianess: " + @endianess.to_s
        end
        seek_IFD0_entries()
        get_all_offsets()
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
      # we get the IFD0_ENTRIES offset by reading the next 4 bytes taking care
      # to the endianess
      @first_ifd_offset = @io.read(4).convert(@packspec, 0).first
    end

    # Get the count of IFD entries (Read and convert 2 bytes)
    def expected_entries?
      expected_size = @io.read(2)
      expected_entries = expected_size.convert(@packspec, 3).first
      vputs "Expected %d IFD entries" % expected_entries
      return expected_entries
    end

    def seek_IFD0_entries
      vputs "IFD0_entries offset: %s" % @first_ifd_offset.to_s(16)
      # and seek to the target offset given by the 4 bytes after tiff header
      @io.seek(@TIFF_header_offset + @first_ifd_offset, IO::SEEK_SET)
    end

    def get_all_offsets
      next_IFD, @@DATA["IFD%d" % 0] = get_offset(expected_entries?, IFD)
      next_IFD = next_IFD.convert(@packspec, 5).first
      i = 1
      # Each IFD (IFD0 to IFD3) has potential pointer to the next one
      # last one is 0x0000
      while next_IFD != 0
        ddputs " -- Jumping to the next hop (%04s) --" % next_IFD.to_s(16)
        @io.seek(@TIFF_header_offset + next_IFD , IO::SEEK_SET)
        next_IFD, @@DATA["IFD%d" % i] = get_offset(expected_entries?, IFD)
        next_IFD = next_IFD.convert(@packspec, 5).first
        i += 1
      end
      # Usually the ExifOffset is present in the first part
      if @@DATA["IFD0"].has_key? "ExifOffset"
        @io.seek(@TIFF_header_offset + @@DATA["IFD0"]["ExifOffset"][:value], IO::SEEK_SET)
        next_IFD, @@DATA["EXIF"] = get_offset(expected_entries?, EXIF)
        i += 1
      end
      if @@DATA["IFD0"].has_key? "GPSInfo"
        @io.seek(@TIFF_header_offset + @@DATA["IFD0"]["GPSInfo"][:value], IO::SEEK_SET)
        next_IFD, @@DATA["GPS"] = get_offset(expected_entries?, GPS)
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
        if [0x01, 0x02, 0x03, 0x04, 0x07].include?(type) and size <= 0x04
          case type
          when BYTE[:id]
            _data = _data.convert(@packspec, type).delete_if{|v| v==0}.join(".")
          when UNDEF[:id] # fuck exif version type...
            _data = _data.to_i
          when INT16U[:id], INT32U[:id]
            _data = _data.convert(@packspec, type).first.to_i
          when ASCII[:id]
            _data.each_byte{|c| c.chr }
          end
          ddputs "%s: Direct value detected" % _data
          _data.strip! if _data.class == String
          data[key][:value] = (entries[key].has_key?(:exec)) ? entries[key][:exec].call(_data) : _data
        else
        # _data is a pointer to the value
          ddputs "Get Pointer: %s" % _data.unpack("H*").first.to_s
          _data = _data.convert(@packspec, 5).first
          data[key][:pointer] = _data
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
            if s[0]/s[1] == 0
              d = d.inject(:/).to_i
              m = Rational(m[0], m[1]).to_f
              s_sup = m % 1
              s = (Rational(s[0], s[1]).to_f + s_sup) * 60
              # See http://en.wikipedia.org/wiki/Geographic_coordinate_conversion
              # and http://en.wikipedia.org/wiki/Geotagging#GPS_formats
              geo = d + Rational((Rational(s.to_f,3600).to_f + m), 60).to_f
              entries[k][:value] = "%d deg %d' %0.2f\" %%s (%%s%0.14f)" % [d, m.to_i, s, geo]
              if entries.include?(k+"Ref")
                ref = entries[k+"Ref"][:value]
                entries[k][:value] = entries[k][:value] % [ref, ["S","W"].include?(ref) ? "-" : "+"]
              end
            else
              tmp = []
              [d, m, s].map{|x|
                tmp << Rational(x[0], x[1]).to_f
              }
              entries[k][:value] = tmp.join(":")
            end
          when 4
            foc = []
            depth = []
            [foc, depth].map{|t|
              @io.read(entries[k][:size] * 4).unpack("L*").each_slice(2) do |n, d|
                d == 0 ? t << 0 : t << n/d
              end
            }
            if foc[0] == foc[1]
              entries[k][:value] = "%dmm F%d-%d" % [[foc[0]].concat(depth)]
            else
              entries[k][:value] = "%d-%dmm F%d-%d" % foc.concat(depth)
            end
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
