extern puts
extern printf
extern strlen
section .data
filename: db "./input.dat",0
inputlen: dd 2263
fmtstr: db "Key: %d",0xa
 
section .text
global main

xor_strings:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8] 
    mov edi, [ebp + 12]
    
    push eax
    call strlen
    mov ecx, eax ; ecx is length of strings
    pop eax
    
    xor ebx, ebx
    xor edx, edx
;xor_each_char is a loop in which those two strings(source and key) are xor(ed) byte by byte which will
;result in the decodified string
xor_each_char:
    mov dl, byte [eax + ebx]
    mov dh, byte [edi + ebx]
    xor dl,dh
    mov byte [eax + ebx], dl
    
    inc ebx
    cmp ebx,ecx
    jne xor_each_char
    
    leave
    ret

rolling_xor:
    push ebp
    mov ebp,esp
    mov eax, [ebp + 8]
    
    push eax
    call strlen
    mov ecx, eax ; ecx is length of string3
    pop eax
    
    
    xor ebx, ebx
    mov edx, ecx
    dec edx

    ;xor_roll loop takes the string from the end to the beginning and does the conversion algorithm presented
    ;in the task which will result in the decodified string
xor_roll:
    mov bh, byte [eax + edx]
    mov edi, edx
    dec edi
    mov bl, byte [eax + edi]
    xor bl, bh
    mov byte [eax + edx], bl
    
    dec edx
    jnz xor_roll
    
    leave
    ret
    
    

xor_hex_strings:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    mov edi, [ebp + 12]
    
    push eax
    call strlen
    mov ecx, eax ; ecx is length of strings
    pop eax
    
    shr ecx, 1
    xor edx, edx
    xor ebx, ebx
    xor esi, esi
    
    ;loop xor_hex used for taking groups of 2 bytes from the source string and transforming them into one
    ;single byte by converting them into binary form
xor_hex:
    mov dl, byte [eax + esi]
    inc esi
    mov dh, byte [eax + esi]
    dec esi
    cmp dl, 61
    jb digit
    cmp dl, 61
    jge letter
 cont: 
    shl dl, 4
    add dl, dh
    push ecx
    mov cl, byte [edi + esi]
    inc esi
    mov ch, byte [edi + esi]
    dec esi
    cmp cl, 61
    jb digit2
    cmp cl, 61
    jge letter2
 cont2:   
    shl cl, 4
    add cl, ch
      
    xor dl, cl
    mov byte [eax + ebx], dl
    add esi, 2
    inc ebx
    pop ecx
    cmp ebx, ecx
    jnz xor_hex
    
    
    
    mov byte [eax + ecx], 0x0
    leave
    ret
    
    
digit:
    sub dl, 48
    cmp dh, 61
    jb digit1
    cmp dh, 61
    jge letter1
    
letter:
    sub dl, 87
    cmp dh, 61
    jb digit1
    cmp dh, 61
    jge letter1
digit1:
    sub dh, 48
    jmp cont
letter1:
    sub dh, 87
    jmp cont
    
digit2:
    sub cl, 48
    cmp ch, 61
    jb digit3
    cmp ch, 61
    jge letter3
    
letter2:
    sub cl, 87
    cmp ch, 61
    jb digit3
    cmp ch, 61
    jge letter3
digit3:
    sub ch, 48
    jmp cont2
letter3:
    sub ch, 87
    jmp cont2
    


base32decode:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    
    push eax
    call strlen
    mov ecx, eax ; ecx is length of string
    pop eax
        
    xor ebx, ebx
    xor edx, edx
    xor esi, esi
    xor edi, edi
    ;loop used for taking groups of 8 bytes in the string and converting them to groups of 5 correct bytes
    ;that will be replaced in the string on stack
loop32:   
    mov bl, [eax + esi]
    cmp bl, 0x32
    jb letter32_1
    cmp bl, 0x37
    ja letter32_1
    sub bl, 24  

continue32_1:
    shl bl, 3
    mov dl, bl
    
    inc esi
    mov bl, [eax + esi]
    cmp bl, 0x32
    jb letter32_2
    cmp bl, 0x37
    ja letter32_2
    sub bl, 24
    
continue32_2:    
    mov bh, bl; bh is copy of bl
    mov dh, 0x1c; dh is mask
    and bl, dh
    shr bl, 2
 
    add dl, bl
    
    mov byte [eax + edi], dl
    
    mov dh, 0x03
    and bh, dh
    shl bh, 6
    
    inc esi
    mov bl, [eax + esi]
    cmp bl, 0x32
    jb letter32_3
    cmp bl, 0x37
    ja letter32_3
    sub bl, 24
continue32_3:       
    shl bl, 1
    and bl, 0x3e
    add bh, bl
    
    inc esi
    mov bl, [eax + esi]
    cmp bl, 0x32
    jb letter32_4
    cmp bl, 0x37
    ja letter32_4
    sub bl, 24
    
