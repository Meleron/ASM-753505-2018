.model tiny
.386
.data
    ;���������
    enterSymbol=0Dh ;������� �������
    backspaceChar=8 ;��� backspaceChar'�
    space=20h ;������
    
.code

org 100h

interruptVector label word

main:
    jmp initialize
    mov ax, 4c00h
    int 21h
    vowelsList  db 'AEIOUYaeiouy'
    
intIntercept proc far
    cmp ah, 0Ah
    je  handleFunc
    jmp dword ptr cs:[interruptVector] ;������������� �� �����, ������ cs+�����, �� ������� ��������� interruptVector
handleFunc:
    push es
    push bx
    push cx
    push di
    push dx
    
    xor cx, cx
    mov bx, dx      ;bx - ����� �� ������ ������ (�����:[�����],[��-� 1], [��-� 2], ..., [��-� n])
    mov di, 1       ;��������� �� ������
    mov cl, [bx]    ;������ ������ (��� ������ �������)
    inc bx          ;bx - ����� ������� ������� � ������
    cmp cx, 0
    je handleStop   ;���� ����� ������ = 0
    mov ax, 0d00h   ;����� ������ ������������� 0dh
    mov [bx], ax
    dec cx
    jz handleStop
    push cs
    pop es          ;�������� � ������� es ������� cs, �.�. ��� ��������� �������� ���������� ����������� ������� es (��� repne)
    
srtingInput:
    call charInput
    cmp al, enterSymbol
    je endOfInput   ;���� ����� enter, �� ��������� ����
    cmp al, backspaceChar
    je backSpace
    call buffering  ;����� ���������� � �����
    call printChar
    call isVowel
    jnz srtingInput ;���� repne ��������� ������� �����, �� ���� jz ����� ����� 0 (repne �������� �� �������� ���������)
    call buffering
    jc srtingInput
    call printChar
    jmp srtingInput
    
backSpace:          ;���� ������������ ��� backspace
    cmp di, 1
    je srtingInput
    mov [bx+si], byte ptr enterSymbol
    dec di
    dec byte ptr [bx]
    call printChar
    mov al, space
    call printChar
    mov al, backspaceChar
    call printChar
    jmp srtingInput
    
endOfInput:
    mov [bx+di], al
    call printChar
    
handleStop:
    pop dx
    pop di
    pop di
    pop bx
    pop es
    iret            ;������� ������� ip, ���������� ������� cs � ������� ������ �� �����, ����� ������� ���������� ������� ���������� �� �����, ������� ��������� � ���� ������� int...
intIntercept endp

buffering proc
    inc byte ptr [bx]
    mov [bx+di], al
    mov byte ptr [bx+di+1], enterSymbol
    inc di
    ret
buffering endp

printChar proc
    push ax
    push dx
    mov dl, al
    mov ah, 2
    int 21h
    pop dx
    pop ax
    ret
printChar endp

charInput proc      ;���� ������� ��� ������ ��� �� �����
    mov ah, 8
    int 21h         ;al - �������� ������
    ret
charInput endp

isVowel proc
    push cx
    push di
    mov di, offset vowelsList
    mov cx, 12
    repne scasb     ;���������� ���������� al � ���������� �� ������ es:di
    pop di
    pop cx
    ret
isVowel endp

printString proc
    push ax
    mov ah, 09h
    xchg dx, di
    int 21h
    xchg dx, di
    pop ax
    ret
printString endp

initialize proc
    mov ax, 3521h
    int 21h
    mov [interruptVector], bx
    mov [interruptVector+2], es
    mov dx, offset intIntercept
    mov ax, 2521h
    int 21h
    mov dx, offset initialize
    int 27h         ;���������� ���������� DOS, �������� ����� ������ ��������������, ��� ��� ����������� ��������� �� ����� ����������� ����������� ��� ��� ������ � ���� ������. (�����������, �� �������� �����������)       
initialize endp

end main