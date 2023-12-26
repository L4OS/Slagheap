; ������� ����� ����� �� �������� X-modem
;
; ����: 	R0 - ����� ������ �������� ������
; �����: 	R6 - ���������� �������� ������ ��� ������ ��������

function	_recive_file
	load			r6, 0xfffefff0	; ����� ����� ������� UART
	load			r7, 0x9		; ����� �������
	load			r10, 0x1	; ����� �����

send_NAK:
	load			r3, 0x15	; NAK-�����
wait_snd_ready:
	mov			r5, (r6)	; ������ ������� ����������
	rcr			R5, 1		; ��������� ��� BUSY � �������
	jc			wait_snd_ready	; ����� ���������� � �����
	inc			r6, 4		; ��������� �� ������� �������� ������
	mov			(r6), r3	; ����� �����
	dec			r6, 4		; ��������� �� ������� �������� ������
	load			r13, 0x00700000	; ����� �������� ������ � �������� �������

wait_start:
	dec			r13		; ���������� ������� ��������
	jnz			check_SOH	; ��������� ����
	dec			r7             	; ��������� ����� ��������
	jne			send_NAK 	; ��������� �������� NAK
;  debug
 ; set_mr			mr1, r3
	return					; ������� �� ������
	
check_SOH:
	mov			r5, (r6)	; ������ ������� ����������
	rcr			r5, 2		; ��� RCV_RDY � �������
	jnc			wait_start	; ��� ������

start_recv:
	inc			r6, 4		; ��������� �� ������� �������� ������
	mov			r3, (r6)	; ���� �����
	dec			r6, 4		; ��������� �� ������� �������� ������

	load			r2, 0x01	; SOH-���������
	cmp			r2, r3		; 
	je			wait_block_id	;

	load			r2, 0x04	; EOT-����� ��������
	cmp			r2, r3		; 
	jne			wait_start	;

; �������� ������ ���������
confirm_transmission:
	mov			r5, (r6)		; ������ ������� ����������
	rcr			R5, 1			; ��������� ��� BUSY � �������
	jc			confirm_transmission	; ����� ���������� � �����
	inc			r6, 4			; ��������� �� ������� �������� ������
	load			r3, 0x06		; ACK-�����
	mov			(r6), r3		; ����� �����
	dec			r6, 4			; ��������� �� ������� �������� ������

	dec			r10, 1			; ���� ���������� � �������, ������ ���
	shl			r10, 7			; �������� ����� ������ �� 128
	mov			r6, r10
	return

wait_block_id:
	mov			r5, (r6)	; ������ ������� ����������
	rcr			r5, 2		; ��� RCV_RDY � �������
	jc			read_block_id	; ���� ������
	dec			r13		; ���������� ������� ��������
	jnz			wait_block_id	; ��������� ����
	dec			r6, 1           ;; ������ = ����� �������� ������� UART - 1
	return					; ������� �� ������


read_block_id:
	inc			r6, 4		; ��������� �� ������� �������� ������
	mov			r1, (r6)	; ���� �����
	dec			r6, 4		; ��������� �� ������� �������� ������
	
wait_block_inv:
	mov			r5, (r6)	; ������ ������� ����������
	rcr			r5, 2		; ��� RCV_RDY � �������
	jc			read_block_inv	; ��������� ����� ����� ������
	dec			r13		; ���������� ������� ��������
	jnz			wait_block_inv	; ��������� ����
	dec			r6, 2           ;; ������ = ����� �������� ������� UART - 2
	return					; ������� �� ������

read_block_inv:
	inc			r6, 4		; ��������� �� ������� �������� ������
	mov			r2, (r6)	; ���� �����
	dec			r6, 4		; ��������� �� ������� �������� ������

	not			r2
	load			r4, 0xff
	and			r2, r4
	cmp			r2, r1
	je			compare_block_id
	dec			r6, 3           ;; ������ = ����� �������� ������� UART - 3
	return					; ������� �� ������

