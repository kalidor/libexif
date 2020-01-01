# This file is part of libEXIF, a library to access stored data in picture.
# (c) 2014-2020 G. Charbonneau
# Published under the terms of WtfPLv2

class Ifd0 < Template
end

class Ifd1 < Template
end

class Ifd2 < Template
end

class Ifd3 < Template
end

IFD_VAR = Hash.new
IFD_VAR["ImageWidth"] = {:id => 0x0100}
IFD_VAR["ImageHeight"] = {:id => 0x0101}
IFD_VAR["BitsPerSample"] = {:id => 0x0102}
IFD_VAR["Compression"] = {:id => 0x0103, :exec => proc{|v|
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
IFD_VAR["PhotometricInterpretation"] = {:id => 0x0106}
IFD_VAR["ImageDescription"] = {:id => 0x010e}
IFD_VAR["Make"] = {:id => 0x010f}
IFD_VAR["Model"] = {:id => 0x0110}
IFD_VAR["PreviewImageStart"] = {:id => 0x0111}
IFD_VAR["SamplesPerPixel"] = {:id => 0x0115}
IFD_VAR["RowsPerStrip"] = {:id => 0x0116}
IFD_VAR["Orientation"] = {:id => 0x0112, :exec => proc{|v|
  case v
  when 1
    "Horizontal"
  when 2
    "Mirror Horizontal"
  when 3
    "Rotate 180"
  when 4
    "Mirror Vertical"
  when 5
    "Mirror horizontal and rotate 270 CW"
  when 6
    "Rotate 90 CW "
  when 7
    "Mirror horizontal and rotate 90 CW"
  when 8
    "Rotate 270 CW"
  end
  }
}
IFD_VAR["PreviewImageLength"] = {:id => 0x0117}
IFD_VAR["XResolution"] = {:id => 0x011a}
IFD_VAR["YResolution"] = {:id => 0x011b}
IFD_VAR["PlanarConfiguration"] = {:id => 0x011c, :exec => proc{|v|
  case v
  when 1
    "Chunky"
  when 2
    "Planar"
  end
  }
}
IFD_VAR["ResolutionUnit"] = {:id => 0x0128, :exec => proc{|v|
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

IFD_VAR["Software"] = {:id => 0x0131}
IFD_VAR["ModifyDate"] = {:id => 0x0132}
IFD_VAR["Artist"] = {:id => 0x013b}
IFD_VAR["WhitePoint"] = {:id => 0x013e}
IFD_VAR["PrimaryChromaticities"] = {:id => 0x013f}
IFD_VAR["ThumbnailOffset"] = {:id => 0x0201}
IFD_VAR["ThumbnailLength"] = {:id => 0x0202}
IFD_VAR["YCbCrCoefficients"] = {:id => 0x0211}
IFD_VAR["YCbCrPositioning"] = {:id => 0x0213, :exec => proc{|v|
  case v
  when 1
    "Centere"
  when 2
    "Co-Sited"
  end
  }
}
IFD_VAR["ReferenceBlackWhite"] = {:id => 0x0214}
IFD_VAR["Copyright"] = {:id => 0x8298}
IFD_VAR["ExifOffset"] = {:id => 0x8769}
IFD_VAR["GPSInfo"] = {:id => 0x8825}
 
module IFD
  def ifd_analyze(offset, data)
    i = 0
    ## Each IFD (IFD0 to IFD3) has potential pointer to the next one
    ## last one is 0x0000
    while offset != 0 
      @io.seek(@TIFF_header_offset + offset , IO::SEEK_SET)
      offset, data["IFD%d" % i] = get_offset(expected_entries?, IFD_VAR)
      offset = offset.convert(@packspec, 5).first
      i += 1
    end
  end
end
