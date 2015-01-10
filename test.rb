#!/usr/bin/env ruby1.9
$LOAD_PATH << "."
require 'libEXIF'
if ARGV.length > 0
  filename = ARGV[0].dup
end
io = REXIF::IMG.new(filename)
puts "Available methods: %s" % io.methods.map{|m| m if m.to_s.start_with?('has_')}.delete_if{|m| m == nil}.join(", ")
puts "Available attributes relative to JPG library:"
puts io.help
puts
io.help.split(", ").each do |k|
  puts "%s: %s" % [k, io.send(k.to_sym)]
end

if io.has_thumbnail?
  puts "[+] extract_thumbnail() available."
  begin
    thumbname = io.extract_thumbnail
    puts "[+] Extracted : %s" % thumbname
  end
end
if io.has_small_preview?
  puts "[+] extract_preview() available."
  begin
    preview = io.extract_small_preview('./')
    puts "[+] Extracted : %s" % preview
  end
end

if io.has_losless_preview?
  puts "[+] extract_losless_preview() available."
  begin
    losless_preview = io.extract_losless_preview('./')
    puts "[+] Extracted : %s" % losless_preview
  end
end

if io.has_uncompressed_preview?
  puts "[+] extract_uncompressed_preview() available."
  begin
    uncompressed = io.extract_uncompressed_preview('./')
    puts "[+] Extracted : %s" % uncompressed
  end
end
