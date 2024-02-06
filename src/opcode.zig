pub const Opcode = enum {
    HLT,
    NOP,
    DBG,

    ADD,
    ADDI,
    SUB,
    SUBI,
    MUL,
    MULI,
    DIV,
    DIVI,
    AND,
    ANDI,
    OR,
    ORI,
    XOR,
    XORI,
    INC,
    DEC,

    MOV,
    MOVR,

    PSH,
    PSHI,
    POP,

    CMP,
    CMPI,

    JMP,
    JEQ,
    JNE,
    JLT,
    JLE,
    JGT,
    JGE,

    CALL,
    RET,

    STR,
    LOD,

    INVALID,

    pub fn from_u8(v: u8) Opcode {
        return switch (v) {
            0x00 => .HLT,
            0x01 => .NOP,
            0x02 => .DBG,

            0x10 => .ADD,
            0x11 => .ADDI,
            0x12 => .SUB,
            0x13 => .SUBI,
            0x14 => .MUL,
            0x15 => .MULI,
            0x16 => .DIV,
            0x17 => .DIVI,
            0x18 => .AND,
            0x19 => .ANDI,
            0x20 => .OR,
            0x21 => .ORI,
            0x22 => .XOR,
            0x23 => .XORI,
            0x24 => .INC,
            0x25 => .DEC,

            0x30 => .MOV,
            0x31 => .MOVR,

            0x40 => .PSH,
            0x41 => .PSHI,
            0x42 => .POP,

            0x50 => .CMP,
            0x51 => .CMPI,

            0x60 => .JMP,
            0x61 => .JEQ,
            0x62 => .JNE,
            0x63 => .JLT,
            0x64 => .JLE,
            0x65 => .JGT,
            0x66 => .JGE,

            0x70 => .CALL,
            0x71 => .RET,

            0x80 => .STR,
            0x81 => .LOD,

            else => .INVALID,
        };
    }

    pub fn to_u8(self: @This()) u8 {
        return switch (self) {
            .HLT => 0x00,
            .NOP => 0x01,
            .DBG => 0x02,

            .ADD => 0x10,
            .ADDI => 0x11,
            .SUB => 0x12,
            .SUBI => 0x13,
            .MUL => 0x14,
            .MULI => 0x15,
            .DIV => 0x16,
            .DIVI => 0x17,
            .AND => 0x18,
            .ANDI => 0x19,
            .OR => 0x20,
            .ORI => 0x21,
            .XOR => 0x22,
            .XORI => 0x23,
            .INC => 0x24,
            .DEC => 0x25,

            .MOV => 0x30,
            .MOVR => 0x31,

            .PSH => 0x40,
            .PSHI => 0x41,
            .POP => 0x42,

            .CMP => 0x50,
            .CMPI => 0x51,

            .JMP => 0x60,
            .JEQ => 0x61,
            .JNE => 0x62,
            .JLT => 0x63,
            .JLE => 0x64,
            .JGT => 0x65,
            .JGE => 0x66,

            .CALL => 0x70,
            .RET => 0x71,

            .STR => 0x80,
            .LOD => 0x81,

            else => 0xFF,
        };
    }
};
