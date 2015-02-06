# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

BIG_ENDIAN = "MM*\x00"
LITTLE_ENDIAN = "II*\x00"

BYTE = {:id => 0x01, :unit => 1}
ASCII = {:id => 0x02, :unit => 1}
INT16U = {:id => 0x03, :unit => 2}
INT32U = {:id => 0x04, :unit => 4}
RATIONAL64U = {:id => 0x05, :unit => 8} # first is numerator, second is denominator
UNDEF = {:id => 0x07, :unit => 4} # first is numerator, second is denominator
RATIONAL64S = {:id => 0x0a, :unit => 8} # first is numerator, second is denominator

EXIF = Hash.new
EXIF["ExposureTime"] = {:id => 0x829a}
EXIF["Copyright"] = {:id => 0x8298}
EXIF["FNumber"] = {:id => 0x829d}
EXIF["ExposureProgram"]= {:id => 0x8822, :exec => proc{|v|
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
EXIF["ISOSpeedRatings"]= {:id => 0x8827}
EXIF["ExifVersion"]= {:id => 0x9000}
EXIF["SpectralSensitivity"] = {:id => 0x8824 }
EXIF["GPSInfo"] = {:id => 0x8825 }
EXIF["ISO"] = {:id => 0x8827 }
EXIF["Opto-ElectricConvFactor"] = {:id => 0x8828 }
EXIF["SensitivityType"] = {:id => 0x8830, :exec => proc{|v|
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
EXIF["StandardOutputSensitivity"] = {:id => 0x8831 }
EXIF["RecommendedExposureIndex"] = {:id => 0x8832 }
EXIF["ISOSpeed"] = {:id => 0x8833 }
EXIF["ISOSpeedLatitudeyyy"] = {:id => 0x8834 }
EXIF["ISOSpeedLatitudezzz"] = {:id => 0x8835 }
EXIF["ExifVersion"] = {:id => 0x9000 }
EXIF["DateTimeOriginal"]= {:id => 0x9003}
EXIF["CreateDate"]= {:id => 0x9004}
EXIF["ComponentConfiguration"]= {:id => 0x9101}
EXIF["CompressedBitsPerPixel"]= {:id => 0x9102}
EXIF["ShutterSpeedValue"]= {:id => 0x9201}
EXIF["ApertureValue"]= {:id => 0x9202}
EXIF["BrightnessValue"]= {:id => 0x9203}
EXIF["ExposureCompensation"]= {:id => 0x9204}
EXIF["MaxApertureValue"]= {:id => 0x9205}
EXIF["SubjectDistance"]= {:id => 0x9206}
EXIF["MeteringMode"]= {:id => 0x9207, :exec => proc{|v|
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
EXIF["LightSource"]= {:id => 0x9208, :exec => proc{|v|
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
EXIF["Flash"]= {:id => 0x9209, :exec => FLASH}
EXIF["FocalLength"]= {:id => 0x920a}
EXIF["SubjectArea"] = {:id => 0x9214}
EXIF["MakerNotes"]= {:id => 0x927c}
EXIF["UserComment"]= {:id => 0x9286}
EXIF["SubSecTime"]= {:id => 0x9290}
EXIF["SubSecTimeOriginal"]= {:id => 0x9291}
EXIF["SubSecTimeDigitized"]= {:id => 0x9292}
EXIF["FlashPixVersion"] = {:id => 0xa000}
EXIF["ColorSpace"] = {:id => 0xa001}
EXIF["ExifImageWidth"] = {:id => 0xa002}
EXIF["ExifImageHeight"] = {:id => 0xa003}
EXIF["RelatedSoundFile"] = {:id => 0xa004}
EXIF["InteropOffset"] = {:id => 0xa005}
EXIF["FocalPlaneXResolution"] = {:id => 0xa20e}
EXIF["FocalPlaneYResolution"] = {:id => 0xa20f}
EXIF["FocalPlaneResolutionUnit"] = {:id => 0xa210, :exec => proc{|v|
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
EXIF["SubjectLocation"] = {:id => 0xa214}
EXIF["ExposureIndex"] = {:id => 0xa215}
EXIF["SensingMethod"] = {:id => 0xa217, :exec => proc{|v|
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
EXIF["FileSource"] = {:id => 0xa300, :exec => proc{|v|
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
EXIF["SceneType"] = {:id => 0xa301, :exec => proc{|v|
  case v
  when 1
    "Directly photographed"
  else
    "Unknown"
  end
  }
}
EXIF["CFAPattern"] = {:id => 0xa302 }
EXIF["CustomeRendered"] = {:id => 0xa401, :exec => proc{|v|
  case v
  when 0
    "Normal"
  when 1
    "Custom"
  end
  }
}
EXIF["ExposureMode"] = {:id => 0xa402, :exec => proc{|v|
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
EXIF["WhiteBalance"] = {:id => 0xa403, :exec => proc{|v|
  case v
  when 0
    "Auto"
  when 1
    "Manual"
  end
  }
}
EXIF["DigitalZoomRatio"] = {:id => 0xa404}
EXIF["FocalLengthIn35mmFormat"] = {:id => 0xa405}
EXIF["SceneCaptureType"] = {:id => 0xa406, :exec => proc{|v|
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
EXIF["GainControl"] = {:id => 0xa407, :exec => proc{|v|
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
EXIF["Contrast"] = {:id => 0xa408, :exec => proc{|v|
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
EXIF["Saturation"] = {:id => 0xa409, :exec => proc{|v|
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
EXIF["Sharpness"] = {:id => 0xa40a, :exec => proc{|v|
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
EXIF["DeviceSettingDescripion"] = {:id => 0xa40b}
EXIF["SubjectDistanceRange"] = {:id => 0xa40c, :exec => proc{|v|
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
EXIF["ImageUniqueID"] = {:id => 0xa420}
EXIF["OwnerName"] = {:id => 0xa430}
EXIF["SerialNumber"] = {:id => 0xa431}
EXIF["LensInfo"] = {:id => 0xa432}
EXIF["LensMake"] = {:id => 0xa433}
EXIF["LensModel"] = {:id => 0xa434}
EXIF["LensSerialNumber"] = {:id => 0xa435}
