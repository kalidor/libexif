require_relative 'libEXIF'
require 'pry'
#binding.pry
%w-IMG_3529.jpg lena_std.tiff sample.tiff-.map do |f|
  img = REXIF::IMG.new("tests/#{f}", true)
  begin
  img.analyze()
  rescue ex
    puts "Hu something failed..."
    puts "#{ex.backtrace}: #{ex.message} (#{ex.class})"
  end
  img.print
  if img.ifd0?
    img.ifd0.infos.map{|i|
      puts " \\-#{i}: %s" % img.ifd0.send(i).to_s
    }
  end
  puts "="*40
end
