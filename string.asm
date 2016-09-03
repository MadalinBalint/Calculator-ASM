; Fisier pentru operatii cu string-uri
.286
.model large

public strlen_proc, strcat_proc, strchr_proc
public memset_proc
public strcmp_proc

.code

strlen_proc proc far
	xor cx, cx
	not cx
	xor ax, ax
	cld
	repne scasb
	not cx
	dec cx
	
    mov ax, cx

	retf
strlen_proc endp

strcat_proc proc far
	xor cx, cx
	not cx
	xor ax, ax
	cld
	repne scasb
	dec di
_1: lodsb
	stosb
	test al, al
	jne _1

	retf
strcat_proc endp

strchr_proc proc far
	cld
again:
    mov al, [si]
	cmp al, 0
	je final
	cmp al, ah
	je gasit
	inc si
	jmp again
gasit:
    mov al, 1
final:
	retf
strchr_proc endp

memset_proc proc far
	cld
	rep
	stosb
	retf
memset_proc endp

strcmp_proc proc far
scloop:
    mov al, [si]
    mov bl, [di]    
    sub al, bl      
    jne scdone      
    cmp bl,0        
    jz  scdone      
    inc si
    inc di          
    jmp scloop
scdone:
    cbw
	retf
strcmp_proc endp

end