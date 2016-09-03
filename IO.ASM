.286
.287

.model large

;
; Declaratii de simboluri publice
;
	public itoa_proc,atoi_proc,puts_proc,puti_proc
	public gets_proc,getc_proc,putc_proc,putu_proc
	public ftoa_proc, ftoa_sc_proc, atof_proc
	public ltoa_proc
	
dosint	macro	func
	mov	ah,func	;Macro de apel functii DOS
	int	21h
endm

f_comp macro val
	local temp, etgt, etlt, eteq, gata
.data
	temp dd ? ; Spatiu de lucru
.code
	push ax ; Salvare AX
	fld st ; Se face o copie a varfului
		   ; stivei, pentru. a nu
           ; altera ST initial
	fsub dword ptr val ; ST <- ST - val
	fstp dword ptr temp ; Depunem diferenta
	mov al, byte ptr temp+3 ; Luam ultimul octet
	; din reprezentare
	and al, 10000000B ; Filtru bit de semn
	jnz etlt ; Diferenta negativa ?
	mov ax, word ptr temp ; Nu, testam daca nu
	; este zero
	or ax, word ptr temp+2 ; Zero real are toti cei
	; 4 octeti null
	jz eteq ; Este zero ?
etgt:
	mov ax, 2 ; Nu, inseamna ca e mai mare
	cmp ax, 1 ; Facem o comparatie pentru a
	jmp gata ; pozitiona indicatorii
etlt:
	mov ax, word ptr temp
	or ax, word ptr temp+2
	and ax, 7FFFH ; -0 si 0 sunt identice
	jz eteq
	mov ax, 1 ; Cazul mai mic
	cmp ax, 2
	jmp gata
eteq:
	mov ax, 1 ; Cazul egal
	cmp ax, 1
gata:
	pop ax ; Refacere AX si gata
endm

.code
;
; Schimba ordinea caracterelor din sirul indicat de DS:SI
;
strrev	proc	far
	cmp	byte ptr [di],0	; Test terminator sir
	je	str_5
	push	di		; Salvari
	push	si
	push	ax
	mov	si,di		; Copie adresa sir
str_1:
	mov	al,[si]		; Determina sfarsit sir
	test	al,al		
	jz	str_2
	inc	si		; Incrementeaza adresa
	jmp	str_1
str_2:
	dec	si		; SI pe ultimul caracter util
str_3:
	mov	al,[si]		; Interschimba
	xchg	al,[di]		; ultimul caracter
	mov	[si],al		; cu primul
	inc	di
	dec	si
	cmp	di,si		; Pana cand pointerul crescator
	jb	str_3		; devine mai mare decat cel descrescator
	pop	ax		; Refaceri
	pop	si
	pop	di
str_5:
	retf
strrev	endp

;
; Converteste intregul cu semn din AX la sirul de caractere
; de la adresa DS:DI
itoa_proc	proc	far
	push	ax		; Salvari
	push	bx
	push	cx
	push	dx
	push	di
	
	xor si, si
	
	cmp	ax, 800h		 	; Caz special
	jne	itoa_1
	mov	byte ptr [di],'-'	; care se
	mov	byte ptr [di+1],'3' 	; converteste
	mov	byte ptr [di+2],'2' 	; manual
	mov	byte ptr [di+3],'7' 	; deoarece NEG din 800h va da
	mov	byte ptr [di+4],'6' 	; tot 800h (adica -32768)
	mov	byte ptr [di+5],'8' 	
	mov	byte ptr [di+6],0
	mov si, 6
	jmp	itoa_2
itoa_1:
	mov	cl,' '			; Memoram semnul
	cmp	ax,0
	jge	itoa_3
	mov	cl,'-'
	neg	ax			; Valoare absoluta
itoa_3:
	mov	bx,10			; Impartitor
itoa_4:
	mov	dx,0			; Impartire 32 de biti
	div	bx			; la 16 biti
	add	dl,'0'			; Cifra curenta
	mov	[di],dl			; depusa in sir
	inc	di
	inc si
	test	ax,ax			; Pana cand AX devine 0
	jnz	itoa_4			
	cmp	cl,'-'			; Test semn
	jne	itoa_6
	mov	[di],cl			; Pune minus
	inc	di
	inc si
