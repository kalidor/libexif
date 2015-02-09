#!/usr/bin/env ruby1.9
$LOAD_PATH << "."
require 'libEXIF'
require 'benchmark'

$BENCH = false

def run(filename)
  io = REXIF::IMG.new(filename, true)
  io.analyze()
  if not $BENCH
    # io.gps
    # io.exif
    # io.ifdX
    puts "[-] io.instance_variables:"
    puts io.instance_variables.inspect
    puts "[-] io.ifd0 method available:"
    puts io.instance_variable_get("@ifd0").infos.inspect
    0.upto(3).map{|id|
      if io.instance_variable_defined? "@ifd%d" % id
        io.instance_variable_get("@ifd%d" % id).infos.map{|m|
          puts "io.ifd%d.%s: %s" % [id, m, io.instance_variable_get("@ifd%d" % id).send(m).to_s]
        }
      end
    }
    puts "GPS infos: %s" % io.gps.infos.inspect if io.instance_variable_defined? '@gps'
    if io.instance_variable_defined? "@gps"
      io.gps.infos.map{|m|
        puts "io.gps.%s: %s" % [m, io.gps.send(m)]
      }
    end
    puts "EXIF infos: %s" % io.exif.infos.inspect if io.instance_variable_defined? '@exif'
    if io.instance_variable_defined? "@exif"
      io.exif.infos.map{|m|
        puts "io.exif.%s: %s" % [m, io.exif.send(m)]
      }
    end

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
      $BENCH = true
      Benchmark.bm(5) do |x|
        x.report("run libexif usecase test.rb"){
          1000.times{run(ARGV[0])}
        }
      end
    else
      run(ARGV[0])
    end
  end
end
