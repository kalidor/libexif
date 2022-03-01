Gem::Specification.new do |s|
  s.name = 'exif'
  s.version = '0.1'
  s.date = '2022-02-28'
  s.summary = 'exif exifrary',
  s.description = 'exif library to easily access EXIF information in file',
  s.authors = ["Gregory 'kalidor' CHARBONNEAU"]
  s.email = 'kalidor@unixed.fr'
  s.files = [ 'exif/exif-var.rb',
  'exif/flash-var.rb',
  'exif/gps-var.rb',
  'exif/header-var.rb', 
  'exif/helper.rb',
  'exif/ifd-var.rb',
  'exif.rb']
  s.homepage = 'https://github.com/kalidor/libexif'
  s.license = 'WTFPL'
  s.require_paths = ['.','exif']
end
