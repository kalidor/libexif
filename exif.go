package main

import (
    "fmt"
    //"io/ioutil"
	"os" // file open
	"encoding/binary"
)
func check(e error) {
    if e != nil {
        panic(e)
    }
}

func unpackBlock(block []byte) int64{
	fmt.Printf("0x%x => %d [binary.BigEndian]\n",block, binary.BigEndian.Uint16(block[0:]))
	fmt.Printf("0x%x => %d [binary.BigEndian]\n",block, binary.BigEndian.Uint16(block[2:]))
	fmt.Printf("0x%x => %d [binary.BigEndian]\n",block, binary.BigEndian.Uint32(block[4:]))
	offset := int64(binary.BigEndian.Uint32(block[4:]))
	return offset
}

func main() {
	var filename = "tests/lena_std.tiff"
    //dat, err := ioutil.ReadFile(filename)
    //check(err)
    //fmt.Print(string(dat))
	fmt.Print("============\n")
    f, err := os.Open(filename)
	check(err)
	th := make([]byte, 8)
	_, erro := f.Read(th)
	check(erro) 
	var offset = unpackBlock(th)
	fmt.Printf("[+] Seeking to %d\n", offset)
	f.Seek(offset, 0)
	th = make([]byte, 2)
	_, erro = f.Read(th)
	check(erro) 
	fmt.Printf("0x%x => %d [binary.BigEndian]\n",th, binary.BigEndian.Uint16(th[0:]))
	f.Close()
}