# stash
Selection of some interesting examples for the Everest processor

Assembly generated listing

<code>
; ------------------- _init_debug ------------------
0000:   01              ; DEBUG                   debug
0001:   9e 20 00        ; LOAD 	R14, 0x2000       	load r14, 0x2000
0004:   e0 ff ff ff ff  ; LOAD 	R0, 0xffffffff    	load r0, 0xffffffff
0009:   52 0a           ; LOAD 	R2, 0x0a          	load r2, 10	                   	
000b:   04              ; NOTCH                   	call	_div
000c:   8f 00 08        ; JMP 	0x0014             
000f:   01              ; DEBUG                   debug
0010:   04              ; NOTCH                   	call	_getchar
0011:   8f 00 87        ; JMP 	0x0098             
0014: 	""
</code>
