# This file is part of libEXIF, a library to access stored data in picture.
# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

class Gps < Template
end

GPS = Hash.new
GPS["VersionId"] = {:id => 0x0000 }
GPS["LatitudeRef"] = {:id => 0x0001 }
GPS["Latitude"] = {:id => 0x0002 }
GPS["LongitudeRef"] = {:id => 0x0003 }
GPS["Longitude"] = {:id => 0x0004 }
GPS["AltitudeRef"] = {:id => 0x0005, :exec => proc{|v|
  case v
  when 0, "0"
    "Above sea level (0)"
  when 1, "1"
    "Below sea level (1)"
  end
  }
}
GPS["Altitude"] = {:id => 0x0006 }
GPS["TimeStamp"] = {:id => 0x0007 }
GPS["Satellites"] = {:id => 0x0008 }
GPS["Status"] = {:id => 0x0009, :exec => proc{|v|
  case v
  when "A"
    "Measurement Active"
  when "V"
    "Measurement Void"
  end
  }
}
GPS["MeasureMode"] = {:id => 0x000a }
GPS["DOP"] = {:id => 0x000b }
GPS["MapDatum"] = {:id => 0x0012 }
GPS["DateStamp"] = {:id => 0x001d }
