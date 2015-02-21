# libexif
Pure ruby library to get EXIF data in a picture. Thumbnail and image extraction are also supported.
For now, JPEG and CR2 format are supported.
--
Existing gem did not returned what I was looking for, so I decide to try to do my own.
(warning: I'm not a developer, if you have any advice/remarks/suggestions, please let me know.)

Only declared EXIF data (see *-var.rb in lib/) are supported. I will try to add more.

### Sample
```ruby
>img = REXIF::IMG.new('my_picture.CR2')
>img.analyze()
```

#### interesting instance variables
```ruby
>img.filename   # filename...
>img.endianess  # endianess (:big or :little)
```

#### If the picture contains embedded thumbnail (here is output of .CR2 file)
```ruby
>img.extract_thumbnail()              # available if thumbnail are contains in the file
>img.extract_preview()                # available if preview are contains in the file
>img.extract_lossless_preview()       # and so on
>img.extract_rgb_uncompress_preview() # and so on

> img.extract_thumbnail("extraction_directory/")
```

#### EXIF data
EXIF data 'section' are stored using a number X (ifdX). Sometimes EXIF identifier is the same, so to
avoid overwriting previous EXIF data, the library keep the same idea:

```ruby
>img.ifd0?
true
>img.ifd0.infos
["ImageWidth", "ImageHeight", "BitsPerSample", "Compression", "Make", "Model", "PreviewImageStart", "Orientation", "PreviewImageLength", "XResolution", "YResolution", "ResolutionUnit", "ModifyDate", "Artist", "Copyright", "ExifOffset", "GPSInfo"]
>img.ifd0.Model
Canon EOS 6D
# same idea for ifd1/2/3, exif, gps
```

Or you can do it dynamically:

```ruby
>if img.ifd0?
>  img.ifd0.infos.map{|i|
>    puts "#{i}: %s" % img.ifd0.send(i).to_s
>  }
>end
ImageWidth: 5472
ImageHeight: 3648
BitsPerSample: 238
Compression: JPEG (old-style)
Make: Canon
Model: Canon EOS 6D
PreviewImageStart: 95000
Orientation: Horizontal
PreviewImageLength: 1285239
XResolution: 72.00 (72)
YResolution: 72.00 (72)
ResolutionUnit: Inches
ModifyDate: 2014:11:25 06:15:54
Artist: 
Copyright: 
ExifOffset: 446
GPSInfo: 69724
# etc same idea for img.ifd1/2/3, img.exif, img.gps.
```
