const std = @import("std");
const Opcode = @import("opcode.zig").Opcode;

pub const REGISTER_CAPACITY: usize = 16;
pub const STACK_CAPACITY: usize = 4096;
pub const MEMORY_CAPACITY: usize = 4096;
pub const PROGRAM_CAPACITY: usize = 4096;

pub const Flags = struct {
    eq: bool,
    gt: bool,
};

pub const VM = struct {
    const Self = @This();

    ip: usize = 0,
    sp: usize = 0,

    registers: [REGISTER_CAPACITY]u16,
    stack: [STACK_CAPACITY]u16,
    memory: [MEMORY_CAPACITY]u16,
    program: [PROGRAM_CAPACITY]u8,
    flags: Flags,

    pub fn init() !Self {
        var registers = std.mem.zeroes([REGISTER_CAPACITY]u16);
        var stack = std.mem.zeroes([STACK_CAPACITY]u16);
        var memory = std.mem.zeroes([MEMORY_CAPACITY]u16);
        var program = std.mem.zeroes([PROGRAM_CAPACITY]u8);

        return Self{
            .registers = registers,
            .stack = stack,
            .memory = memory,
            .program = program,
            .flags = .{ .eq = false, .gt = false },
        };
    }

    fn read_number(self: *Self) u16 {
        var l: u16 = @as(u16, @intCast(self.program[self.ip]));
        self.ip += 1;
        var h: u16 = @as(u16, @intCast(self.program[self.ip]));
        self.ip += 1;

        var value: u16 = l + h * 256;
        return value;
    }

    pub fn run(self: *Self) !void {
        var running = true;
        while (running) {
            var op = Opcode.from_u8(self.program[self.ip]);

            // std.debug.print("registers: {any}\n", .{self.registers});
            // std.debug.print("stack:     {any}\n", .{self.stack});
            // std.debug.print("memory:    {any}\n", .{self.memory});
            // std.debug.print("flags:     {any}\n", .{self.flags});
            // std.debug.print("ip:        {}\n", .{self.ip});
            // std.debug.print("sp:        {}\n", .{self.sp});
            // std.debug.print("opcode:    {}\n\n", .{op});

            switch (op) {
                .HLT => running = false,
                .NOP => self.ip += 1,
                .DBG => {
                    var reg = self.program[self.ip + 1];
                    if (reg == 0xA0) {
                        std.debug.print("{}\n", .{self.ip});
                    } else if (reg == 0xA1) {
                        std.debug.print("{}\n", .{self.sp});
                    } else {
                        std.debug.print("{}\n", .{self.registers[reg]});
                    }
                    self.ip += 2;
                },
                .ADD => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var src2 = self.program[self.ip];
                    self.ip += 1;

                    self.registers[dest] = self.registers[src1] + self.registers[src2];
                },
                .ADDI => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var value = self.read_number();

                    self.registers[dest] = self.registers[src1] + value;
                },
                .SUB => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var src2 = self.program[self.ip];
                    self.ip += 1;

                    self.registers[dest] = self.registers[src1] - self.registers[src2];
                },
                .SUBI => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var value = self.read_number();

                    self.registers[dest] = self.registers[src1] - value;
                },
                .MUL => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var src2 = self.program[self.ip];
                    self.ip += 1;

                    self.registers[dest] = self.registers[src1] * self.registers[src2];
                },
                .MULI => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var value = self.read_number();

                    self.registers[dest] = self.registers[src1] * value;
                },
                .DIV => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var src2 = self.program[self.ip];
                    self.ip += 1;

                    self.registers[dest] = self.registers[src1] / self.registers[src2];
                },
                .DIVI => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var value = self.read_number();

                    self.registers[dest] = self.registers[src1] / value;
                },
                .AND => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var src2 = self.program[self.ip];
                    self.ip += 1;

                    self.registers[dest] = self.registers[src1] & self.registers[src2];
                },
                .ANDI => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var value = self.read_number();

                    self.registers[dest] = self.registers[src1] & value;
                },
                .OR => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var src2 = self.program[self.ip];
                    self.ip += 1;

                    self.registers[dest] = self.registers[src1] | self.registers[src2];
                },
                .ORI => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var value = self.read_number();

                    self.registers[dest] = self.registers[src1] | value;
                },
                .XOR => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var src2 = self.program[self.ip];
                    self.ip += 1;

                    self.registers[dest] = self.registers[src1] ^ self.registers[src2];
                },
                .XORI => {
                    self.ip += 1;
                    var dest = self.program[self.ip];
                    self.ip += 1;
                    var src1 = self.program[self.ip];
                    self.ip += 1;
                    var value = self.read_number();

                    self.registers[dest] = self.registers[src1] ^ value;
                },
                .INC => {
                    self.ip += 1;
                    var register = self.program[self.ip];
                    self.ip += 1;

                    self.registers[register] += 1;
                },
                .DEC => {
                    self.ip += 1;
                    var register = self.program[self.ip];
                    self.ip += 1;

                    self.registers[register] -= 1;
                },
                .MOV => {
                    self.ip += 1;
                    var register = self.program[self.ip];
                    self.ip += 1;
                    var value = self.read_number();

                    self.registers[register] = value;
                },
                .MOVR => {
                    self.ip += 1;
                    var register1 = self.program[self.ip];
                    self.ip += 1;
                    var register2 = self.program[self.ip];
                    self.ip += 1;

                    self.registers[register1] = self.registers[register2];
                },
                .PSH => {
                    self.ip += 1;
                    var register = self.program[self.ip];
                    self.ip += 1;

                    self.stack[self.sp] = self.registers[register];
                    self.sp += 1;
                },
                .PSHI => {
                    var value = self.read_number();

                    self.stack[self.sp] = value;
                    self.sp += 1;
                },
                .POP => {
                    self.sp -= 1;
                    self.registers[self.program[self.ip + 1]] = self.stack[self.sp];
                    self.ip += 2;
                },
                .CMP => {
                    self.ip += 1;
                    var reg1 = self.program[self.ip];
                    self.ip += 1;
                    var reg2 = self.program[self.ip];
                    self.ip += 1;

                    self.flags.eq = self.registers[reg1] == self.registers[reg2];
                    self.flags.gt = self.registers[reg1] > self.registers[reg2];
                },
                .CMPI => {
                    self.ip += 1;
                    var reg = self.program[self.ip];
                    self.ip += 1;
                    var imm = self.read_number();

                    self.flags.eq = self.registers[reg] == imm;
                    self.flags.gt = self.registers[reg] > imm;
                },
                .JMP => {
                    self.ip += 1;
                    var addr = self.read_number();
                    self.ip = @as(usize, @intCast(addr));
                },
                .JEQ => {
                    self.ip += 1;
                    var addr = self.read_number();

                    if (self.flags.eq) {
                        self.ip = @as(usize, @intCast(addr));
                    }
                },
                .JNE => {
                    self.ip += 1;
                    var addr = self.read_number();

                    if (!self.flags.eq) {
                        self.ip = @as(usize, @intCast(addr));
                    }
                },
                .JLT => {
                    self.ip += 1;
                    var addr = self.read_number();

                    if (!self.flags.gt) {
                        self.ip = @as(usize, @intCast(addr));
                    }
                },
                .JLE => {
                    self.ip += 1;
                    var addr = self.read_number();

                    if (!self.flags.gt or self.flags.eq) {
                        self.ip = @as(usize, @intCast(addr));
                    }
                },
                .JGT => {
                    self.ip += 1;
                    var addr = self.read_number();

                    if (self.flags.gt) {
                        self.ip = @as(usize, @intCast(addr));
                    }
                },
                .JGE => {
                    self.ip += 1;
                    var addr = self.read_number();

                    if (self.flags.gt or self.flags.eq) {
                        self.ip = @as(usize, @intCast(addr));
                    }
                },
                .CALL => {
                    self.ip += 1;
                    var addr = self.read_number();

                    self.stack[self.sp] = @as(u16, @intCast(self.ip));
                    self.sp += 1;
                    self.ip = @as(usize, @intCast(addr));
                },
                .RET => {
                    self.sp -= 1;
                    var addr = self.stack[self.sp];
                    self.ip = addr;
                },
                .STR => {
                    self.ip += 1;
                    var addr = self.read_number();
                    var imm = self.read_number();

                    self.memory[addr] = imm;
                },
                .LOD => {
                    self.ip += 1;
                    var reg = self.program[self.ip];
                    self.ip += 1;
                    var addr = self.read_number();

                    self.registers[reg] = self.memory[addr];
                },
                else => {
                    std.debug.print("invalid instruction `{}`\n", .{self.program[self.ip]});
                    return;
                },
            }
        }
    }

    pub fn load(self: *Self, program: []u8) void {
        var idx: usize = 0;
        for (program) |instruction| {
            self.program[idx] = instruction;
            idx += 1;
        }
    }
};
