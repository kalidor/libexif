# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

GPS = Hash.new
GPS["GPSVersionId"] = {:id => 0x0000 }
GPS["GPSLatitudeRef"] = {:id => 0x0001 }
GPS["GPSLatitude"] = {:id => 0x0002 }
GPS["GPSLongitudeRef"] = {:id => 0x0003 }
GPS["GPSLongitude"] = {:id => 0x0004 }
GPS["GPSAltitudeRef"] = {:id => 0x0005, :exec => proc{|v|
  case v
  when 0, "0"
    "Above sea level (0)"
  when 1, "1"
    "Below sea level (1)"
  end
  }
}
GPS["GPSAltitude"] = {:id => 0x0006 }
GPS["GPSTimeStamp"] = {:id => 0x0007 }
GPS["GPSSatellites"] = {:id => 0x0008 }
GPS["GPSStatus"] = {:id => 0x0009, :exec => proc{|v|
  case v
  when "A"
    "Measurement Active"
  when "V"
    "Measurement Void"
  end
  }
}
GPS["GPSMeasureMode"] = {:id => 0x000a }
GPS["GPSDOP"] = {:id => 0x000b }
GPS["GPSMapDatum"] = {:id => 0x0012 }
GPS["GPSDateStamp"] = {:id => 0x001d }
