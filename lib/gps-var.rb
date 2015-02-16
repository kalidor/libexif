# This file is part of libEXIF, a library to access stored data in picture.
# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

class Gps < Template
end

def compute_GPS(d, m, s, ref=nil)
  if s[0]/s[1] == 0
    d = d.inject(:/).to_i
    m = Rational(m[0], m[1]).to_f
    s_sup = m % 1
    s = (Rational(s[0], s[1]).to_f + s_sup) * 60
    # See http://en.wikipedia.org/wiki/Geographic_coordinate_conversion
    # and http://en.wikipedia.org/wiki/Geotagging#GPS_formats
    geo = d + Rational((Rational(s.to_f,3600).to_f + m), 60).to_f
    lat = "%d deg %d' %0.2f\" %%s (%%s%0.14f)" % [d, m.to_i, s, geo]
    lat % [ref, ["S","W"].include?(ref) ? "-" : "+"]
  end
end

GPS_VAR = Hash.new
GPS_VAR["VersionId"] = {:id => 0x0000 }
GPS_VAR["LatitudeRef"] = {:id => 0x0001 }
GPS_VAR["Latitude"] = {:id => 0x0002, :exec => proc{|d, m, s, ref|
  compute_GPS(d, m, s, ref)
  }
}
GPS_VAR["LongitudeRef"] = {:id => 0x0003 }
GPS_VAR["Longitude"] = {:id => 0x0004, :exec => proc{|d, m, s, ref|
  compute_GPS(d, m, s, ref)
  }
}
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
GPS_VAR["TimeStamp"] = {:id => 0x0007, :exec => proc{|d, m, s|
    tmp = []
    [d, m, s].map{|x|
      tmp << Rational(x[0], x[1]).to_f
    }
    tmp.join(":")
  }
}
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