itoa_6:
	mov	byte ptr [di],0		; Terminator
	pop	di			; Adresa de inceput
	call	far ptr strrev		; Inverseaza sir
	push	di			; Pentru POP-urile care vin
itoa_2:
	pop	di			; Refaceri
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	retf
itoa_proc	endp

;
; Converteste long cu semn din EAX la sirul de caractere
; de la adresa DS:DI
; in SI cate caractere a convertit
.386
ltoa_proc	proc	far
	push	ax		; Salvari
	push	bx
	push	cx
	push	dx
	push	di
	
	xor si, si
;
	cmp	eax, 80000000h		 	; Caz special
	jne	ltoa_1
	mov	byte ptr [di],'-'	; care se
	mov	byte ptr [di+1],'2' 	; converteste
	mov	byte ptr [di+2],'1' 	; manual
	mov	byte ptr [di+3],'4' 	; deoarece NEG din 800h va da
	mov	byte ptr [di+4],'7' 	; tot 800h (adica -32768)
	mov	byte ptr [di+5],'4' 	
	mov	byte ptr [di+6],'8' 	
	mov	byte ptr [di+7],'3' 
	mov	byte ptr [di+8],'6'
	mov	byte ptr [di+9],'4'
	mov	byte ptr [di+10],'8'	
	mov	byte ptr [di+11],0
	mov si, 11
	jmp	ltoa_2
ltoa_1:
	mov	cl,' '			; Memoram semnul
	cmp	eax,0
	jge	ltoa_3
	mov	cl,'-'
	neg	eax			; Valoare absoluta
ltoa_3:
	mov	ebx,10			; Impartitor
ltoa_4:
	mov	edx,0			; Impartire 32 de biti
	div	ebx			; la 16 biti
	add	dl,'0'			; Cifra curenta
	mov	[di],dl			; depusa in sir
	inc	di
	inc si
	test eax,eax			; Pana cand AX devine 0
	jnz	ltoa_4			
	cmp	cl,'-'			; Test semn
	jne	ltoa_6
	mov	[di],cl			; Pune minus
	inc	di
	inc si
ltoa_6:
	mov	byte ptr [di],0		; Terminator
	pop	di			; Adresa de inceput
	call	far ptr strrev		; Inverseaza sir
	push	di			; Pentru POP-urile care vin
ltoa_2:
	pop	di			; Refaceri
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	retf
ltoa_proc	endp
.286

;
; Converteste sirul de la adresa DI:SI la intreg in AX
;
atoi_proc	proc 	far
	push	di			; Salvari
	push	si
	push	bx
	push	cx
	push	dx
atoi_1:
	cmp	byte ptr [si],' '	; Sarim peste spatiile initiale
	jne	atoi_2
	inc	si
	jmp	atoi_1
atoi_2:
	mov	di,1			; Memorare semn '+'
	cmp	byte ptr [si],'+'	; Test semn
	je	atoi_3
	cmp	byte ptr [si],'-'	
	jne	atoi_4
	mov	di,-1			; Memorare semn '-'
atoi_3:
	inc	si
atoi_4:
	xor	ax,ax			; Valoare initiala 
	xor	ch,ch			; Pentru adunare cifra
	mov	bx,10			; Deinmulit
atoi_5:
	cmp	byte ptr [si],'0'	; Text
	jb	atoi_6			; cifre
	cmp	byte ptr [si],'9'	; zecimale
	ja	atoi_6
	mul	bx			; n = n * 10
	mov	cl,[si]			; +
	sub	cl,'0'			; cifra
	add	ax,cx			; curenta
	inc	si
	jmp	atoi_5			; Reluare bucla
atoi_6:
	cmp	di,-1			; A fost '-' ?
	jne	atoi_7
	neg	ax			; Schimba semnul
atoi_7:
	pop	dx			; Refaceri
	pop	cx
	pop	bx
	pop	si
	pop	di
	retf
atoi_proc	endp

;
; Afisarea sirului de la adresa DS:SI
;	
puts_proc	proc	far
	push	ax			; Salvari
	push	si
	push	dx
puts_1:
	mov	dl,[si]			; Preia caracter
	test	dl,dl			; Test terminator
	jz	puts_2
	dosint	2			; Afisare caracter
	inc	si			; Urmatorul
	jmp	puts_1
