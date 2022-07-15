MAX_STRING_LENGTH = 2147483647
.code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stringLength proc uses rbx rdi
; finds the length of a null-terminated string
; receives: (rcx) BYTE PTR, a null-terminated string
; returns: (rax) DWORD, the size of that string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov al, 0 ; search for the null byte ('\0' is ASCII 0)
mov rdi, rcx ; string -> rdi
mov rbx, rcx ; string base address -> rbx
mov rcx, MAX_STRING_LENGTH

cld ; clear direction flag = increment rdi 
repnz scasb ; iterate through [rdi++] until the null byte is found

;move string pos into rax
sub rdi, rbx ; string length = null_byte_address - base_address
dec rdi ; subtract null-byte's length
mov rax, rdi 

ret
stringLength endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
findIndexOfChar proc uses rbx rdi
; searches for char in string
; receives: (rcx) BYTE PTR, a null-terminated string
;           (dl) BYTE, the char to find in string.
; returns: (rax) QWORD, the index of charToFind, or -1 (if not found)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov rax, 0 ; current index of string
mov bl, dl ; charToFind -> bl
mov rdi, rcx ; string -> rdi
 
Search:
cmp BYTE PTR [rdi + rax], bl ; string[rax] == charToFind 
jz Found
cmp BYTE PTR [rdi + rax], 0 ; end of string reached
jz NotFound 
inc rax
jmp Search

Found:
ret

NotFound:
mov rax, -1
ret

findIndexOfChar endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
findIndexOfString proc uses rbx rdi rsi r8 r9 r10
; searches for string in string
; receives: (rcx) BYTE PTR, haystack, a null-terminated string to search
;           (rdx) BYTE PTR, needle, a null-terminated string to find
; returns: (rax) QWORD, the index of needle, or -1 (if not found)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov rsi, rcx ; haystack -> rsi 
mov rdi, rdx ; needle -> rdi

; r8 = needleLength = stringLength(needle)
mov rcx, rdi ; needle -> rcx
sub rsp, 32 ; add shadow space
call stringLength
add rsp, 32 ; remove spadow space
mov r8, rax

; r9 = haystackLength = stringLength(haystack)
mov rcx, rsi ; haystack -> rcx
sub rsp, 32 ; add shadow space
call stringLength
add rsp, 32 ; remove spadow space
mov r9, rax

cmp r8, 0 ; needleLength == 0
je cannotFind ; can't find the needle if there is no needle

mov rax, 0 ; rax = haystack iterator
iterateThroughHaystack:
mov r10, r9 ; r10 = haystackLength
sub r10, rax ; r10 = haystackLength - i

cmp r8, r10 ; needleLength, haystackLength - i 
jg cannotFind ; if needleLength exceeds the remaining haystack (haystackLength-i),
              ; needle cannot be in haystack. return -1.


mov rbx, 0 ; rbx = needle iterator
iterateThroughNeedle:
mov rcx, rax 
add rcx, rbx ; rcx = rax + rbx
mov dl, BYTE PTR [rsi + rcx] ; haystack[haystackIterator + needleIterator]
mov dh, BYTE PTR [rdi + rbx] ; needle[needleIterator]

cmp dl, dh
jne doneIteratingThroughNeedle ; haystack[haystackIterator] is not a match.

inc rbx
cmp rbx, r8 ; needle iterator, needleLength 
jl iterateThroughNeedle
je matchFound

doneIteratingThroughNeedle:
inc rax ; haystackIterator
cmp rax, r9 ; haystackIterator, haystackLength
jl iterateThroughHaystack

cannotFind:
mov rax, -1
ret

matchFound:
ret
findIndexOfString endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getSubstring proc uses rsi rdi
; copies the specified portion of a string to another string.
; receives: (rcx) BYTE PTR stringIn
;           (rdx) BYTE PTR stringOut
;           (r8) DWORD start index
;           (r9) DWORD end index (non-inclusive)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov rsi, rcx ; stringIn -> rsi
mov rdi, rdx ; stringOut -> rdi

add rsi, r8 ; stringIn += start index
sub r9d, r8d ; end index -= start index -> numCharsToCopy
jz done ; numCharsToCopy == 0
js done ; numCharsToCopy < 0
xor rcx, rcx ; zero rcx
mov ecx, r9d ; numCharsToCopy -> rcx

cld
rep movsb

done:
mov BYTE PTR [rdi], 0 ; terminate substring with null byte ('\0')
ret
getSubstring endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setBytes proc uses rdi
; sets numBytes bytes to value at location
; receives: (rcx) QWORD location, where to set bytes
;           (dl) BYTE value, value to set bytes
;           (r8) DWORD numBytes, number of bytes to set
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov rdi, rcx ; location -> rdi
mov rcx, r8 ; numBytes -> rcx
mov al, dl ; value -> accumulator

cld
rep stosb

