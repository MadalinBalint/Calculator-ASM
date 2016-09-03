; Calculator asemanator cu cel din Windows

.286
.287
include io.h
include bios.asm
include string.h

; lungime maxima sir
max equ 21

.model large
.stack 256
.data
	newline db cr, lf, 0
	case db kbd_0, kbd_1, kbd_2, kbd_3, kbd_4, kbd_5, kbd_6
	     db kbd_7, kbd_8, kbd_9, kbd_minus, kbd_plus, kbd_inmultire
		 db kbd_impartire, kbd_punct, kbd_egal, kbd_enter
         db kbd_spacebar, kbd_backspace, kbd_c_mic, kbd_c_mare
		 db kbd_r_mic, kbd_r_mare, kbd_p_mic, kbd_p_mare
		 db kbd_i_mic, kbd_i_mare, kbd_s_mic, kbd_s_mare
		 db kbd_b_mic, kbd_b_mare
	cases dw $ - case
	casejmp dw et_0, et_1, et_2, et_3, et_4, et_5, et_6
	        dw et_7, et_8, et_9, et_minus, et_plus, et_inmultire
			dw et_impartire, et_punct, et_egal, et_enter
            dw et_spacebar, et_backspace
    		dw et_c_mic, et_c_mare, et_r_mic, et_r_mare
			dw et_p_mic, et_p_mare, et_i_mic, et_i_mare
			dw et_s_mic, et_s_mare, et_b_mic, et_b_mare
			
    ; maxim 16 cifre cu tot cu '.', fara '-'
	rezultat db (max+1) dup(0)
	temp db (max+1) dup(0)
	x dw ?
	
	len dw 0
	minus_zero db "-0", 0
	zero_punct db "0.", 0
	zero  db '0', 0
	unu   db '1', 0
	doi   db '2', 0
	trei  db '3', 0
	patru db '4', 0
	cinci db '5', 0
	sase  db '6', 0
	sapte db '7', 0
	opt   db '8', 0
	noua  db '9', 0
	punct db '.', 0
	minus db '-', 0
	are_punct db 0 ; variabila bool daca avem . in rezultat
	are_minus db 0 ; variabila bool daca avem - in rezultat
	zero_initial dw 0
	e_minus_zero dw 0
	numar dd ? ; variabila float pe 32 biti
	eroare_sqrt db "Introdu un nr + !", 0
	eroare_div0 db "Impartire la 0 !", 0
	eroare_nan  db "NAN-not a number", 0
	eroare_pinf db "+Infinit", 0
	eroare_minf db "-Infinit", 0
	eroare_gol  db "ST(0) gol", 0
	eroare_dp   db "Denormalizat +", 0
	eroare_dn   db "Denormalizat -", 0
	
	nr1 dd ?
	nr2 dd ?
	op  db 0
	round dd 0.0000005 ; Pt rotunjire
	clear db 0

	minim  dd 0.000001
	status dw 0
