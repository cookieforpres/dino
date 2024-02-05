    jmp _start              ; jump to the start of the program

fact:
    mov x0, 1               ; initialize x0 to 1
    movr x1, x2             ; move value of x2 to x1
fact_loop:
    mul x0, x0, x1          ; multiply x0 by x1 and store result in x0
    dec x1                  ; decrement x1
    cmpi x1, 0              ; compare x1 to 0
    jne fact_loop           ; if not equal to 0, jump back to fact_loop
    dbg x0                  ; output current value of x0 (for debugging)
    ret                     ; return from the function

_start:
    mov x2, 8               ; initialize x2 to 5
    call fact               ; call the factorial function
    hlt                     ; halt the program
