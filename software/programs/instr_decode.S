.globl _start
.section .text
_start:
    li x1, 10
    li x2, 20

    add x3, x1, x2
    sub x4, x2, x1

    sw x5, 0(x3)
    lw x6, 0(x5)

    jalr x7, 0(x1)

loop:
    j loop
