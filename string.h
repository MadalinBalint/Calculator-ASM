
extrn strlen_proc:far
extrn strcat_proc:far
extrn strchr_proc:far
extrn memset_proc:far
extrn strcmp_proc:far
extrn atof_proc:far

strlen macro s, len	
    lea di, s
	call strlen_proc
	mov [len], ax	
endm

strcat macro dest, source
    lea di, dest
	lea si, source
	call far ptr strcat_proc
endm

strchr macro s, c, gasit
	lea si, s
	mov ah, c
	call far ptr strchr_proc
	mov [gasit], al
endm

memset macro s, c, count
	mov al, c
	lea di, s
	mov cx, count
	call far ptr memset_proc
endm

; pos din source
strpcat macro dest, source, pos
    lea di, dest
	lea si, source
	add si, pos
	call far ptr strcat_proc
endm

; compara 2 siruri
strcmp macro cs, ct, gasit
    lea si, cs
	lea di, ct
	call far ptr strcmp_proc
	mov [gasit], ax
endm

; str delete last character
strdlc macro source
	local @@sfarsit
	
	lea di, source
	call far ptr strlen_proc	
	; Daca sirul are lungimea 0, terminam operatia
	cmp ax, 0
	je @@sfarsit
	
	; Punem la sfarsitul sirului 0
	lea si, source	
	add si, ax
	dec si
	mov byte ptr [si], 0
@@sfarsit:
endm

; str delete zero
strdz macro source
	local @@sfarsit, @@again, @@go_on, stiintific
.data
	stiintific db 0
.code
	strchr source, 'E', stiintific
	cmp byte ptr [stiintific], 1
	je @@sfarsit

	lea di, source
	call far ptr strlen_proc	
	; Daca sirul are lungimea 0, terminam operatia
	cmp ax, 0
	je @@sfarsit	
	
	; Punem la sfarsitul sirului 0
	lea si, source	
	add si, ax
	dec si 
@@again:
	cmp byte ptr [si], '.'
	jne @@go_on
	mov byte ptr [si], 0
	jmp @@sfarsit
@@go_on:	
	cmp byte ptr [si], '0'
	jne @@sfarsit
	cmp ax, 1
	je @@sfarsit
	mov byte ptr [si], 0
	dec si
	dec ax
	jmp @@again	
@@sfarsit:	
endm