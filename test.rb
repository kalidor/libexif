#!/usr/bin/env ruby1.9
$LOAD_PATH << "."
require 'libEXIF'
if ARGV.length > 0
  filename = ARGV[0].dup
end
io = REXIF::IMG.new(filename)
puts "Available methods relative to JPG library:"
puts io.help
puts
io.help.split(", ").each do |k|
  puts "%s: %s" % [k, io.send(k.to_sym)]
end
if io.has_thumbnail?
  puts "[+] extract_thumb() available."
  begin
    thumbname = io.extract_thumbnail
    puts "[+] Extracted : %s" % thumbname
  end
end
