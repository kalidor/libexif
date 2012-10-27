# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

THUMBNAIL = Hash.new
THUMBNAIL["XResolution"] = {:id => 0x011a}
THUMBNAIL["YResolution"] = {:id => 0x011b}
THUMBNAIL["Compression"] = {:id => 0x0103, :exec => proc{|v|
  case v
  when 1
    "Uncompressed"
  when 2
    "CCITT 1D"
  when 3
    "T4/Group 3 Fax"
  when 4
    "T6/Group 4 Fax"
  when 5
    "LZW"
  when 6
    "JPEG (old-style)"
  when 7
    "JPEG"
  when 8
    "Adobe Deflate"
  when 9
    "JBIG B&W"
  when 10
    "JBIG Color"
  when 99
    "JPEG"
  when 262
    "Kodak 262"
  when 32766
    "Next"
  when 32767
    "Sony ARW Compressed"
  when 32769
    "Packed RAW"
  when 32770
    "Samsung SRW Compressed"
  when 32771
    "CCIRLEW"
  when 32773
    "PackBits"
  when 32809
    "Thunderscan"
  when 32867
    "Kodak KDC Compressed"
  when 32895
    "IT8CTPAD"
  when 32896
    "IT8LW"
  when 32897
    "IT8MP"
  when 32898
    "IT8BL"
  when 32908
    "PixarFilm"
  when 32909
    "PixarLog"
  when 32946
    "Deflate"
  when 32947
    "DCS"
  when 34661
    "JBIG"
  when 34676
    "SGILog"
  when 34677
    "SGILog24"
  when 34712
    "JPEG 2000"
  when 34713
    "Nikon NEF Compressed"
  when 34715
    "JBIG2 TIFF FX"
  when 34718
    "Microsoft Document Imaging (MDI) Binary Level Codec"
  when 34719
    "Microsoft Document Imaging (MDI) Progressive Transform Codec"
  when 34720
    "Microsoft Document Imaging (MDI) Vector"
  when 34892
    "Lossy JPEG"
  when 65000
    "Kodak DCR Compressed"
  when 65535
    "Pentax PEF Compressed"
  end
  }
}
THUMBNAIL["ResolutionUnit"] = {:id => 0x0128, :exec => proc{|v|
  case v
  when 1
    "None"
  when 2
    "Inches"
  when 3
    "Cm"
  end
  }
}
THUMBNAIL["ThumbnailOffset"] = {:id => 0x0201}
THUMBNAIL["ThumbnailLength"] = {:id => 0x0202}
