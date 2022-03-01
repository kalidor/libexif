# This file is part of libEXIF_VAR, a library to access stored data in picture.
# (c) 2014-2020 G. Charbonneau
# Published under the terms of WtfPLv2

class Header < Template
end
HEADER_VAR = {}
HEADER_VAR["JPEGHeader"] = {:id => 0xFFd8}
0xe0.upto(0xef).each_with_index{|c, i|
  HEADER_VAR["APP#{i}"] = {:id => c}
}
HEADER_VAR["APP13Segment"] = {:id => 0xFFED}

module HEADER
  def header_analyze(offset, data)
    @io.seek(0, IO::SEEK_SET)
    @io.read(2)
    HEADER.map{|h|
      
    }
  end
end