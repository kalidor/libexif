#!/usr/bin/env ruby1.9
$LOAD_PATH << "."
require 'libEXIF'
if ARGV.length > 0
  filename = ARGV[0].dup
end
io = REXIF::IMG.new(filename, true)
puts "Available methods: %s" % io.methods.map{|m| m if m.to_s.start_with?('has_')}.delete_if{|m| m == nil}.join(", ")
puts "Available methods: %s" % io.methods.map{|m| m if m.to_s.start_with?('extract_')}.delete_if{|m| m == nil}.join(", ")
puts "Available attributes relative to JPG library:"
puts io.help
puts
io.help.split(", ").each do |k|
  puts "%s: %s" % [k, io.send(k.to_sym)]
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
