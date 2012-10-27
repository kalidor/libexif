# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

IFD = Hash.new
IFD["ImageWidth"] = {:id => 0x0100}
IFD["ImageHeight"] = {:id => 0x0101}
IFD["BitsPerSample"] = {:id => 0x0102}
IFD["Compression"] = {:id => 0x0103, :exec => proc{|v|
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
IFD["PhotometricInterpretation"] = {:id => 0x0106}
IFD["ImageDescription"] = {:id => 0x010e}
IFD["Make"] = {:id => 0x010f}
IFD["Model"] = {:id => 0x0110}
IFD["StripOffsets"] = {:id => 0x0111}
IFD["SamplesPerPixel"] = {:id => 0x0115}
IFD["RowsPerStrip"] = {:id => 0x0116}
IFD["StripByteConunts"] = {:id => 0x0117}
IFD["Orientation"] = {:id => 0x0112, :exec => proc{|v|
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
IFD["XResolution"] = {:id => 0x011a}
IFD["YResolution"] = {:id => 0x011b}
IFD["PlanarConfiguration"] = {:id => 0x011c, :exec => proc{|v|
  case v
  when 1
    "Chunky"
  when 2
    "Planar"
  end
  }
}
IFD["ResolutionUnit"] = {:id => 0x0128, :exec => proc{|v|
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

IFD["Software"] = {:id => 0x0131}
IFD["ModifyDate"] = {:id => 0x0132}
IFD["Artist"] = {:id => 0x013b}
IFD["WhitePoint"] = {:id => 0x013e}
IFD["PrimaryChromaticities"] = {:id => 0x013f}
IFD["JpegIFOffset"] = {:id => 0x0201}
IFD["JpegIFByteCount"] = {:id => 0x0211}
IFD["YCbCrCoefficients"] = {:id => 0x0211}
IFD["YCbCrPositioning"] = {:id => 0x0213, :exec => proc{|v|
  case v
  when 1
    "Centere"
  when 2
    "Co-Sited"
  end
  }
}
IFD["ReferenceBlackWhite"] = {:id => 0x0214}
IFD["Copyright"] = {:id => 0x8298}
IFD["ExifOffset"] = {:id => 0x8769}
