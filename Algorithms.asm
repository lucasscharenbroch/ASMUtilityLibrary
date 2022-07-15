INT_MAX = 2147483647
INT_MIN = -2147483648
.code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
binarySearch proc
; searches array for target, returns the index or -1 (if not found). 
; receives: (rcx) DWORD PTR array, a pointer to an array of 32-bit integers
;           (rdx) QWORD size, the size of the array
;           (r8) QWORD target, the integer to search for
; returns: (rax) QWORD index, the index of target in array (or -1 if not found)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov rbx, 0 ; rbx -> start
           ; rdx -> end (non-inclusive)

search:
cmp rbx, rdx ; start, end
jae doneSearching

; r9 = mid
mov r9, rbx
add r9, rdx ; r9 = start + end
shr r9, 1   ; r9 = (start + end) / 2

cmp DWORD PTR [rcx + r9 * 4], r8d ; target, array[mid]
je foundMatch
ja above 

; below
mov rbx, r9 ; rbx = mid
inc rbx     ; rbx = mid + 1
jmp search

above:
mov rdx, r9 ; end = mid
jmp search

foundMatch:
mov rax, r9 ; return mid
ret

doneSearching:
mov rax, -1 
ret
binarySearch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
swap proc
; swaps the values of the two pointer parameters.
; receives: (rcx) QWORD a, a pointer to the first item to be swapped
;           (rdx) QWORD b, a pointer to the second item to be swapped
;           (r8) QWORD size, the size, in bytes, of a and b.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

copyAByte:
; swap a byte
mov al, BYTE PTR [rcx]
xchg al, BYTE PTR [rdx]
mov BYTE PTR [rcx], al

inc rcx
inc rdx
dec r8
jnz copyAByte

ret
swap endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nsum proc
; calculates the sum of an arbitrary number of integer arguments 
; receives: (rcx) QWORD numAddends, the number of trailing arguments to add together
;           (rdx, r8, r8, stack...) VARARGS addends, the addends to add
; returns: (rax) the sum
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
push rbp
mov rbp, rsp

mov rax, 0 ; rax = sum

and rcx, rcx ; if numAddends == 0
jz done      ; return 0

; move registers into the shadow space
mov [rbp + 24], rdx
mov [rbp + 32], r8
mov [rbp + 40], r9

mov rdx, 24 ; rdx = offset from rbp to the addend

addAnother:
add rax, [rbp + rdx]

add rdx, 8
loop addAnother

done:
pop rbp
ret
nsum endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nmin proc
; calculates the minimum of an arbitrary number of integer arguments 
; receives: (rcx) QWORD numOperands, the number of trailing integer operands 
;           (rdx, r8, r8, stack...) VARARGS operands
; returns: (rax) the minimum operand
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
push rbp
mov rbp, rsp

; int_max -> eax
mov eax, INT_MAX

and ecx, ecx ; if numOperands == 0
jz done      ; return int_max

; move registers into the shadow space
mov [rbp + 24], rdx
mov [rbp + 32], r8
mov [rbp + 40], r9

mov rdx, 24 ; rdx = offset from rbp to the addend

checkAnother:
cmp eax, DWORD PTR [rbp + rdx]
jle next

mov rax, [rbp + rdx]

next:
add rdx, 8
loop checkAnother

done:
pop rbp
ret
nmin endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nmax proc
; calculates the maximum of an arbitrary number of integer arguments 
; receives: (rcx) QWORD numOperands, the number of trailing integer operands
;           (rdx, r8, r8, stack...) VARARGS operands
; returns: (rax) the maximum operand
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
push rbp
mov rbp, rsp

; int_min -> eax
mov eax, INT_MIN

and ecx, ecx ; if numOperands == 0
jz done      ; return int_min

; move registers into the shadow space
mov [rbp + 24], rdx
mov [rbp + 32], r8
mov [rbp + 40], r9

mov rdx, 24 ; rdx = offset from rbp to the addend

checkAnother:
cmp eax, DWORD PTR [rbp + rdx]
jge next

mov rax, [rbp + rdx]

next:
add rdx, 8
loop checkAnother

done:
pop rbp
ret
nmax endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
naverage proc
; calculates the average of an arbitrary number of integer arguments 
; receives: (rcx) QWORD numOperands, the number of trailing integer operands
;           (rdx, r8, r8, stack...) VARARGS operands
; returns: (rax) the average of the operands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmp rcx, 0
jne regularProcedure
mov rax, 0 ; return zero for zero arguments
ret

regularProcedure:
push rcx
sub rsp, 32 ; add shadow space
call nsum ; sum -> rax
add rsp, 32 ; remove spadow space
pop rcx

and rdx, 0 ; zero rdx
div ecx ; rax = rdx:rax / rcx

ret
naverage endp

end