.code
start:
    ; Initializam segmentele pt date si pt acces memorie text
	init_ds_es
	finit
	
	; Intram in modul text 80x25
	textmode80x25
	
	start_video
	
	; Stergem tot ecranul
	cls br_red, white 
	
	; Fundalul calculatorului
	cls_region 28, 1, 54, 23, br_white, black, 176
	
	; Fundalul unde se afiseaza rezultatul calculelor
	cls_region 30, 3, 52, 5, white, black, 0
	
	; < Randul 1 de operatori >
	; Cifra 7
	cls_region 30, 7, 32, 9, br_cyan, black, 0	
	
	; Cifra 8
	cls_region 34, 7, 36, 9, br_cyan, black, 0
	
	; Cifra 9
	cls_region 38, 7, 40, 9, br_cyan, black, 0
	
	; Impartire
	cls_region 42, 7, 44, 9, br_cyan, black, 0
	
	; Numarul pi
	cls_region 46, 7, 48, 9, br_cyan, black, 0
	
	; Clear
	cls_region 50, 7, 52, 9, yellow, black, 0
	
	; < Randul 2 de operatori >
	; Cifra 4
	cls_region 30, 11, 32, 13, br_cyan, black, 0
	
	; Cifra 5
	cls_region 34, 11, 36, 13, br_cyan, black, 0
	
	; Cifra 6
	cls_region 38, 11, 40, 13, br_cyan, black, 0
	
	; Inmultire
	cls_region 42, 11, 44, 13, br_cyan, black, 0
	
	; 1/x - inversul lui x
	cls_region 46, 11, 48, 13, br_cyan, black, 0
	
	; Stergere cifra
	cls_region 50, 11, 52, 13, yellow, black, 0
	
	; < Randul 3 de operatori >
	; Cifra 1
	cls_region 30, 15, 32, 17, br_cyan, black, 0
	
	; Cifra 2
	cls_region 34, 15, 36, 17, br_cyan, black, 0
	
	; Cifra 3
	cls_region 38, 15, 40, 17, br_cyan, black, 0
	
	; Scadere
	cls_region 42, 15, 44, 17, br_cyan, black, 0
	
	; x^2 = patratul lui x
	cls_region 46, 15, 48, 17, br_cyan, black, 0
	
	; Radacina patrata
	cls_region 50, 15, 52, 17, br_cyan, black, 0
	
	; < Randul 4 de operatori >
	; Cifra 0
	cls_region 30, 19, 32, 21, br_cyan, black, 0
	
	; .
	cls_region 34, 19, 36, 21, br_cyan, black, 0
	
	; +/-
	cls_region 38, 19, 40, 21, br_cyan, black, 0
	
	; Adunare
	cls_region 42, 19, 44, 21, br_cyan, black, 0
	
	; x^3 = cubul lui x
	cls_region 46, 19, 48, 21, br_cyan, black, 0
	
	; Egal
	cls_region 50, 19, 52, 21, br_red, br_white, 0
	
	; < Randul 1 de operatori >
	bios_putc 31, 8, '7'
	bios_putc 35, 8, '8'
	bios_putc 39, 8, '9'
	bios_putc 43, 8, '/'
	bios_putc 47, 8, 227
	bios_putc 51, 8, 'C'
	
	; < Randul 2 de operatori >
	bios_putc 31, 12, '4'
	bios_putc 35, 12, '5'
	bios_putc 39, 12, '6'
	bios_putc 43, 12, '*'
	bios_putc 46, 12, '1'
	bios_putc 47, 12, '/'
	bios_putc 48, 12, 'x'
	bios_putc 51, 12, '<'
	
	; < Randul 3 de operatori >
	bios_putc 31, 16, '1'
	bios_putc 35, 16, '2'
	bios_putc 39, 16, '3'
	bios_putc 43, 16, '-'
	bios_putc 47, 16, 'x'
	bios_putc 48, 16, 253
	bios_putc 51, 16, 251
	
	; < Randul 4 de operatori >
	bios_putc 31, 20, '0'
	bios_putc 35, 20, '.'
	bios_putc 39, 20, 241
	bios_putc 43, 20, '+'
	bios_putc 46, 20, 'x'
	bios_putc 47, 20, '^'
	bios_putc 48, 20, '3'
	bios_putc 51, 20, '='
	
	; < Rama calculator >
	; colt stanga sus 
	bios_putc 28, 1, 201
	; colt dreapta sus 
	bios_putc 54, 1, 187
	; colt stanga jos 
	bios_putc 28, 23, 200
	; colt dreapta jos 
	bios_putc 54, 23, 188
	
	; linie orizontala sus
	bios_hputc_color 29, 1, 205, br_white, black, 25
	; linie orizontala jos
	bios_hputc_color 29, 23, 205, br_white, black, 25
	
	; linie verticala stanga
	bios_vputc_color 28, 2, 186, br_white, black, 21
	; linie verticala dreapta
	bios_vputc_color 54, 2, 186, br_white, black, 21
	
	; < Rama rezultat calcule >
	; colt stanga sus 
	bios_putc 30, 3, 218
	; colt dreapta sus 
	bios_putc 52, 3, 191
	; colt stanga jos 
	bios_putc 30, 5, 192
	; colt dreapta jos 
	bios_putc 52, 5, 217
	
	; linie orizontala sus
	bios_hputc_color 31, 3, 196, white, black, 21
	; linie orizontala jos
	bios_hputc_color 31, 5, 196, white, black, 21
	
	; linie verticala stanga
	bios_putc 30, 4, 179
	; linie verticala dreapta
	bios_putc 52, 4, 179

	end_video
	
	; Initializam rezultatul cu valoarea 0
	strcat rezultat, zero
	strlen rezultat, len
	
