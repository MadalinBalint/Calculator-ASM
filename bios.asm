; Fisier pentru lucrul cu BIOS

; Constante pt culori
black      equ 00h
blue       equ 01h
green      equ 02h
cyan       equ 03h
red        equ 04h
magenta    equ 05h
brown      equ 06h
white      equ 07h
gray       equ 08h
br_blue    equ 09h
br_green   equ 0ah
br_cyan    equ 0bh
br_red     equ 0ch
br_magenta equ 0dh
yellow     equ 0eh
br_white   equ 0fh

; Constante pt tastatura folosind functiile DOS
; Corespund cu valorile din tabelul ASCII
kbd_0         equ 30h
kbd_1         equ 31h
kbd_2         equ 32h 
kbd_3         equ 33h
kbd_4         equ 34h
kbd_5         equ 35h
kbd_6         equ 36h
kbd_7         equ 37h
kbd_8         equ 38h
kbd_9         equ 39h

kbd_minus     equ 2dh
kbd_plus      equ 2bh
kbd_inmultire equ 2ah
kbd_impartire equ 2fh
kbd_punct     equ 2eh ; pune semn pt nr reale
kbd_egal      equ 2dh ; efectueaza operatia

kbd_esc       equ 1bh ; iese din program
kbd_spacebar  equ 20h ; schimba semnul numarului
kbd_backspace equ 08h ; sterge o cifra
kbd_enter     equ 0dh ; efectueaza operatia

kbd_c_mic     equ 63h ; sterge ecranul calculatorului
kbd_c_mare    equ 43h ;
kbd_r_mic     equ 72h ; operatia Radical
kbd_r_mare    equ 52h ;
kbd_p_mic     equ 70h ; numarul Pi
kbd_p_mare    equ 50h ;
kbd_i_mic     equ 69h ; 1/x - Inversul lui x
kbd_i_mare    equ 49h ;
kbd_s_mic     equ 73h ; x^2 - patratul lui x (Square)
kbd_s_mare    equ 53h ;
kbd_b_mic     equ 62h ; x^3 - cubul lui x (cuBe)
kbd_b_mare    equ 42h ;

bios_write macro char, bg_color, fg_color, count
    mov ah, 09h
	mov al, char
	mov bh, 00h
	mov bl, bg_color * 16 + fg_color
    mov cx, count
	int 10h
endm

bios_cls macro
	mov ax, 0600h
	mov bh, 17h
	mov dx,0
	mov cx, 24 * 256 + 79
	int 10h
endm

textmode80x25 macro
	mov ax, 0003h
	int 10h
endm

bios_data macro
	mov ah, 0fh
	int 10h
endm

start_video macro
	push ax
	push es
	mov ax, 0b800h
	mov es, ax
endm

end_video macro
	pop es
	pop ax
endm

; Doar constante
cls macro bg_color, fg_color
	xor di, di 	; clear di, ES:DI points to video memory
	mov ax, bg_color * 4096 + fg_color * 256
	mov cx, 4000 	; amount of times to put it there 
	cld 		; direction - forwards
	rep stosw 	; output character at ES:[DI]
endm

; Doar constante
cls_region macro x1, y1, x2, y2, bg_color, fg_color, char
	local @@again
	mov bx, y1
@@again:    
	mov ax, 80
	mul bx
	add ax, x1
	shl ax, 1
	mov di, ax	;mov di, (y1 * 80 + x1) * 2; clear di, ES:DI points to video memory
	mov ax, bg_color * 4096 + fg_color * 256 + char
	mov cx, (x2 - x1 + 1)
	cld 		; direction - forwards
	rep stosw 	; output character at ES:[DI]
	inc bx
	cmp bx, y2
	jng @@again
endm

; [ES:DI] = [ES:(y * 80 + x) * 2]
bios_putc macro x, y, char
	mov bx, y
	mov ax, 80
	mul bx
	add ax, x
	shl ax, 1
	mov di, ax	
	mov al, char
	stosb
endm

; [ES:DI] = [ES:(y * 80 + x) * 2]
bios_putc_color macro x, y, char, bg_color, fg_color
	mov bx, y
	mov ax, 80
	mul bx
	add ax, x
	shl ax, 1
	mov di, ax	
	mov ax, bg_color * 4096 + fg_color * 256 + char
	stosw
endm

; o linie orizontala din caracterul 'char'
bios_hputc_color macro x, y, char, bg_color, fg_color, count
	mov bx, y
	mov ax, 80
	mul bx
	add ax, x
	shl ax, 1
	mov di, ax	
	mov ax, bg_color * 4096 + fg_color * 256 + char
	mov cx, count
	cld 		
	rep stosw
endm

; o linie verticala din caracterul 'char'
bios_vputc_color macro x, y, char, bg_color, fg_color, count
	local @@again
	mov bx, y
@@again:
	mov ax, 80
	mul bx
	add ax, x
	shl ax, 1
	mov di, ax	
	mov ax, bg_color * 4096 + fg_color * 256 + char
	stosw
	inc bx
	cmp bx, y+count-1
	jng @@again
endm

; Scriem un sir la pozitia x, y
bios_puts macro x, y, sir, bg_color, fg_color, count
	local @@again, @@finish
    lea si, sir
	mov bx, y
	mov ax, 80
	mul bx
	add ax, x
	shl ax, 1
	mov di, ax
	mov ah, bg_color * 16 + fg_color
	mov cx, count
	cld
@@again:
	cmp cx, 0
	je @@finish
	lodsb
	stosw	
	dec cx	
	jmp @@again
@@finish:	
endm

gotoxy macro x, y
	mov ah, 02h
	mov bh, 0
	mov dh, y
	mov dl, x
    int 10h	
endm