# This file is part of libEXIF, a library to access stored data in picture.
# (c) 2014-2015 G. Charbonneau
# Published under the terms of WtfPLv2

FLASH = proc{|v|
  case v
  when 0x0
    "No flash"
  when 0x1
    "Fired"
  when 0x5
    "Fired, return not detected"
  when 0x7
    "Fired, return detected"
  when 0x8
    "On, did not fire"
  when 0x9
    "On, fired"
  when 0xd
    "On, return not detected"
  when 0xf
    "On, return detected"
  when 0x10
    "Off, did not fire"
  when 0x14
    "Off, did not fire return not detected"
  when 0x18
    "Auto, did not fire"
  when 0x19
    "Auto, fired"
  when 0x1d
    "Auto, fired return not detected"
  when 0x1f
    "Auto, fired return detected"
  when 0x20
    "No flash function"
  when 0x30
    "Off, no flash function"
  when 0x41
    "Fired, red-eye reduction"
  when 0x45
    "Fired, red-eye reduction return not detected"
  when 0x47
    "Fired, red-eye reduction return detected"
  when 0x49
    "On, red-eye reduction"
  when 0x4d
    "On, red-eye reduction return not detected"
  when 0x4f
    "On, red-eye reduction return detected"
  when 0x50
    "Off, red-eye reduction"
  when 0x58
    "Auto, did not fire red-eye reduction"
  when 0x59
    "Auto, fired red-eye reduction"
  when 0x5d
    "Auto, fired red-eye reduction return not detected"
  when 0x5f
    "Auto, fired red-eye reduction return detected"
  end
}
