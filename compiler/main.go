package main

import (
	"fmt"
	"io/fs"
	"os"
)

const (
	INPUT_FILE  = "main.dino"
	OUTPUT_FILE = "dino.bin"
)

func main() {
	program, err := os.ReadFile(INPUT_FILE)
	if err != nil {
		panic(err)
	}

	c := NewCompiler()
	c.Load(program)
	c.Run()

	fmt.Printf("bytecode is %d bytes in size\n", len(c.bytecode))

	err = os.WriteFile(OUTPUT_FILE, c.Output(), fs.FileMode(os.O_RDWR))
	if err != nil {
		panic(err)
	}

	fmt.Printf("wrote bytecode to `%s`\n", OUTPUT_FILE)
}