ret
setBytes endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stringCopy proc uses rsi rdi
; copies sourceStr to destStr
; receives: (rcx) BYTE PTR destStr, string to be copied to
;           (rdx) BYTE PTR sourceStr, string to be copied from
; returns: (rax) QWORD, number of characters successfuly copied
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov rdi, rcx ; destStr -> rdi 
mov rsi, rdx ; sourceStr -> rsi

; rax = stringLength(sourcStr)
mov rcx, rdx ; sourceStr -> rcx
sub rsp, 32 ; add shadow space
call stringLength
add rsp, 32 ; remove shadow space


mov rcx, rax
inc rcx ; also copy null byte

cld
rep movsb

ret
stringCopy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stringToUppercase proc
; converts all alphabetical characters in string to uppercase.
; receives: (rcx) BYTE PTR string, the string to convert 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

iterateThroughString:
mov al, BYTE PTR [rcx]
cmp al, 0 ; *string == '/0'
je finished

cmp al, 'a' ; *rcx < 'a' ?
jb continue

cmp al, 'z' ; *rcx > 'z' ?
ja continue

xor al, 32 ; convert to lowercase
mov BYTE PTR [rcx], al ; store char back in string

continue:
inc rcx
jmp iterateThroughString

finished:
ret
stringToUppercase endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stringToLowercase proc
; converts all alphabetical characters in string to lowercase.
; receives: (rcx) BYTE PTR string, the string to convert 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

iterateThroughString:
mov al, BYTE PTR [rcx]
cmp al, 0 ; *string == '/0'
je finished

cmp al, 'A' ; *rcx < 'A' ?
jb continue

cmp al, 'Z' ; *rcx > 'Z' ?
ja continue

or al, 32 ; convert to uppercase
mov BYTE PTR [rcx], al ; store char back in string

continue:
inc rcx
jmp iterateThroughString

finished:
ret
stringToLowercase endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
countCharsInString proc
; counts the number of instances of ch in string
; receives: (rcx) BYTE PTR string, to search of instances for ch
;           (dl) BYTE ch, the character to search string for.
; returns: (rax) QWORD, count of ch in string. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov rax, 0 ; rax = count
iterateThroughString:

cmp BYTE PTR [rcx], 0 ; *string == '/0'
je done

cmp BYTE PTR [rcx], dl ; *string == ch
jne continue 
inc rax

continue:
inc rcx ; string++
jmp iterateThroughString

done:
ret
countCharsInString endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stringConcat proc uses rdi rsi
; concatenates string1 and string2 - appends string2 to the end of string1
; receives: (rcx) BYTE PTR string1, string to be appended to
;           (rdx) BYTE PTR string2, string to be appended
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov al, 0 ; al = '\0'

mov rdi, rcx ; string1 -> rdi
mov rcx, MAX_STRING_LENGTH
cld ; clear direction flag
repnz scasb ; advance string1 until *(string1++) == '\0'
dec rdi ; adjust for overshoot

mov rsi, rdx ; string2 -> rsi

copyAnother:
cmp BYTE PTR [rsi], 0 ; *string2 == '\0'
je done

mov al, BYTE PTR [rsi] ; *string2 -> al
mov BYTE PTR [rdi], al ; al -> *string1

inc rsi ; string2++
inc rdi ; string1++
jmp copyAnother

done:
mov BYTE PTR [rdi], 0 ; truncate the resulting string with '\0'
ret
stringConcat endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reverseString proc
; reverses a string.
; receives: (rcx) BYTE PTR string, the string to reverse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; string length -> rax
push rcx
sub rbp, 32 ; add shadow space
call stringLength
add rbp, 32 ; remove shadow space
pop rcx

add rax, rcx ; rax = end of string ('\0'), rcx = string
dec rax ; rax -> last char in string

swapTwo:
; while rax > rcx
cmp rax, rcx
jng done

; swap [rax] and [rcx]
mov dl, BYTE PTR [rax]
xchg byte PTR [rcx], dl
mov BYTE PTR [rax], dl

inc rcx
dec rax
jmp swapTwo

done:
ret
reverseString endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
compareStrings proc
; lexographically compares string1 to string2
; receives: (rcx) BYTE PTR string1, one string to compare
;           (rdx) BYTE PTR string2, the other string to compare
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

advanceWhileEqual:
cmp BYTE PTR [rcx], 0 ; *str1 == '\0'
je done
cmp BYTE PTR [rdx], 0 ; *str2 == '\0'
je done

mov al, BYTE PTR [rcx]
cmp al, BYTE PTR [rdx] ; *str1 == *str2
jne done

inc rcx
inc rdx
jmp advanceWhileEqual

done:
;return *str1 > *str2
movzx rax, BYTE PTR [rcx]
movzx rdx, BYTE PTR [rdx]
sub rax, rdx
ret
compareStrings endp

end
