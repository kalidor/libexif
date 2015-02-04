#!/usr/bin/env ruby1.9
$LOAD_PATH << "."
require 'libEXIF'
require 'benchmark'

$BENCH = false

def run(filename)
  io = REXIF::IMG.new(filename, false)
  if not $BENCH
    #puts "Available methods: %s" % io.methods.map{|m| m if m.to_s.start_with?('has_')}.delete_if{|m| m == nil}.join(", ")
    #puts "Available methods: %s" % io.methods.map{|m| m if m.to_s.start_with?('extract_')}.delete_if{|m| m == nil}.join(", ")
    #puts "Available attributes relative to JPG library:"
    #puts io.help
    #puts
    ## using methods
    #io.help.split(", ").each do |k|
    #  puts "%s: %s" % [k, io.send(k.to_sym)]
    #end

    # or using dedicated class methods
    # io.gps
    # io.exif
    # io.ifd
    puts io.ifd[0].Make
    puts io.ifd[0].Model
    #puts io.ifd[0].Artist
    puts io.ifd[0].ImageWidth
    #puts io.ifd[2].ImageWidth
    #puts io.ifd[3].ImageWidth
    #(0..3).map{|i|
    #puts (io.ifd[i].methods - io.ifd[i].class.methods).inspect
    #}
    #puts io.exif.Flash
    #puts io.exif.methods - io.exif.class.methods

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
