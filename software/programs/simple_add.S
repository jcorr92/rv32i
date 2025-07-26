.globl _start
.section .text
_start:
  li x1, 5
  li x2, 7
  add x3, x1, x2   # x3 should be 12
loop:
  j loop
