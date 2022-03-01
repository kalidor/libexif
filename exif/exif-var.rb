# This file is part of libEXIF_VAR, a library to access stored data in picture.
# (c) 2014-2020 G. Charbonneau
# Published under the terms of WtfPLv2

BIG_ENDIAN = "MM\x00*"
LITTLE_ENDIAN = "II*\x00"

BYTE = {:id => 0x01, :unit => 1}
ASCII = {:id => 0x02, :unit => 1}
INT16U = {:id => 0x03, :unit => 2}
INT32U = {:id => 0x04, :unit => 4}
RATIONAL64U = {:id => 0x05, :unit => 8} # first is numerator, second is denominator
UNDEF = {:id => 0x07, :unit => 4} # first is numerator, second is denominator
RATIONAL64S = {:id => 0x0a, :unit => 8} # first is numerator, second is denominator

class Exif < Template
end

EXIF_VAR = Hash.new
EXIF_VAR["ExposureTime"] = {:id => 0x829a}
EXIF_VAR["Copyright"] = {:id => 0x8298}
EXIF_VAR["FNumber"] = {:id => 0x829d}
EXIF_VAR["ExposureProgram"]= {:id => 0x8822, :exec => proc{|v|
  case v
  when 0
    "Undefined"
  when 1
    "Manual"
  when 2
    "Program AE"
  when 3
    "Aperture priority AE"
  when 4
    "Shutter speed priority AE"
  when 5
    "Creative (slow speed)"
  when 6
    "Action (high speed)"
  when 7
    "Portrait"
  when 8
    "Landscape"
  when 9
    "Bulb"
  end
  }
}
EXIF_VAR["ISOSpeedRatings"]= {:id => 0x8827}
EXIF_VAR["ExifVersion"]= {:id => 0x9000}
EXIF_VAR["SpectralSensitivity"] = {:id => 0x8824 }
EXIF_VAR["GPSInfo"] = {:id => 0x8825 }
EXIF_VAR["ISO"] = {:id => 0x8827 }
EXIF_VAR["Opto-ElectricConvFactor"] = {:id => 0x8828 }
EXIF_VAR["SensitivityType"] = {:id => 0x8830, :exec => proc{|v|
  case v
  when 0
    "Unknown"
  when 1
    "Standard Output Sensitivity"
  when 2
    "Recommended Exposure Index"
  when 3
    "ISO Speed"
  when 4
    "Standard Output Sensitivity and Recommended Exposure Index"
  when 5
    "Standard Output Sensitivity and ISO Speed"
  when 6
    "Recommended Exposure Index and ISO Speed"
  when 7
    "Standard Output Sensitivity, Recommended Exposure Index and ISO Speed"
  end
  }
}
EXIF_VAR["StandardOutputSensitivity"] = {:id => 0x8831 }
EXIF_VAR["RecommendedExposureIndex"] = {:id => 0x8832 }
EXIF_VAR["ISOSpeed"] = {:id => 0x8833 }
EXIF_VAR["ISOSpeedLatitudeyyy"] = {:id => 0x8834 }
EXIF_VAR["ISOSpeedLatitudezzz"] = {:id => 0x8835 }
EXIF_VAR["ExifVersion"] = {:id => 0x9000 }
EXIF_VAR["DateTimeOriginal"]= {:id => 0x9003}
EXIF_VAR["CreateDate"]= {:id => 0x9004}
EXIF_VAR["ComponentConfiguration"]= {:id => 0x9101}
EXIF_VAR["CompressedBitsPerPixel"]= {:id => 0x9102}
EXIF_VAR["ShutterSpeedValue"]= {:id => 0x9201}
EXIF_VAR["ApertureValue"]= {:id => 0x9202}
EXIF_VAR["BrightnessValue"]= {:id => 0x9203}
EXIF_VAR["ExposureCompensation"]= {:id => 0x9204}
EXIF_VAR["MaxApertureValue"]= {:id => 0x9205}
EXIF_VAR["SubjectDistance"]= {:id => 0x9206}
EXIF_VAR["MeteringMode"]= {:id => 0x9207, :exec => proc{|v|
  case v
  when 0
    "Unknown"
  when 1
    "Average"
  when 2
    "Center-weighted average"
  when 3
    "Spot"
  when 4
    "Multi-spot"
  when 5
    "Multi-segment"
  when 6
    "Partial"
  when 255
    "Other"
  end
  }
}
EXIF_VAR["LightSource"]= {:id => 0x9208, :exec => proc{|v|
  case v
  when 0
    "Unknown"
  when 1
    "Daylight"
  when 2
    "Fluorescent"
  when 3
    "Tungsten (Incandescent)"
  when 4
    "Flash"
  when 9
    "Fine Weather"
  when 10
    "Cloudy"
  when 11
    "Shade"
  when 12
    "Daylight Fluorescent"
  when 13
    "Day White Fluorescent"
  when 14
    "Cool White Fluorescent"
  when 15
    "White Fluorescent"
  when 16
    "Warm White Fluorescent"
  when 17
    "Standard Light A"
  when 18
    "Standard Light B"
  when 19
    "Standard Light C"
  when 20
    "D55"
  when 21
    "D65"
  when 22
    "D75"
  when 23
    "D50"
  when 24
    "ISO Studio Tungsten"
  when 255
    "Other"
  end
  }
}
EXIF_VAR["Flash"]= {:id => 0x9209, :exec => FLASH}
EXIF_VAR["FocalLength"]= {:id => 0x920a}
EXIF_VAR["SubjectArea"] = {:id => 0x9214}
EXIF_VAR["MakerNotes"]= {:id => 0x927c}
EXIF_VAR["UserComment"]= {:id => 0x9286}
EXIF_VAR["SubSecTime"]= {:id => 0x9290}
EXIF_VAR["SubSecTimeOriginal"]= {:id => 0x9291}
EXIF_VAR["SubSecTimeDigitized"]= {:id => 0x9292}
EXIF_VAR["FlashPixVersion"] = {:id => 0xa000}
EXIF_VAR["ColorSpace"] = {:id => 0xa001}
EXIF_VAR["ExifImageWidth"] = {:id => 0xa002}
EXIF_VAR["ExifImageHeight"] = {:id => 0xa003}
EXIF_VAR["RelatedSoundFile"] = {:id => 0xa004}
EXIF_VAR["InteropOffset"] = {:id => 0xa005}
EXIF_VAR["FocalPlaneXResolution"] = {:id => 0xa20e}
EXIF_VAR["FocalPlaneYResolution"] = {:id => 0xa20f}
EXIF_VAR["FocalPlaneResolutionUnit"] = {:id => 0xa210, :exec => proc{|v|
  case v
  when 1
    "None"
  when 2
    "inches"
  when 3
    "cm"
  when 4
    "mm"
  when 5
    "um"
  end
  }
}
EXIF_VAR["SubjectLocation"] = {:id => 0xa214}
EXIF_VAR["ExposureIndex"] = {:id => 0xa215}
EXIF_VAR["SensingMethod"] = {:id => 0xa217, :exec => proc{|v|
  case v
  when 1
    "Not defined "
  when 2
    "One-chip color area "
  when 3
    "Two-chip color area "
  when 4
    "Three-chip color area "
  when 5
    "Color sequential area "
  when 7
    "Trilinear "
  when 8
    "Color sequential linear"
  end
  }
}
EXIF_VAR["FileSource"] = {:id => 0xa300, :exec => proc{|v|
  case v
  when 1
    "Film Scanner "
  when 2
    "Reflection Print Scanner "
  when 3
    "Digital Camera "
#"\x03\x00\x00\x00" = Sigma Digital Camera
  end
  }
}
EXIF_VAR["SceneType"] = {:id => 0xa301, :exec => proc{|v|
  case v
  when 1
    "Directly photographed"
  else
    "Unknown"
  end
  }
}
EXIF_VAR["CFAPattern"] = {:id => 0xa302 }
EXIF_VAR["CustomeRendered"] = {:id => 0xa401, :exec => proc{|v|
  case v
  when 0
    "Normal"
  when 1
    "Custom"
  end
  }
}
EXIF_VAR["ExposureMode"] = {:id => 0xa402, :exec => proc{|v|
  case v
  when 0
    "Auto"
  when 1
    "Manual"
  when 2
    "Auto bracket"
  end
  }
}
EXIF_VAR["WhiteBalance"] = {:id => 0xa403, :exec => proc{|v|
  case v
  when 0
    "Auto"
  when 1
    "Manual"
  end
  }
}
EXIF_VAR["DigitalZoomRatio"] = {:id => 0xa404}
EXIF_VAR["FocalLengthIn35mmFormat"] = {:id => 0xa405}
EXIF_VAR["SceneCaptureType"] = {:id => 0xa406, :exec => proc{|v|
  case v
  when 0
    "Standard"
  when 1
    "Landscape"
  when 2
    "Portrait"
  when 3
    "Night"
  end
  }
}
EXIF_VAR["GainControl"] = {:id => 0xa407, :exec => proc{|v|
  case v
  when 0
    "None"
  when 1
    "Low gain up"
  when 2
    "High gain up"
  when 3
    "Low gain down"
  when 4
    "High gain down"
  end
  }
}
EXIF_VAR["Contrast"] = {:id => 0xa408, :exec => proc{|v|
  case v
  when 0
    "Normal"
  when 1
    "Low"
  when 2
    "High"
  end
  }
}
EXIF_VAR["Saturation"] = {:id => 0xa409, :exec => proc{|v|
  case v
  when 0
    "Normal"
  when 1
    "Low"
  when 2
    "High"
  end
  }
}
EXIF_VAR["Sharpness"] = {:id => 0xa40a, :exec => proc{|v|
  case v
  when 0
    "Normal"
  when 1
    "Soft"
  when 2
    "Hard"
  end
  }
}
EXIF_VAR["DeviceSettingDescripion"] = {:id => 0xa40b}
EXIF_VAR["SubjectDistanceRange"] = {:id => 0xa40c, :exec => proc{|v|
  case v
  when 0
    "Unknown"
  when 1
    "Macro"
  when 2
    "Close"
  when 3
    "Distant"
  end
  }
}
EXIF_VAR["ImageUniqueID"] = {:id => 0xa420}
EXIF_VAR["OwnerName"] = {:id => 0xa430}
EXIF_VAR["SerialNumber"] = {:id => 0xa431}
EXIF_VAR["LensInfo"] = {:id => 0xa432, :exec => proc{|in1, in2|
  foc = []
  depth = []
  [[foc,in1],[depth, in2]].map{|k, v|
      v.unpack("L*").each_slice(2) do |n, d|
      d == 0 ? k << 0 : k << n/d
    end
  }
  if foc[0] == foc[1]
    "%dmm F%d-%d" % [foc[0]].concat(depth)
  else
    "%d-%dmm F%d-%d" % foc.concat(depth)
  end
  }
}
EXIF_VAR["LensMake"] = {:id => 0xa433}
EXIF_VAR["LensModel"] = {:id => 0xa434}
EXIF_VAR["LensSerialNumber"] = {:id => 0xa435}

module EXIF
  def exif_analyze(offset, data)
    @io.seek(@TIFF_header_offset + data["IFD0"]["ExifOffset"][:value], IO::SEEK_SET)
    offset, data["EXIF"] = get_offset(expected_entries?, EXIF_VAR)
    offset = offset.convert(@packspec, 5).first
  end
end
