.equ LED_0, 0x2000
.equ LED_1, 0x2004
.equ LED_2, 0x2008

main:
    addi a0, zero, 10
    addi a1, zero, 5

    call function
	nop
	nop
	br end
	nop
	nop

function:
	nop 
	nop
    add  v0, a0, a1
	nop
	nop
    ret

end:
    stw a0, LED_0 (zero)
	nop
	nop
	nop
	nop
	nop
	nop
    stw a1, LED_1 (zero)
	nop
	nop
	nop
	nop
	nop
	nop
    stw v0, LED_2 (zero)
	nop
	nop
	nop
	nop
	nop
	nop