puts_2:
	pop	dx			; Refaceri
	pop	si
	pop	ax
	retf
puts_proc	endp

;
; Buffer local pentru gets_proc
;
	.data
buffer	db	83 dup(?)

	.code

;
; Citeste un sir de lungime maxima CX si il depune
; la adresa DS:DI
; Se foloseste functia DOS 0AH, care vrea lungimea maxima pe
; primul octet al bufferului. Ea raporteaza cate caractere
; s-au citit de fapt in al doilea octet al bufferu-ului.
; Caracterele sunt depuse incepand de la al treilea octet al
; buffer-ului. Lungimea raportata nu include CR final,
; care se depune totusi in buffer-ul local. Functia 0AH 
; accepta MAX-1 caractere, unde MAX este primul octet din
; buffer, dupa care se da un semnal sonor si se asteapta 
;obligatoriu CR.
;
gets_proc	proc	far
	push	ax			; Salvari
	push	dx
	push	di
	push	si
	push	es

	mov	ax,ds			; Vom folosi
					; instructiuni
	mov	es,ax			; cu siruri
	cmp	cx,80			; Trunchiem lungimea
	jle	gets_1			; maxima la 80 de
	mov	cx,80			; caractere
gets_1:
	cmp	cx,2			; Si la
	jge	gets_2			; minim 2 caractere
	mov	cx,2			; (pentru CR si terminator)
gets_2:
	mov	buffer,cl		; Pregatire buffer
	lea	dx,buffer
	dosint	0AH			; Apel functie
	mov	cl,buffer+1		; Lungimea efectiva
	mov	ch,0			; Pentru JCXZ
	jcxz	gets_3			; Daca este 0, este sirul vid
	lea	si,buffer+2		; Caracterele propriu-zise
	cld				; Directie ascendenta
	rep	movsb	; Bucla de copiere in spatiul utilizatorului
gets_3:
	mov	byte ptr es:[di],0	; Terminator sir
	mov	dl,0DH			; Un CR/LF in ecou
	dosint	2			; la
	mov	dl,0AH			; consola
	dosint	2
	pop	es			; Refaceri
	pop	si
	pop	di
	pop	dx
	pop	ax
	retf
gets_proc	endp

;
; Citeste caracter in AL
;
getc_proc	proc	far
	dosint	1
	mov	ah,0			; Intoarce ca intreg
	retf
getc_proc	endp

;
; Afiseaza caracterul din AL
;
putc_proc	proc	far
	push	ax
	push	dx
	mov	dl,al
	dosint	2
	pop	dx
	pop	ax
	retf
putc_proc	endp

;
; Afiseaza intreg fara semn. Parametrul in stiva.
;
putu_proc	proc	far
	push	bp
	mov	bp,sp
	push	dx			; Salvari
	push	ax
	push	bx
	mov	ax,[bp+6]		; Preia intreg din stiva
	cmp	ax,10
	mov	dl,al
	jb	putu_1			; Este mai mic decat 10
	mov	bx,10			; Nu, il impartim
	xor	dx,dx			; 32 de biti la 16
	div	bx			; AX = cat (n/10)
					; DX = rest (n MOD 10)
	push	ax			; Apel
	call	far ptr putu_proc	; recursiv pentru
	add	sp,2			; n/10
putu_1:
	add	dl,'0'			; Afisare n MOD 10
	dosint	2
	pop	bx			; Refaceri
	pop	ax
	pop	dx
	pop	bp
	retf
putu_proc	endp

;
; Afisare intreg cu semn. Parametrul in stiva.
;
puti_proc	proc	far
	push	bp
	mov	bp,sp
	push	ax			; Salvari
	push	dx
	mov	ax,[bp+6]		; Preia numar
	xor	ax,ax			; Test semn
	jnz	puti_1			; Este pozitiv, salt
	mov	dl,'-'			; Este negativ, se
					; afiseaza un '-'
	dosint	2
	neg	word ptr [bp+6]		; Se schimba semnul numarului
puti_1:
	push	word ptr [bp+6]			; Se afiseaza ca numar
					; fara semn
	call	far ptr putu_proc
	add	sp,2			; Descarca stiva
	pop	dx			; Refaceri
	pop	ax
	pop	bp
	retf
