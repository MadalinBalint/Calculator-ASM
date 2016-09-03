	.xlist
;
;  Declaratii de proceduri externe (implementate in IO.ASM)
;
extrn	itoa_proc:far, atoi_proc:far,puts_proc:far
extrn	gets_proc:far, getc_proc:far,putc_proc:far
extrn	puti_proc:far, putu_proc:far
extrn	ftoa_proc:far, atof_proc:far, ftoa_sc_proc:far
extrn	ltoa_proc:far

cr	equ	0dh		; Constante
lf	equ	0ah		; simbolice
tab	equ	09h		; uzuale
;
; 	init_ds_es: Initializarea registrelor DS si ES
;
init_ds_es macro
	push ax
	mov	ax,dgroup
	mov	ds,ax
	mov	es,ax
	pop	ax
endm
;
;	exit_dos: Iesire in DOS
;
exit_dos	macro
	mov	ax,4c00h
	int	21h
endm
;
;	itoa: Conversia Intreg-ASCII
;
itoa	macro	dest,source
	push	ax
	push	di
	mov	ax,source		; Numar intreg
	lea	di,dest			; Adresa sir generat
	call	itoa_proc
	pop	di
	pop	ax
endm

;
;	atoi: Conversie ASCII-Intreg
;
atoi	macro	source
	push 	si
	lea	si,source		; Adresa sir
	call	atoi_proc		; Rezultat in AX
	pop	si
endm
;
;	inputs: Citire sir cu numar maxim admis de caractere
;
inputs	macro dest,length
	push	di
	push	cx
	lea	di,dest			; Adresa sir
	mov	cx,length		; Lungime maxima
	call	gets_proc
	pop	cx
	pop	di
endm
;
;	getc: Citire caracter
;
getc	macro
	call	getc_proc		; Caracter in AL
endm
;
;	puti: Afisare intreg cu semn
;
puti	macro	n
	push	n			; Intreg
	call	far ptr puti_proc
	add	sp,2
endm
;
;	putu: Afisare intreg fara semn
;
putu	macro	n
	push 	n			; Intreg
	call	far ptr putu_proc
	add	sp,2
endm
;
;	geti: Citire intreg
;
geti	macro
	local	buff
	.data
	buff	db	8 dup(0)
	.code
	inputs	buff,7		; Cel mult sapte cifre si semn
	atoi	buff		; ASCII-Intreg in AX
endm
;
;	getu: Citire intreg fara semn
;
getu	macro
	geti		; Este acelasi lucru cu geti
endm
;
;	puts: Afisare sir
;
puts	macro	x
	push	si
	lea	si,x		; Adresa sir
	call	puts_proc
	pop	si
endm
;
;	putsi: Afisare sir imediat (din aceeasi linia)
;
putsi	macro	x
	local	string
	.data
		string	db	x,0	; Sir definit local
	.code
		puts	string
endm
;
;	gets: Citeste sir de la consola
;
gets	macro	x
	inputs	x,80		; Cel mult 80 de caractere
endm
;
;	putc: Afisare un caracter
;
putc	macro	x
	push	ax
	mov	al,x
	call	far ptr putc_proc
	pop	ax
endm
;
;	getvec: Citeste vector de intrerupere
;
getvec	macro	oldint,n
	push	bx
	push	ax
	push	es
	mov	al,n		; Nivel
	mov	ah,35h		; Apel
	int	21h		; functie DOS
	mov	word ptr oldint,bx	; Adresa depunere
	mov	word ptr oldint+2,es	; vector citit
	pop	es
	pop	ax
	pop	bx
endm
;
;	setvec: Modifica vector de intrerupere
;
setvec	macro	newint,n
	push	ax
	push	ds
	push	dx
	mov	al,n		; Nivel
	lds	dx,newint	; Adresa vector nou
	mov	ah,25h		; Apel
	int	21h		; functie DOS
	pop	dx
	pop	ds
	pop	ax
endm
;
;	o_read: Deschide fisier pentru citire
;
o_read	macro	fname,hand
	mov	ah,3dh
	mov	al,0c0h		; Mod acces
	lea	dx,fname	; Nume fisier
	int	21h
	mov	hand,ax		; Depune handler
endm
;
;	o_write: Deschide fisier pentru scriere
;
o_write	macro	fname,hand
	mov	ah,3dh
	mov	al,0c1h		; Mod acces
	lea	dx,fname	; Nume fisier
	int	21h
	mov	hand,ax		; Depune handler
endm
;
;	o_creat: Creeaza fisier
;
o_creat	macro	fname,hand
	mov	ah,3ch
	mov	cx,0		; Atribute normale
	lea	dx,fname	; Nume fisier
	int	21h
	mov	hand,ax		; Depune handler
endm
;
;	f_read: Citeste date din fisier
;
f_read	macro	hand,buf,nr
	mov	bx,hand		; Handler
	mov	cx,nr		; Numar de octeti
	lea	dx,buf		; Buffer (destinatie)
	mov	ah,3fh
	int	21h
endm
;
;	f_write: Scrie date in fisier
;
f_write	macro	hand,buf,nr
	mov	bx,hand		; Handler
	mov	cx,nr		; Numar octeti
	lea	dx,buf		; Buffer (sursa)
	mov	ah,40h	
	int	21h		; AX = numar octeti
				; cititi efectiv
endm
;
;	f_close: Inchidere fisier
;
f_close	macro	hand
	mov	ah,3eh
	mov	bx,hand		; Handler
	int	21h
endm
;
;	set_dta: Fixeaza adresa zonei DTA
;
set_dta	macro 	dta
	mov	ah,1ah
	lea	dx,dta		; Adresa zonei DTA
				; (41 de octeti)
	int	21h
endm
;
; find_first: Determina primul fisier dintr-un nume generic
;
find_first	macro	name
	mov	ah,4eh
	lea	dx,name		; Nume generic
	mov	cx,0		; Atribute normale
	int	21h
endm
;
; find_next: Determina urmatorul fisier dintr-un nume generic
;
find_next	macro	dta_area
	mov	ah,4fh
	lea	dx,dta_area	; Adresa zonei DTA
	int	21h
endm

; Operatii de conversie
_atof macro a_sir, a_num
	push si
	lea si, a_sir
	push si
	lea si, a_num
	push si

	call far ptr atof_proc
	add sp, 4
	pop si
endm

_ftoa macro val, sir
	local x, maxim, minim, status, @@end, @@ftoa1, @@ftoa2
	
.data 	
	maxim  dd 2.147e09
	minim  dd 0.000001
	status dw 0
	x dd ?
.code 
	; incarcam parametrii in stiva
	push ax
	lea ax, sir
	push ax
	mov ax, word ptr val + 2
	push ax
	mov ax, word ptr val
	push ax
	
	fld dword ptr [val]
	fabs
	
	; comparam nr nostru in valoare absoluta cu maximul reprezentabil
	fcom maxim
	
	fstsw status
	fwait
	mov	ax, status
	sahf
	ja @@ftoa2
	
	; comparam nr nostru in valoare absoluta cu minimul reprezentabil
	fcomp minim
	
	fstsw status
	fwait
	mov	ax, status
	sahf
	jb @@ftoa2	
	
@@ftoa1:
	; desc
	fstp x
	; afisam nr in format normal
	call far ptr ftoa_proc
	jmp @@end
@@ftoa2:
	fstp x
	; afisam nr in format stiintific
	call far ptr ftoa_sc_proc
@@end:	
	add sp, 6
	pop ax
endm
	.sall
	.list