compare_block_id:
	cmp			r1, r10			; �������� ������ ������
	je			read_data_block
	jc			re_read_data_block	; ��������� ����
	dec			r6, 4           	;; ������ = ����� �������� ������� UART - 4

;  debug
;  nop
;  nop
;  nop
;  nop
;  set_mr			mr1, r1
;  set_mr			mr1, r2
;  set_mr			mr2, r10

	return					; ������� �� ������

re_read_data_block:
	load			r2, 0x80
	clc
	subc			r0, r2
	dec			r10, 1

read_data_block:
	load			r12, 0x00	; ����������� �����
	load			r11, 0x80	; ���������� ����������� ����
	load			r13, 0x00500000	; ����� �������� ������ � �������� �������

read_word:
	load			r8, 0		; � ���� �������� ����������� ���������
	load			r9, 4		; ���������� ���� � �����

wait_data:
	mov			r5, (r6)	; ������ ������� ����������
	rcr			r5, 2		; ��� RCV_RDY � �������
	jc			data_ready	; ��������� ����� ����� ������
	dec			r13		; ���������� ������� ��������
	jnz			wait_data	; ��������� ����
	dec			r6, 5           ;; ������ = ����� �������� ������� UART - 5
	return					; ������� �� ������
	
data_ready:
	inc			r6, 4		; ��������� �� ������� �������� ������
	mov			r2, (r6)	; ���� �����
	dec			r6, 4		; ��������� �� ������� �������� ������
	
	clc
	addc			r12, r2
	rol			r8, 8		; �������� ������� �� 8 ���
	or			r8, r2		; ������� � �������� ������
	
	dec			r9, 1		; ��������� �����
	jne			wait_data

	mov			(r0), r8	; ��������� 4 �����
	inc			r0, 4		; � ���������� �����
	dec			r11, 4
	jne			read_word	

; �������� ����������� �����
	load			r2, 0xff
	and			r12, r2

; ������ ����������� �����
wait_checksum:
	mov			r5, (r6)	; ������ ������� ����������
	rcr			r5, 2		; ��� RCV_RDY � �������
	jc			checksum_ready	; ����������� ����� ���
	dec			r13		; ���������� ������� ��������
	jnz			wait_checksum	; ��������� ����
	dec			r6, 5           ;; ������ = ����� �������� ������� UART - 5
	return					; ������� �� ������
	
checksum_ready:
	inc			r6, 4		; ��������� �� ������� �������� ������
	mov			r2, (r6)	; ���� �����
	dec			r6, 4		; ��������� �� ������� �������� ������

;  debug
;  nop
;  nop
;  nop
;  nop
;  set_mr			mr1, r12
;  set_mr			mr2, r2
;  set_mr			mr3, r13


	cmp			r2, r12		; ��������� ���������� ����
	je			prepare_next_block
	dec			r6, 6           ;; ������ = ����� �������� ������� UART - 6
	return					; ������� �� ������

prepare_next_block:
	inc			r10, 1

;;	load			r2, 0xff	; ������ ������ ������������!!! 
;;	and			r10, r2		; ���� ���������������� ����� ��������� ����� 32 �� !!!!

wait_snd_ack:
	mov			r5, (r6)	; ������ ������� ����������
	rcr			R5, 1		; ��������� ��� BUSY � �������
	jc			wait_snd_ack	; ����� ���������� � �����

	inc			r6, 4		; ��������� �� ������� �������� ������
	load			r3, 0x06	; ACK-�����
	mov			(r6), r3	; ����� �����
	dec			r6, 4		; ��������� �� ������� �������� ������

wait_ack_sent:
	mov			r5, (r6)	; ������ ������� ����������
	rcr			R5, 1		; ��������� ��� BUSY � �������
	jc			wait_ack_sent	; ����� ���������� � �����

wait_data_recv:
	mov			r5, (r6)	; ������ ������� ����������
	rcr			r5, 2		; ��� RCV_RDY � �������
	jnc			wait_data_recv	; ��� ������

	load			r13, 0x00500000	; ����� �������� ������ � �������� �������
	jmp			start_recv

end

