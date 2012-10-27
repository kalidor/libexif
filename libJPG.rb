# TODO: don't use the offset, search key << type, maybe faster
# this version is probably slow because each seek, we seek from the begining of the file
$LOAD_PATH << "."
require 'libJPG-var'
@entries = Hash.new
@exif = Hash.new
$DEBUG = true
$DDEBUG = nil
@HEADER = nil


class String
  def to_id
    self[0..1].reverse.unpack('H*').join.hex
  end
  def to_size
    self.unpack('H*').join.hex
  end
  def to_type
    to_size
  end
  def to_num
    self.reverse.unpack('H*').join.to_i(16)
  end
  def to_num!
    # Ugly hack to replace in-place the value
    self.replace(self.reverse.unpack('H*').join.to_i(16).to_s)
  end
end

class Fixnum
  def to_hexa
    self.to_s(16)
  end
end

class Value
  def initialize(val)
    @val = val
  end
  def value
    @val.reverse.join.hex
  end
end


class File
  def puts(str)
    STDOUT.write("%s\n" % str)
  end
  def dputs(str)
    puts "[D] %s" % str if $DDEBUG
  end
  def sputs(str)
    puts "[+] %s" % str if $DEBUG
  end
  def eputs(str)
    puts "[-] %s" % str
  end

  def readHeader
  # JPEG and TIFF headers
  # We don't need this value for now. Maybe one day
    22.times{readchar}
    @HEADER = true
  end

  def analyze
    @@IFD = get_entries(IFD)
    get_values(@@IFD)
    @@EXIF = get_entries(EXIF)
    get_values(@@EXIF)
    @@IFD.each do |k, v|
      puts "%s: %s" % [k, v[:value]]
    end
    @@EXIF.each do |k,v|
      puts "%s: %s" % [k, v[:value]]
    end
  end

private
  def cur_pos
    dputs "Current position: %d" % pos
  end

  def get_entries(hash)
    data = Hash.new
    # The header contains IFD0-00 to IFD0-XX entries
    if not @HEADER
      readHeader
      @HEADER = true
    end
    id = nil
    while id != hash["ExifOffset"]
      id, type, size, rest = readblock()
      if id == hash["ExifOffset"]
        next
      end
      key = hash.find{|k, v| v == id}
      if not key
        puts "Don't know this id. Next"
        next
      end
      key = key[0]
      sputs "%s : (type: %s, size: %s) 0x%s" % [key, type, size, rest.to_hexa]
      data[key] = {:size => size, :pointer => nil, :value => nil, :type => type}
      if [0x02, 0x03, 0x04, 0x07].include?(type) and size <= 0x04
      # rest is a pointer to the value
        dputs "%s: Direct value detected" % rest
        data[key][:value] = rest
      else
        dputs "Get Pointer: %d" % (rest + SHIFT)
        data[key][:pointer] = rest + SHIFT
      end
    end
    # read Next IFD
    4.times{readchar}
    # cur_pos
    # puts @@IFD['Make'][:pointer]
    return data
  end

  def get_values(hash)
    hash.each do |k, v|
      if not hash[k][:pointer]
        next
      end
      if pos != hash[k][:pointer]
        seek(hash[k][:pointer] - pos, IO::SEEK_CUR)
      end
      tmp = ""
      case hash[k][:type]
      when ASCII[:id]
        hash[k][:size].times{tmp << readchar}
        hash[k][:value] = tmp.strip
        dputs tmp
      when INT16U[:id] # actually this id is a direct value and not used here
      when INT32U[:id] # actually this id is a direct value and not used here
      when UNDEF[:id] # EXIF version
      when RATIONAL64U[:id], RATIONAL64S[:id]
        num = ""
        denum = ""
        hash[k][:size].times{
          4.times{num << readchar}
          4.times{denum << readchar}
        }
        num.to_num!
        denum.to_num!
        dputs "%d/%d" % [num, denum]
        hash[k][:value] = "%d/%d" % [num, denum]
      else
        eputs "%s Unknown type" % hash[k][:type]
      end
    end
    readchar << readchar
  end

  def readblock(size = 12)
    block = ""
    size.times{block << readchar}
    return block[0..1].to_id, block[2].to_type, block[4].to_size, block[8..11].to_num
  end

  def search(block)
    while readblock != block
    end
  end
end

class JPEG
  def initialize(filename)
    io = File.open(filename, 'rb')
    io.analyze
    io.close
  end
end