continue32_4:
    mov dl, bl; dl is copy of bl
    mov dh, 0x10
    and bl, dh
    shr bl, 4
    add bh, bl
    
    inc edi
    mov byte [eax + edi], bh
    
    mov dh, 0x0f
    and dl, dh
    shl dl, 4
    
    inc esi
    mov bl, [eax + esi]
    cmp bl, 0x32
    jb letter32_5
    cmp bl, 0x37
    ja letter32_5
    sub bl, 24
    
continue32_5:
    mov bh, bl; bh is copy of bl
    mov dh, 0x1e
    and bl, dh
    shr bl, 1
    add dl, bl
    
    inc edi
    mov byte [eax + edi], dl
    
    mov dh, 0x01
    and bh, dh
    shl bh, 7
    
    inc esi
    mov bl, [eax + esi]
    cmp bl, 0x32
    jb letter32_6
    cmp bl, 0x37
    ja letter32_6
    sub bl, 24

continue32_6:   
    shl bl, 2
    and bl, 0x7c
    add bh, bl 
    
    inc esi
    mov bl, [eax + esi]
    cmp bl, 0x32
    jb letter32_7
    cmp bl, 0x37
    ja letter32_7
    sub bl, 24

continue32_7:
    mov dl, bl; dl is copy of bl
    mov dh, 0x18
    and bl, dh
    shr bl, 3
    add bh, bl
    
    inc edi
    mov byte [eax + edi], bh
    
    mov dh, 0x07
    and dl, dh
    shl dl, 5
    
    inc esi
    mov bl, [eax + esi]
    cmp bl, 0x32
    jb letter32_8
    cmp bl, 0x37
    ja letter32_8
    sub bl, 24

continue32_8:
    add dl, bl
    inc edi
    mov byte [eax + edi], dl

    inc esi
    inc edi
    
    cmp esi, ecx
    jb loop32

    leave
    ret
    
;flags used for converting the bytes in the string into base32 index from 0-31

letter32_1:
    cmp bl, 0x41
    jb zeros_1
    cmp bl, 0x5A
    ja zeros_1
    
    sub bl, 65
    jmp continue32_1
    
zeros_1:
    mov bl, 0x0
    jmp continue32_1
    
letter32_2:
    cmp bl, 0x41
    jb zeros_2
    cmp bl, 0x5A
    ja zeros_2
    
    sub bl, 65
    jmp continue32_2
    
zeros_2:
    mov bl, 0x0
    jmp continue32_2
    
letter32_3:
    cmp bl, 0x41
    jb zeros_3
    cmp bl, 0x5A
    ja zeros_3
    
    sub bl, 65
    jmp continue32_3
    
zeros_3:
    mov bl, 0x0
    jmp continue32_3
    
letter32_4:
    cmp bl, 0x41
    jb zeros_4
    cmp bl, 0x5A
    ja zeros_4
    
    sub bl, 65
    jmp continue32_4
    
zeros_4:
    mov bl, 0x0
    jmp continue32_4
    
letter32_5:
    cmp bl, 0x41
    jb zeros_5
    cmp bl, 0x5A
    ja zeros_5
    
    sub bl, 65
    jmp continue32_5
    
zeros_5:
    mov bl, 0x0
    jmp continue32_5 
    
letter32_6:
    cmp bl, 0x41
    jb zeros_6
    cmp bl, 0x5A
    ja zeros_6
    
    sub bl, 65
    jmp continue32_6
    
zeros_6:
    mov bl, 0x0
    jmp continue32_6 

letter32_7:
    cmp bl, 0x41
    jb zeros_7
    cmp bl, 0x5A
    ja zeros_7
    
    sub bl, 65
    jmp continue32_7
    
zeros_7:
    mov bl, 0x0
    jmp continue32_7 
    
letter32_8:
    cmp bl, 0x41
    jb zeros_8
    cmp bl, 0x5A
    ja zeros_8
    
    sub bl, 65
    jmp continue32_8
    
zeros_8:
    mov bl, 0x0
    jmp continue32_8 
    
bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    
    push eax
    call strlen
    mov ecx, eax
    pop eax
    xor edi, edi
    
    ;xor each char in the string with the key
xor_bruteforce:
    mov bh, [eax + edi]
    xor bh, bl
    mov byte [eax + edi], bh
    inc edi
    cmp edi,ecx
    jnz xor_bruteforce
     
    leave
    ret
    