din_nou:    
	; Scriem rezultatul pe ecran
	start_video
	mov ax, 31+max
	sub ax, len
	mov [x], ax
	; Stergem ecranul
	bios_hputc_color 31, 4, 0, white, black, max
	; Afisam rezultatul
	bios_puts x, 4, rezultat, white, black, len
	end_video
	
	; Citim de la tastatura
	mov ah, 08h
	int 21h	

	; Daca apasam ESC programul se termina
	cmp al, kbd_esc
	je gata	

	; Cautam in lista noastra operatia si sarim direct la ea
	lea di, case
	mov cx, cases
	cld
	repne scasb
	jne et_default	
	
	dec di
	lea bx, case
	sub di, bx
	shl di, 1 ; inmultim cu 4 - 32 biti	
	jmp casejmp[di]
	
gata:
	; Inchidem programul
    mov ah, 4Ch
    int 21h

et_default:
	jmp et

; Cifra 0
et_0:
	; Verificam daca trebuie sa stergem rezultatul
	cmp byte ptr [clear], 0
	je et_0c
	; Stergem rezultatul
	mov byte ptr [clear], 0
	jmp et_00c
et_0c:
	strlen rezultat, len
	cmp ax, max-1
	jge et_0_
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne et_00_
et_00c:	
	memset rezultat, 0, max+1
et_00_:
	strcat rezultat, zero
et_0_:
	jmp et
	
; Cifra 1
et_1:
	; Verificam daca trebuie sa stergem rezultatul
	cmp byte ptr [clear], 0
	je et_1c
	; Stergem rezultatul
	mov byte ptr [clear], 0
	jmp et_11c
et_1c:
	; Verificam lungimea maxima a sirului
	strlen rezultat, len
	cmp ax, max-1
	jge et_1_
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne et_11_
et_11c:	
	memset rezultat, 0, max+1
et_11_:
	strcat rezultat, unu
et_1_:	
	jmp et

; Cifra 2
et_2:
	; Verificam daca trebuie sa stergem rezultatul
	cmp byte ptr [clear], 0
	je et_2c
	; Stergem rezultatul
	mov byte ptr [clear], 0
	jmp et_22c
et_2c:
	strlen rezultat, len
	cmp ax, max-1
	jge et_2_
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne et_22_
et_22c:	
	memset rezultat, 0, max+1
et_22_:
	strcat rezultat, doi
et_2_:
	jmp et

; Cifra 3
et_3:
	; Verificam daca trebuie sa stergem rezultatul
	cmp byte ptr [clear], 0
	je et_3c
	; Stergem rezultatul
	mov byte ptr [clear], 0
	jmp et_33c
et_3c:
	strlen rezultat, len
	cmp ax, max-1
	jge et_3_
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne et_33_
et_33c:	
	memset rezultat, 0, max+1
et_33_:
	strcat rezultat, trei
et_3_:
	jmp et

; Cifra 4
et_4:
	; Verificam daca trebuie sa stergem rezultatul
	cmp byte ptr [clear], 0
	je et_4c
	; Stergem rezultatul
	mov byte ptr [clear], 0
	jmp et_44c
et_4c:
	strlen rezultat, len
	cmp ax, max-1
	jge et_4_
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne et_44_
et_44c:	
	memset rezultat, 0, max+1
et_44_:
	strcat rezultat, patru
et_4_:
	jmp et

; Cifra 5
et_5:
	; Verificam daca trebuie sa stergem rezultatul
	cmp byte ptr [clear], 0
	je et_5c
	; Stergem rezultatul
	mov byte ptr [clear], 0
	jmp et_55c
et_5c:
	strlen rezultat, len
	cmp ax, max-1
	jge et_5_
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne et_55_
et_55c:	
	memset rezultat, 0, max+1
et_55_:
	strcat rezultat, cinci
et_5_:
	jmp et
	
