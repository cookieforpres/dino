package main

import (
	"strconv"
	"strings"
)

type Compiler struct {
	program  string
	bytecode []byte
	labels   map[string]int
	fixups   map[int]string
	parts    []string
}

func NewCompiler() *Compiler {
	return &Compiler{
		program:  "",
		bytecode: []byte{},
		labels:   make(map[string]int),
		fixups:   make(map[int]string),
		parts:    []string{},
	}
}

func (c *Compiler) Load(program []byte) {
	c.program = string(program)
}

func (c *Compiler) Output() []byte {
	return c.bytecode
}

func (c *Compiler) Run() {
	lines := strings.Split(strings.TrimSpace(c.program), "\n")

	for _, line := range lines {
		line = strings.TrimSpace(strings.Split(line, ";")[0])
		line = strings.TrimSpace(strings.ReplaceAll(line, ",", ""))
		if line == "" {
			continue
		}

		c.parts = strings.Split(line, " ")
		instruction := c.parts[0]

		if strings.HasSuffix(instruction, ":") {
			label := strings.ReplaceAll(instruction, ":", "")
			c.labels[label] = len(c.bytecode)
			continue
		}

		switch instruction {
		case "hlt":
			c.haltOp()
		case "nop":
			c.nopOp()
		case "dbg":
			c.dbgOp()
		case "add":
			c.binaryRrOp(ADD_OP)
		case "addi":
			c.binaryRiOp(ADDI_OP)
		case "sub":
			c.binaryRrOp(SUB_OP)
		case "subi":
			c.binaryRiOp(SUBI_OP)
		case "mul":
			c.binaryRrOp(MUL_OP)
		case "muli":
			c.binaryRiOp(MULI_OP)
		case "div":
			c.binaryRrOp(DIV_OP)
		case "divi":
			c.binaryRiOp(DIVI_OP)
		case "and":
			c.binaryRrOp(AND_OP)
		case "andi":
			c.binaryRiOp(ANDI_OP)
		case "or":
			c.binaryRrOp(OR_OP)
		case "ori":
			c.binaryRiOp(ORI_OP)
		case "xor":
			c.binaryRrOp(XOR_OP)
		case "xori":
			c.binaryRiOp(XORI_OP)
		case "inc":
			c.incOp()
		case "dec":
			c.decOp()
		case "mov":
			c.movOp()
		case "movr":
			c.movrOp()
		case "psh":
			c.pshOp()
		case "pshi":
			c.pshiOp()
		case "pop":
			c.popOp()
		case "cmp":
			c.cmpOp()
		case "cmpi":
			c.cmpiOp()
		case "jmp":
			c.jumpOp(JMP_OP)
		case "jeq":
			c.jumpOp(JEQ_OP)
		case "jne":
			c.jumpOp(JNE_OP)
		case "jlt":
			c.jumpOp(JLT_OP)
		case "jle":
			c.jumpOp(JLE_OP)
		case "jgt":
			c.jumpOp(JGT_OP)
		case "jge":
			c.jumpOp(JGE_OP)
		case "call":
			c.callOp()
		case "ret":
			c.retOp()
		case "str":
			c.strOp()
		case "lod":
			c.lodOp()
		}
	}

	for addr, name := range c.fixups {
		if _, ok := c.labels[name]; ok {
			value := c.labels[name]

			len1 := value % 256
			len2 := (value - len1) / 256

			c.bytecode[addr+1] = byte(len1)
			c.bytecode[addr+2] = byte(len2)
		}
	}
}

func registerToInt(ident string) int {
	var result int
	if strings.HasPrefix(ident, "x") {
		i, err := strconv.Atoi(strings.ReplaceAll(ident, "x", ""))
		if err != nil {
			panic(err)
		}
		result = i
	} else if ident == "ip" {
		result = 0xA0
	} else if ident == "sp" {
		result = 0xA1
	} else {
		i, err := strconv.Atoi(ident)
		if err != nil {
			panic(err)
		}
		result = i
	}

	return result
}

func toU16Bytes(v int) []byte {
	len1 := v % 256
	len2 := (v - len1) / 256

	return []byte{byte(len1), byte(len2)}
}

func intToString(v string) int {
	i, _ := strconv.Atoi(v)
	return i
}

func (c *Compiler) haltOp() {
	c.bytecode = append(c.bytecode, HLT_OP)
}

func (c *Compiler) nopOp() {
	c.bytecode = append(c.bytecode, NOP_OP)
}

func (c *Compiler) dbgOp() {
	reg := registerToInt(c.parts[1])

	c.bytecode = append(c.bytecode, DBG_OP)
	c.bytecode = append(c.bytecode, byte(reg))
}

func (c *Compiler) binaryRrOp(op byte) {
	dest := registerToInt(c.parts[1])
	src1 := registerToInt(c.parts[2])
	src2 := registerToInt(c.parts[3])

	c.bytecode = append(c.bytecode, op)
	c.bytecode = append(c.bytecode, byte(dest))
	c.bytecode = append(c.bytecode, byte(src1))
	c.bytecode = append(c.bytecode, byte(src2))
}

