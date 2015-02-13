# This file is part of libEXIF, a library to access stored data in picture.
# coding: utf-8
# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

class PackSpec
  def initialize(endian)
    @packspec = [
        (endian == :little) ? 'v*' : 'N*', # only used to get IFD0 pointer
        'C*',           # BYTE (8-bit unsigned integer)
        nil,           # ASCII
        (endian == :little) ? 'v*' : 'n*', # SHORT (16-bit unsigned integer)
        (endian == :little) ? 'V*' : 'N*', # LONG (32-bit unsigned integer)
        (endian == :little) ? 'V*' : 'N*', # LONG (32-bit unsigned integer)
        'c*',           # SBYTE (8-bit signed integer)
        nil,           # UNDEFINED
        (endian == :little) ? 'v*' : 'n*', # SSHORT (16-bit unsigned integer)
        (endian == :little) ? 'V*' : 'N*', # SLONG (32-bit unsigned integer)
        (endian == :little) ? 'V*' : 'N*', # SRATIONAL (32-bit unsigned integer)
      ]
  end

  def packspec
    @packspec
  end
end

# Overload String class to add helpful stuff
class String
  def convert(ptr, type) # endianess convertion
    self.unpack(ptr.packspec[type])
  end
end

class Template
  attr_reader :infos
  def initialize(data)
    @data = data
    @infos = data.keys
  end
  def method_missing(method)
    if @data.keys.include? method.to_s
      @data[method.to_s][:value]
    else
      raise NoMethodError, "Unknown method '%s'.\nSee 'infos' instance variable." % method.to_s
    end
  end
end