; Cifra 6
et_6:
	; Verificam daca trebuie sa stergem rezultatul
	cmp byte ptr [clear], 0
	je et_6c
	; Stergem rezultatul
	mov byte ptr [clear], 0
	jmp et_66c
et_6c:
	strlen rezultat, len
	cmp ax, max-1
	jge et_6_
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne et_66_
et_66c:	
	memset rezultat, 0, max+1
et_66_:
	strcat rezultat, sase
et_6_:
	jmp et

; Cifra 7	
et_7:
	; Verificam daca trebuie sa stergem rezultatul
	cmp byte ptr [clear], 0
	je et_7c
	; Stergem rezultatul
	mov byte ptr [clear], 0
	jmp et_77c
et_7c:
	strlen rezultat, len
	cmp ax, max-1
	jge et_7_
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne et_77_
et_77c:	
	memset rezultat, 0, max+1
et_77_:
	strcat rezultat, sapte
et_7_:
	jmp et

; Cifra 8
et_8:
	; Verificam daca trebuie sa stergem rezultatul
	cmp byte ptr [clear], 0
	je et_8c
	; Stergem rezultatul
	mov byte ptr [clear], 0
	jmp et_88c
et_8c:
	strlen rezultat, len
	cmp ax, max-1
	jge et_8_
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne et_88_
et_88c:	
	memset rezultat, 0, max+1
et_88_:
	strcat rezultat, opt
et_8_:
	jmp et

; Cifra 9	
et_9:
	; Verificam daca trebuie sa stergem rezultatul
	cmp byte ptr [clear], 0
	je et_9c
	; Stergem rezultatul
	mov byte ptr [clear], 0
	jmp et_99c
et_9c:
	strlen rezultat, len
	cmp ax, max-1
	jge et_9_
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne et_99_
et_99c:	
	memset rezultat, 0, max+1
et_99_:
	strcat rezultat, noua
et_9_:
	jmp et

; Separator virgula
et_punct:
	cmp byte ptr [clear], 0
	je et_pc
	; Stergem rezultatul
	mov byte ptr [clear], 0
	memset rezultat, 0, max+1
	strcat rezultat, zero_punct
	strlen rezultat, len
	jmp din_nou
et_pc:
	strlen rezultat, len
	cmp ax, max-1
	jge et_p_
	strchr rezultat, '.', are_punct
	cmp byte ptr [are_punct], 0 ; daca avem un . deja in 'rezultat'
	jne et_p_
	strcat rezultat, punct
et_p_:
	strlen rezultat, len
	jmp din_nou

; Operatia de schimbare de semn
et_spacebar:
	; Verificam daca e 0
	strcmp rezultat, zero, zero_initial
	cmp word ptr [zero_initial], 0	
	jne continua
	jmp et
continua:	
	memset temp, 0, max+1
	strlen rezultat, len
	cmp ax, max
	jge et_sb0_
	strchr rezultat, '-', are_minus
	cmp byte ptr [are_minus], 0 ; daca nu avem - in 'rezultat'	
	jne et_sb_
	; Punem minus in rezultat	
	strcat temp, minus
	strcat temp, rezultat
	memset rezultat, 0, max+1
	strcat rezultat, temp
	jmp et
et_sb_:
	; Scoatem minusul din rezultat	
	strcat temp, rezultat
	memset rezultat, 0, max+1
	strpcat rezultat, temp, 1
et_sb0_:	
	jmp et
	
; Operatii matematice	
et_plus:	
	; daca avem deja un operator il schimbam cu cel nou
	cmp byte ptr [clear], 1
	jne et_p0
	mov byte ptr [op], '+'
	jmp et
et_p0:
	; daca avem deja un operator de calculat il aplicam
	cmp byte ptr [op], 0
	je et_p
	_atof rezultat, nr2
	call calcul
et_p:
    ; punem nr nostru in nr1
	_atof rezultat, nr1
	; setam operatorul
	mov byte ptr [op], '+'
	mov byte ptr [clear], 1
	jmp et

et_minus:
	; daca avem deja un operator il schimbam cu cel nou
	cmp byte ptr [clear], 1
	jne et_m0
	mov byte ptr [op], '-'
	jmp et