func (c *Compiler) binaryRiOp(op byte) {
	dest := registerToInt(c.parts[1])
	reg := registerToInt(c.parts[2])
	imm := toU16Bytes(intToString(c.parts[3]))

	c.bytecode = append(c.bytecode, op)
	c.bytecode = append(c.bytecode, byte(dest))
	c.bytecode = append(c.bytecode, byte(reg))
	c.bytecode = append(c.bytecode, imm...)
}

func (c *Compiler) incOp() {
	reg := registerToInt(c.parts[1])

	c.bytecode = append(c.bytecode, INC_OP)
	c.bytecode = append(c.bytecode, byte(reg))
}

func (c *Compiler) decOp() {
	reg := registerToInt(c.parts[1])

	c.bytecode = append(c.bytecode, DEC_OP)
	c.bytecode = append(c.bytecode, byte(reg))
}

func (c *Compiler) movOp() {
	dest := registerToInt(c.parts[1])
	src := intToString(c.parts[2])

	len1 := src % 256
	len2 := (src - len1) / 256

	c.bytecode = append(c.bytecode, MOV_OP)
	c.bytecode = append(c.bytecode, byte(dest))
	c.bytecode = append(c.bytecode, byte(len1))
	c.bytecode = append(c.bytecode, byte(len2))
}

func (c *Compiler) movrOp() {
	dest := registerToInt(c.parts[1])
	src := registerToInt(c.parts[2])

	c.bytecode = append(c.bytecode, MOVR_OP)
	c.bytecode = append(c.bytecode, byte(dest))
	c.bytecode = append(c.bytecode, byte(src))
}

func (c *Compiler) pshOp() {
	reg := registerToInt(c.parts[1])

	c.bytecode = append(c.bytecode, PSH_OP)
	c.bytecode = append(c.bytecode, byte(reg))
}

func (c *Compiler) pshiOp() {
	imm := toU16Bytes(intToString(c.parts[1]))

	c.bytecode = append(c.bytecode, PSHI_OP)
	c.bytecode = append(c.bytecode, imm...)
}

func (c *Compiler) popOp() {
	reg := registerToInt(c.parts[1])

	c.bytecode = append(c.bytecode, POP_OP)
	c.bytecode = append(c.bytecode, byte(reg))
}

func (c *Compiler) cmpOp() {
	reg1 := registerToInt(c.parts[1])
	reg2 := registerToInt(c.parts[2])

	c.bytecode = append(c.bytecode, CMP_OP)
	c.bytecode = append(c.bytecode, byte(reg1))
	c.bytecode = append(c.bytecode, byte(reg2))
}

func (c *Compiler) cmpiOp() {
	reg := registerToInt(c.parts[1])
	imm := toU16Bytes(intToString(c.parts[2]))

	c.bytecode = append(c.bytecode, CMPI_OP)
	c.bytecode = append(c.bytecode, byte(reg))
	c.bytecode = append(c.bytecode, imm...)
}

func (c *Compiler) jumpOp(op byte) {
	i, err := strconv.Atoi(c.parts[1])
	if err != nil {
		label := c.parts[1]

		c.fixups[len(c.bytecode)] = label

		c.bytecode = append(c.bytecode, op)
		c.bytecode = append(c.bytecode, 0x00)
		c.bytecode = append(c.bytecode, 0x00)
		return
	}

	addr := toU16Bytes(i)

	c.bytecode = append(c.bytecode, op)
	c.bytecode = append(c.bytecode, addr...)
}

func (c *Compiler) callOp() {
	i, err := strconv.Atoi(c.parts[1])
	if err != nil {
		label := c.parts[1]

		c.fixups[len(c.bytecode)] = label

		c.bytecode = append(c.bytecode, CALL_OP)
		c.bytecode = append(c.bytecode, 0x00)
		c.bytecode = append(c.bytecode, 0x00)
		return
	}

	addr := toU16Bytes(i)

	c.bytecode = append(c.bytecode, CALL_OP)
	c.bytecode = append(c.bytecode, addr...)
}

func (c *Compiler) retOp() {
	c.bytecode = append(c.bytecode, RET_OP)
}

func (c *Compiler) strOp() {
	var addr = toU16Bytes(intToString(c.parts[1]))
	var imm = toU16Bytes(intToString(c.parts[2]))

	c.bytecode = append(c.bytecode, STR_OP)
	c.bytecode = append(c.bytecode, addr...)
	c.bytecode = append(c.bytecode, imm...)
}

func (c *Compiler) lodOp() {
	reg := registerToInt(c.parts[1])
	addr := toU16Bytes(intToString(c.parts[2]))

	c.bytecode = append(c.bytecode, LOD_OP)
	c.bytecode = append(c.bytecode, byte(reg))
	c.bytecode = append(c.bytecode, addr...)
}
