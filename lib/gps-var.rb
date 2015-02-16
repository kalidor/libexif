# This file is part of libEXIF, a library to access stored data in picture.
# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

class Gps < Template
end

GPS_VAR = Hash.new
GPS_VAR["VersionId"] = {:id => 0x0000 }
GPS_VAR["LatitudeRef"] = {:id => 0x0001 }
GPS_VAR["Latitude"] = {:id => 0x0002 }
GPS_VAR["LongitudeRef"] = {:id => 0x0003 }
GPS_VAR["Longitude"] = {:id => 0x0004 }
GPS_VAR["AltitudeRef"] = {:id => 0x0005, :exec => proc{|v|
  case v
  when 0, "0"
    "Above sea level (0)"
  when 1, "1"
    "Below sea level (1)"
  end
  }
}
GPS_VAR["Altitude"] = {:id => 0x0006 }
GPS_VAR["TimeStamp"] = {:id => 0x0007 }
GPS_VAR["Satellites"] = {:id => 0x0008 }
GPS_VAR["Status"] = {:id => 0x0009, :exec => proc{|v|
  case v
  when "A"
    "Measurement Active"
  when "V"
    "Measurement Void"
  end
  }
}
GPS_VAR["MeasureMode"] = {:id => 0x000a }
GPS_VAR["DOP"] = {:id => 0x000b }
GPS_VAR["MapDatum"] = {:id => 0x0012 }
GPS_VAR["DateStamp"] = {:id => 0x001d }

module GPS
  def gps_analyze(offset, data)
    @io.seek(@TIFF_header_offset + data["IFD0"]["GPSInfo"][:value], IO::SEEK_SET)
    offset, data["GPS"] = get_offset(expected_entries?, GPS_VAR)
    offset = offset.convert(@packspec, 5).first
  end
end
