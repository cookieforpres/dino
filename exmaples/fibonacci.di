    jmp _start             ; jump to the start of the program

fib:
    mov x0, 0              ; initialize x0 to 0
    mov x1, 1              ; initialize x1 to 1
    dbg x1                 ; output initial value of x1 (for debugging)
fib_loop:
    add x0, x0, x1         ; add x1 to x0 and store result in x0
    movr x2, x0            ; move value of x0 to x2 (for temporary storage)
    movr x0, x1            ; move value of x1 to x0
    movr x1, x2            ; move value of x2 (stored earlier) to x1
    dbg x2                 ; output current value of x2 (for debugging)
    dec x3                 ; decrement loop counter (x3)
    cmpi x3, 0             ; compare loop counter to 0
    jne fib_loop           ; if not equal to 0 jump back to fib_loop
    ret                    ; return from the function

_start:
    mov x3, 23             ; initialize loop counter (x3) to 23
    call fib               ; call the fibonacci function
    hlt                    ; halt the program