main:
    push ebp
    mov ebp, esp
    sub esp, 2300
    
    ; fd = open("./input.dat", O_RDONLY);
    mov eax, 5
    mov ebx, filename
    xor ecx, ecx
    xor edx, edx
    int 0x80
    
	; read(fd, ebp-2300, inputlen);
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	; close(fd);
	mov eax, 6
	int 0x80
        
        xor ebx, ebx
        ; all input.dat contents are now in ecx (address on stack)
        
	; TASK 1: Simple XOR between two byte streams
	; TODO: compute addresses on stack for str1 and str2
	; TODO: XOR them byte by byte
	;push addr_str2
	;push addr_str1
	;call xor_strings
	;add esp, 8

         push ecx
         call strlen
         pop ecx ; eax is length of string1
         lea edx, [ecx + eax + 1] ;edx is string 2
         push edx
         push ecx
         call xor_strings
         pop ecx
         pop edx
        
        ;Print the first resulting string
	;push addr_str1
	;call puts
	;add esp, 4

         push edx
         push ecx
         call puts
         add esp, 4
         pop ecx
         
         ; TASK 2: Rolling XOR
	; TODO: compute address on stack for str3
	; TODO: implement and apply rolling_xor function
	;push addr_str3
	;call rolling_xor
	;add esp, 4
         
         push ecx
         call strlen
         pop ecx ; eax is length of string2
         lea edx, [ecx + eax + 1] ;edx is string 3
         push edx
         call rolling_xor
         pop edx
         
          ; Print the second resulting string
	;push addr_str3
	;call puts
	;add esp, 4

         push edx
         call puts
         pop edx
         
         ; TASK 3: XORing strings represented as hex strings
	; TODO: compute addresses on stack for strings 4 and 5
	; TODO: implement and apply xor_hex_strings
	;push addr_str5
	;push addr_str4
	;call xor_hex_strings
	;add esp, 8

         push edx
         call strlen
         pop edx; eax is length of string3
         
         lea edx, [edx + eax + 1] ;edx is string 4
         
         push edx
         call strlen
         pop edx; eax is length of string4
         
         lea ecx, [edx + eax + 1] ;ecx is string 5
         
         push ecx
         push edx
         call xor_hex_strings
         pop edx
         pop ecx
         
         ; Print the third string
	;push addr_str4
	;call puts
	;add esp, 4

         push ecx
         push edx
         call puts
         pop edx
         pop ecx
         
         ; TASK 4: decoding a base32-encoded string
	; TODO: compute address on stack for string 6
	; TODO: implement and apply base32decode
	;push addr_str6
	;call base32decode
	;add esp, 4
         
         push ecx
         call strlen
         pop ecx; eax is length of string5
         lea ecx, [ecx + eax + 1] ; ecx is string6
         
         push ecx
         call strlen
         pop ecx; eax is length of string6 - used for task 5
         push eax
         
         push ecx
         call base32decode
         pop ecx
        
	; Print the fourth string
	;push addr_str6
	;call puts
	;add esp, 4

         push ecx
         call puts
         pop ecx
         
         ; TASK 5: Find the single-byte key used in a XOR encoding
	; TODO: determine address on stack for string 7
	; TODO: implement and apply bruteforce_singlebyte_xor
	;push key_addr
	;push addr_str7
	;call bruteforce_singlebyte_xor
	;add esp, 8

         pop eax ;- length of string6 
         lea ecx, [ecx + eax + 1] ; ecx is string7
         
         push ecx
         call strlen
         pop ecx ; eax is length of string7
         
         xor ebx, ebx
         xor edx, edx
         push edi
         push esi
         xor edi, edi
         xor esi, esi; flag used for checking if the word "force" was found
         mov dl, -1 ; key which goes from 0 to 0xFF - trial and error
         
loop1: ;loop used for taking each key
         inc dl
loop2: ;loop used for taking each char in the string in groups of 5 and xoring them with the key
       ;to check if they are equal to "force"
         mov dh, [ecx + edi]
         xor dh, dl
         cmp dh, 0x66 ; check if == 'f'
         jz flag1
continue_1:         
         inc edi
         mov dh, [ecx + edi]
         xor dh, dl
         cmp dh, 0x6f ; check if == 'o'
         jnz flag2
continue_2:
         inc edi
         mov dh, [ecx + edi]
         xor dh, dl
         cmp dh, 0x72 ; check if == 'r'
         jnz flag3
continue_3:
         inc edi
         mov dh, [ecx + edi]
         xor dh, dl
         cmp dh, 0x63 ; check if == 'c'
         jnz flag4
continue_4:        
         inc edi
         mov dh, [ecx + edi]
         xor dh, dl
         cmp dh, 0x65 ; check if == 'e'
         jnz flag5
continue_5:    
         cmp esi, 1 
         jz found
         sub edi, 3
         cmp edi, eax
         jnz loop2
         
         xor edi, edi
         
         cmp dl, 0xff
         jnz loop1
         
         jmp exit
         
;flags used for modifying the flag accordingly   
             
flag1:
         mov esi, 1 
         jmp continue_1 
flag2:
         mov esi, 0  
         jmp continue_2
flag3:
         mov esi, 0  
         jmp continue_3  
flag4:
         mov esi, 0  
         jmp continue_4
flag5:
         mov esi, 0  
         jmp continue_5
found:
        xor eax, eax
        mov al, dl ;save the key if it is the right one
exit:
        
        pop esi
        pop edi
        
        push eax
        push ecx
        call bruteforce_singlebyte_xor
        pop ecx
        pop eax
        
        push eax; save key
        
        ; Print the fifth string and the found key value
	;push addr_str7
	;call puts
	;add esp, 4

        push ecx
        call puts
        pop ecx
        
        pop eax; restore key
        
        ;push keyvalue
	;push fmtstr
	;call printf
	;add esp, 8

        push eax
        push fmtstr
        call printf
        add esp, 8
        
        xor eax, eax
        leave
        ret
