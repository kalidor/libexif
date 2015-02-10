# coding: utf-8
$LOAD_PATH << ".."
require_relative '../libEXIF'
require 'benchmark'

def run(filename, bench=nil)
  io = REXIF::IMG.new(filename, true)
  io.analyze()
  if not bench

    # io.gps
    # io.exif
    # io.ifdX
    if io.ifd0?
      puts "[-] io.ifd0 method available:"
      puts io.ifd0.infos.inspect
    end
    0.upto(3).map{|id|
      if io.instance_variable_defined? "@ifd%d" % id
        io.instance_variable_get("@ifd%d" % id).infos.map{|m|
          puts "io.ifd%d.%s: %s" % [id, m, io.instance_variable_get("@ifd%d" % id).send(m).to_s]
        }
      end
    }
    if io.gps?
      puts "GPS infos: %s" % io.gps.infos.inspect
      io.gps.infos.map{|m|
        puts "io.gps.%s: %s" % [m, io.gps.send(m)]
      }
    end
    if io.exif?
      puts "EXIF infos: %s" % io.exif.infos.inspect
      io.exif.infos.map{|m|
        puts "io.exif.%s: %s" % [m, io.exif.send(m)]
      }
    end

    exit
    # puts io.extract_all()
    # or
    Dir.mkdir("extract") if not File.exist?("extract")
    if io.has_thumbnail?
      puts "[+] extract_thumbnail() available."
      begin
        thumbname = io.extract_thumbnail("extract")
        puts "[+] Extracted : %s" % thumbname
      end
    end
    if io.has_small_preview?
      puts "[+] extract_preview() available."
      begin
        preview = io.extract_small_preview('extract')
        puts "[+] Extracted : %s" % preview
      end
    end

    if io.has_lossless_preview?
      puts "[+] extract_lossless_preview() available."
      begin
        lossless_preview = io.extract_lossless_preview('extract')
        puts "[+] Extracted : %s" % lossless_preview
      end
    end
    if io.has_rgb_uncompress_preview?
      puts "[+] extract_rgb_uncompress_preview() available."
      begin
        uncompressed = io.extract_rgb_uncompress_preview('extract')
        puts "[+] Extracted : %s" % uncompressed
      end
    end
  end
end

if __FILE__ == $0
  if ARGV.length > 0
    if ARGV[1] == "bench"
      Benchmark.bm(5) do |x|
        x.report("run libexif usecase test.rb"){
          1000.times{run(ARGV[0], true)}
        }
      end
    else
      run(ARGV[0])
    end
  else
    puts "Usage: #{$0} <path_to_picture>"
  end
end