et_m0:
	; daca avem deja un operator de calculat il aplicam
	cmp byte ptr [op], 0
	je et_m
	_atof rezultat, nr2
	call calcul
et_m:
    ; punem nr nostru in nr1
	_atof rezultat, nr1
	; setam operatorul
	mov byte ptr [op], '-'
	mov byte ptr [clear], 1
	jmp et
	
et_inmultire:
	; daca avem deja un operator il schimbam cu cel nou
	cmp byte ptr [clear], 1
	jne et_inm0
	mov byte ptr [op], '*'
	jmp et
et_inm0:
	; daca avem deja un operator de calculat il aplicam
	cmp byte ptr [op], 0
	je et_inm
	_atof rezultat, nr2
	call calcul
et_inm:
    ; punem nr nostru in nr1
	_atof rezultat, nr1
	; setam operatorul
	mov byte ptr [op], '*'
	mov byte ptr [clear], 1
	jmp et
	
et_impartire:
	; daca avem deja un operator il schimbam cu cel nou
	cmp byte ptr [clear], 1
	jne et_imp0
	mov byte ptr [op], '/'
	jmp et
et_imp0:
	; daca avem deja un operator de calculat il aplicam
	cmp byte ptr [op], 0
	je et_imp
	_atof rezultat, nr2
	call calcul
et_imp:
    ; punem nr nostru in nr1
	_atof rezultat, nr1
	; setam operatorul
	mov byte ptr [op], '/'
	mov byte ptr [clear], 1
	jmp et

; Radacina patrata
et_r_mic:
et_r_mare:
	strchr rezultat, '-', are_minus
	cmp byte ptr [are_minus], 0 ; daca nu avem - in 'rezultat'	
	je et_rr_
	memset rezultat, 0, max+1
	strcat rezultat, eroare_sqrt
	jmp et
et_rr_:
	_atof rezultat, numar
	fld dword ptr [numar]
	fsqrt
	fstp dword ptr [numar]
	memset rezultat, 0, max+1
	_ftoa numar, rezultat
	jmp et

; numarul PI	
et_p_mic:
et_p_mare:
	fldpi
	fstp dword ptr [numar]
	memset rezultat, 0, max+1
	_ftoa numar, rezultat
	strdz rezultat
	jmp et

; 1/x
et_i_mic:
et_i_mare:
	_atof rezultat, numar
	fld1
	fld dword ptr [numar]
	fdivp st(1), st(0)
	fstp dword ptr [numar]
	memset rezultat, 0, max+1
	_ftoa numar, rezultat
	strdz rezultat
	jmp et

; x^2	
et_s_mic:
et_s_mare:
	_atof rezultat, numar
	fld dword ptr [numar]
	fmul st(0), st(0)
	fstp dword ptr [numar]
	memset rezultat, 0, max+1
	_ftoa numar, rezultat
	strdz rezultat
	jmp et

; x^3	
et_b_mic:
et_b_mare:
	_atof rezultat, numar
	fld dword ptr [numar]
	fmul st(0), st(0)
	fld dword ptr [numar]
	fmulp st(1), st(0)
	fstp dword ptr [numar]
	memset rezultat, 0, max+1
	_ftoa numar, rezultat
	strdz rezultat
	jmp et
	
et_egal:
et_enter:
	; daca avem un operator afisam rezultatul calculului
	cmp byte ptr [op], 0
	je et_rez
	_atof rezultat, nr2
	call calcul
et_rez:	
	jmp et

; Operatia de stergere cifra	
et_backspace:
	; stergem ultimul caracter
	strdlc rezultat
	strlen rezultat, len
	
	; Daca nu mai avem nici un caracter, punem 0
	cmp word ptr [len], 0
	jg et_b1	
	jmp et_b4
et_b1:
	; daca rezultat = - transformam in 0
	strcmp rezultat, minus, e_minus_zero
	cmp word ptr [e_minus_zero], 0
	je et_b3
et_b2:
    ; daca rezultat = -0 transformam in 0
	strcmp rezultat, minus_zero, e_minus_zero
	cmp word ptr [e_minus_zero], 0
	jne et_b
et_b3:	
	memset rezultat, 0, max+1
