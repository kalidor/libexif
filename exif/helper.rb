# This file is part of libEXIF, a library to access stored data in picture.
# coding: utf-8
# (c) 2014-2020 G. Charbonneau
# Published under the terms of WtfPLv2

KNOWN_META = %w[ifd0 ifd1 ifd2 ifd3 exif gps]
BLOCK = 8

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

def puts(str)
  begin
    STDOUT.write(str)
    STDOUT.write("\n")
  rescue
    STDOUT.write("Cannot output\n")
  end
end
def ddputs(str)
  puts "[D] %s" % str if $DEBUG
end
def vputs(str)
  puts "[+] %s" % str if @verbose
end
def dprint(str)
  print "[+] %s" % str if @verbose
end
def eputs(str)
  puts "[-] %s" % str
end
def puts_debug(var, str)
  ddputs "*" * 20 + " DEBUG " + "*" * 20
  ddputs "#{var}: %s" % str.unpack("H*").first.scan(/../).map{|c| "\\x"+c}.join("")
  ddputs "#{var}: %d" % str.convert(@packspec, 5).first
  ddputs "*" * 47
end
def set_value(var, key, data, val)
  ddputs "%s: Direct value detected" % val
  val.strip! if val.class == String
  data[key][:value] = (var.has_key?(:exec)) ? var[:exec].call(val) : val
end
def set_ptr(var, key, data, val)
  ddputs "Get Pointer: %s" % val.unpack("H*").first.to_s
  val = val.convert(@packspec, 5).first
  data[key][:pointer] = val
  data[key][:exec] = var[:exec] if var.has_key?(:exec)
end