puti_proc	endp

itoa	macro	dest,source
	push	ax
	push	di
	mov	ax,source		; Numar intreg
	lea	di,dest			; Adresa sir generat
	call	itoa_proc
	pop	di
	pop	ax
endm

sablon_ftoa struc
		dw ?
		dd ?
	val dd ?
	siradr dw ?
ends

.data
	_zece dd 10.0
	_unu dd 1.0
	_zero dd 0.0
	_round dd 0.0000005
	_exp dw ?
	_cifra dw ?
	_cifra32 dd ?
	_temp dd ?
	_cw dw ?
	len dw 0
.code

ftoa_proc proc far
	push bp
	mov bp, sp
	push ax ; Salvare
	push bx ; registre
	push si
	push cx
	fstcw _cw ; Salvare Control Word
	mov ax, _cw
	and ax, NOT 0000110000000000B ; Filtru bitii 10 si 11
	or ax, 0000010000000000B ; Fortare RC = 1
	mov _cw, ax ; inapoi in memorie
	fldcw _cw ; inapoi in 80x87

	mov _exp, 0 ; Exponent
	mov si, [bp].siradr ; Adresa sir
	; de caractere
	fld dword ptr [bp].val ; Valoare reala in ST
	
	fist _cifra32 ; Generam partea
                ; intreaga
.386	
	push si
	push ax
	push di
	mov	eax, _cifra32		; Numar intreg
	mov	di, si			; Adresa sir generat
	call ltoa_proc
	mov len, si
	pop	di
	pop	ax
	pop si
.286
	add si, len	

	mov byte ptr [si], '.' ; Apoi punctul zecimal
	inc si
	mov cx, 6 ; Bucla de 7 cifre
			  ; dupa punct
ftoa_5:
	fisub _cifra32 ; ST = partea
	; fractionara
	fmul _zece ; ST = ST * 10
	fist _cifra32 ; Partea intreaga
	mov bl, byte ptr [_cifra32] ; Determinare cifra
	add bl, '0'
	mov [si], bl
	inc si
	loop ftoa_5
	fstp _temp ; Descarcam stiva 8087

	pop cx ; Refacere
	pop si ; registre
	pop bx
	pop ax
	pop bp
	retf ; Revenire
ftoa_proc endp

ftoa_sc_proc proc far
	push bp
	mov bp, sp
	push ax ; Salvare
	push bx ; registre
	push si
	push cx
	fstcw _cw ; Salvare Control Word
	mov ax, _cw
	and ax, NOT 0000110000000000B ; Filtru bitii 10 si 11
	or ax, 0000010000000000B ; Fortare RC = 1
	mov _cw, ax ; inapoi in memorie
	fldcw _cw ; inapoi in 80x87

	mov _exp, 0 ; Exponent
	mov si, [bp].siradr ; Adresa sir
	; de caractere
	fld dword ptr [bp].val ; Valoare reala in ST
	f_comp _zero
	jg _ftoa_poz ; Este > 0 ?
	mov byte ptr [si], '-' ; Nu, depunem '-'
	inc si ; in sir si schimbam
	fchs ; semnul numarului real
_ftoa_poz:
	f_comp _zero
	jne _ftoa_aici ; Este diferit de 0.0 ?
	jmp _ftoa_1
_ftoa_aici: ; Da, il convertim
	f_comp _zece
	jnge _ftoa_2 ; Este < 10 ?
_ftoa_3:
	fdiv _zece ; Nu, il impartim la 10
	add _exp, 1 ; si tinem minte
	; la exponent
	f_comp _zece ; pana cand ajunge
	jnl _ftoa_3 ; mai mic strict
	; decat 10
_ftoa_2:
	f_comp _unu ; Este mai mare
	; sau egal ca 1 ?
	jge _ftoa_1 ; Da, salt
	fmul _zece ; Nu, il inmultim cu
	; 10 si tinem minte
	sub _exp, 1 ; la exponent,
	; pana ajunge
	jmp _ftoa_2 ; mai mare sau
	; egal ca 1