et_b4:
	strcat rezultat, zero
et_b:
	jmp et
	
; Anuleaza rezultat + alte flag-uri
et_c_mic:
et_c_mare:
	mov byte ptr [clear], 0
	mov byte ptr [op], 0
	mov word ptr [e_minus_zero], 0
	mov byte ptr [are_minus], 0
	mov byte ptr [are_punct], 0
	memset rezultat, 0, max+1	
	strcat rezultat, zero	
	jmp et
	
et:
	strlen rezultat, len
	jmp din_nou

; calculul propriu-zis al operatiilor
calcul:	
	cmp byte ptr [op], '+'
	jne op_minus
	; Operatia de adunare
	fld dword ptr [nr1] ; st0 = nr1
	fadd nr2 ; st0 = st0 + nr2
	;fadd round
	jmp op_final
op_minus:
	cmp byte ptr [op], '-'
	jne op_inmultire
	; Operatia de scadere
	fld dword ptr [nr1] ; st0 = nr1
	fsub nr2 ; st0 = st0 - nr2
	;fadd round
	jmp op_final
op_inmultire:
	cmp byte ptr [op], '*'
	jne op_impartire
	; Operatia de inmultire
	fld dword ptr [nr1] ; st0 = nr1
	fmul nr2 ; st0 = st0 * nr2
	;fadd round
	jmp op_final
op_impartire:
	cmp byte ptr [op], '/'
	je op_imp
	jmp op_gata
op_imp:	
	; Operatia de impartire
	fld dword ptr [nr1] ; st0 = nr1
	fdiv nr2 ; st0 = st0 / nr2
	;fadd round
op_final:	
	memset rezultat, 0, max+1
	
	fxam           ;examine it
    fstsw ax       ;copy the content of the Status Word to AX
    fwait          ;insure the last instruction is completed
    sahf           ;copy the C3/C2/C0 condition codes to the ZF/PF/CF flags
    jz    C3is1    ;either Zero, Empty or Denormalized if C3=1
    jpe   C2is1    ;either normal or infinity if C3=0 and C2=1
    jc    isNAN    ;would be NAN if C3=0, C2=0 and C0=1
                   ;code for the case of Unsupported, no need to check sign
	jmp op_final_
isNAN:
    strcat rezultat, eroare_nan     ;code for the case of a NAN, no need to check the sign
	jmp op_afisare

C2is1:
    jc    isINFINITY ;would be Infinity if C3=0, C2=1 and C0=1
                     ;this leaves the case for a Normal finite number
    test  ah,2       ;test for the sign which is in bit1 of AH
    jnz   negNORMAL
    jmp op_final_     ;code for the case of a positive Normal finite number

negNORMAL:
    jmp op_final_     ;code for the case of a negative Normal finite number

isINFINITY:
    test  ah,2     ;test for the sign which is in bit1 of AH
    jnz   negINFINITY
    strcat rezultat, eroare_pinf
    jmp op_afisare     ;code for the case of a positive Infinity

negINFINITY:
	strcat rezultat, eroare_minf
    jmp op_afisare     ;code for the case of a negative Infinity

C3is1:
    jc  isEMPTY  ;would be Empty if C3=1 and C0=1
    jpe isDENORMAL ;would be a Denormalized number if C3=1, C0=0 and C2=1
                  ;this leaves the case for a Zero value
    jmp op_final_     ;code for the case of a Zero value, no need to check sign

isEMPTY:
	strcat rezultat, eroare_gol
    jmp op_afisare     ;code for the case of an Empty register
                  ;which does not apply in this example because
                  ;ST(0) was loaded with a value from memory

isDENORMAL:
    test ah,2     ;test for the sign which is in bit1 of AH
    jnz negDENORMAL
	strcat rezultat, eroare_dp
    jmp op_afisare    ;code for the case of a positive Denormalized number
	
negDENORMAL:
	strcat rezultat, eroare_dn
	jmp op_afisare
	
op_final_:
	fstp dword ptr [numar]	
	_ftoa numar, rezultat
	strdz rezultat
op_afisare:	
	strlen rezultat, len
	
	mov byte ptr [op], 0
	mov byte ptr [clear], 0
op_gata:	
	ret
end start