_ftoa_1:
	fadd _round ; Rotunjim la
	; 7 zecimale
	f_comp _zece ; Poate a depasit
	; acum 10 ?
	jna _ftoa_4
	fdiv _zece ; Daca da, corectam
	add _exp, 1
_ftoa_4:
	fist _cifra ; Generam partea
	; intreaga
	mov bl, byte ptr _cifra ; Luam cifra
	; propriu-zisa,
	add bl, '0' ; o convertim la
	; caracter ASCII
	mov [si], bl ; si o depunem in sir
	inc si
	mov byte ptr [si], '.' ; Apoi punctul zecimal
	inc si
	mov cx, 6 ; Bucla de 7 cifre
	; dupa punct
_ftoa_5:
	fisub _cifra ; ST = partea
	; fractionara
	fmul _zece ; ST = ST * 10
	fist _cifra ; Partea intreaga
	mov bl, byte ptr _cifra ; Determinare cifra
	add bl, '0'

	mov [si], bl
	inc si
	loop _ftoa_5
	fstp _temp ; Descarcam stiva 8087
	mov byte ptr [si], 'E' ; Notatie stiintifica
	inc si
	cmp _exp, 0 ; Test semn exponent
	jge _ftoa_6
	mov byte ptr [si], '-' ; Negativ
	neg _exp ; Schimbam semnul
	jmp _ftoa_7
_ftoa_6:
	mov byte ptr [si], '+' ; Pozitiv
_ftoa_7:
	inc si
	mov ax, _exp ; Exponent
	aam ; AH = _exp / 10;
	; AL = _exp MOD 10
	or ax, 3030H ; Ambele cifre
	; convertite la ASCII
	mov [si], ah ; Depunere in sir
	inc si
	mov [si], al
	inc si
	mov byte ptr [si], 0 ; in fine, terminatorul
	; de sir
	pop cx ; Refacere
	pop si ; registre
	pop bx
	pop ax
	pop bp
	retf ; Revenire
ftoa_sc_proc endp

sablon_atof struc
		    dw ? ; Loc pentru BP
		    dd ? ; Loc pentru adresa de revenire
	adr_num dw ?
	adr_sir dw ?
ends

.data
	_punct db ?
	_minus db ?
	
.code
atof_proc proc
	push bp
	mov bp, sp
	push bx ; Salvari
	push si ; registre
	fld1 ; ST <- 1.0
	fldz ; ST <- 0.0, ST(1) <- 1.0
	; Asignam valoare in ST si divizor in ST(1)
	mov _punct, 0
	mov _minus, 0
	xor bh, bh ; Necesar la depunere intreg
	mov si, [bp].adr_sir ; Adresa sir
	cmp byte ptr [si], '-' ; Test '-'
	jne atof_1
	mov _minus, 1
	inc si
atof_1:
	mov bl, [si] ; Preia caracter
	cmp bl, '.' ; Test '.'
	jne atof_2
	mov _punct, 1
	jmp atof_3 ; Salt la reluare
atof_2:
	cmp bl, '0' ; Test
	jb atof_4 ; cifra
	cmp bl, '9' ; zecimala
	ja atof_4
	sub bl, '0' ; Conversie la intreg
	mov _cifra, bx ; Memoram ca intreg
	fmul _zece ; valoare = 10*valoare
	fiadd _cifra ; valoare = valoare +
	; cifra
	cmp _punct, 1 ; Test punct
	jne atof_3
	fxch ; Schimbam ST cu ST(1)
	fmul _zece ; pentru ca vrem
	; sa inmultim
	fxch ; divizorul cu zece,
	; apoi schimbam la loc
atof_3:
	inc si ; Reluare
	jmp atof_1 ; bucla
atof_4:
	fdivr ; impartire ST la ST(1)
	; cu descarcarea stivei
	; Rezultat in ST
	cmp _minus, 1 ; Test semn
	jne atof_5
	f_comp _zero ; Daca e 0.0 nu
	je atof_5 ; schimba semnul
	fchs ; Schimbare semn
atof_5:
	mov bx, [bp].adr_num ; Adresa numar real
	fstp dword ptr [bx] ; Depunere ST
	; cu descarcarea
	fwait ; stivei, apoi FWAIT
	pop si ; Refaceri
    pop bx ; registre
	pop bp
	retf ; Revenire
atof_proc endp

end

