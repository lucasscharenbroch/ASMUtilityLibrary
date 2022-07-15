.code
;;; C function prototypes
rand proto
printf proto

;;; asm function prototypes
swap proto

;;; macros
pushArgRegs macro
    push rcx
    push rdx
    push r8
    push r9
endm

popArgRegs macro
    pop r9
    pop r8
    pop rdx
    pop rcx
endm


;;; functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reverseArray proc uses rbx rdi rsi r9 r10 r11
; reverses an array
; receives: (rcx) QWORD array, address of the array
;           (rdx) DWORD elementSize, size (in bytes) of an element
;           (r8) DWORD numElements, number of elements in the array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov rax, r8 ; rax = numElements
shr rax, 1 ; rax = numElements / 2

mov rbx, 0 ; currentIndex
swapElements:
cmp rbx, rax ; currentIndex == numElements / 2
je done

; swap array[currentIndex] and arr[length-currentIndex-1]
mov rsi, rbx ; rsi = currentIndex
imul rsi, rdx ; rsi = currentIndex * elementSize
add rsi, rcx ; rsi = array[currentIndex]

mov rdi, r8 ; rdi = arrayLength
dec rdi ; rdi = arrayLength - 1
sub rdi, rbx ; rdi = arrayLength - currentIndex - 1
imul rdi, rdx ; rdi = (arrayLength - currentIndex - 1) * elementSize 
add rdi, rcx ; rdi = array[length-currentIndex-1]

mov r9, rdx ; r9 = num bytes to copy 
swapAByte:
; swap byte ptr [rsi] and byte ptr [rdi]
mov r10b, BYTE PTR [rsi] 
mov r11b, BYTE PTR [rdi]
xchg r10b, r11b
mov BYTE PTR [rsi], r10b
mov BYTE PTR [rdi], r11b

inc rsi
inc rdi
sub r9, 1
jnz swapAByte

inc rbx ; currentIndex++
jmp swapElements

done:
ret
reverseArray endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
joinArrays proc uses r10
; appends array2 to the end of array1
; receives: (rcx) QWORD array1, address of the first array
;           (rdx) QWORD array2, address of the second array
;           (r8) DWORD array1Length, the number of elements in the first array
;           (r9) DWORD array2Length, the number of elements in the second array
;           ([ebp + 56]) DWORD elementSize, the size of an element (in both arrays)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
push rbp
mov rbp, rsp

xor rax, rax ; zero rax
mov eax, DWORD PTR [rbp + 56] ; rax = elementSize
mov r10, rax ; r10 = elementSize
imul r10, r8 ; r10 = elementSize * array1Length 
add rcx, r10 ; array1 += array1Length

; r10d = number of bytes to be copied
mov r10, r9  ; r10d = array2Length
imul r10, rax ; r10d = array2Length * elementSize

copyAByte:
mov al, BYTE PTR [rdx]
mov BYTE PTR [rcx], al

inc rcx
inc rdx
sub r10, 1
jnz copyAByte

pop rbp
ret
joinArrays endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
searchArray proc uses r10 rdi
; searches array for elementToFind, returns the first index, or -1 (if not found)
; receives: (rcx) QWORD array, the array to search 
;           (rdx) DWORD elementSize, the size (in bytes) of each element in the array
;           (r8) DWORD numElements, the number of elements in the array
;           (r9) QWORD elementToFind, a pointer to the element to search for.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

test r8, r8
jz notFound
mov r10, 0 ; array iterator

nextElement:
mov rbx, 0 ; number of bytes that match

nextByte:
cmp rbx, rdx ; numMatchedBytes, numBytesPerElement
je found

mov rdi, r10 ; currentIndex -> rdi
imul rdi, rdx ; currentIndex * elementSize -> rdi
add rdi, rcx ; rdi = array[i]
mov al, BYTE PTR [rdi + rbx] ; array[i] + currentByteIndex
cmp al, BYTE PTR [r9 + rbx] ; target element + currentByteIndex
jne continueToNextIndex ; array[i] does not match target
inc rbx
jmp nextByte

continueToNextIndex:
inc r10
cmp r10, r8 ; i == length
jnz nextElement

notFound:
mov rax, -1
ret

found:
mov rax, r10 ; matched index -> rax
ret

searchArray endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
arrayRemove proc uses rbx rdi rsi
; removes array[indexToRemove]
; receives: (rcx) QWORD array, the address of the array
;           (rdx) DWORD elementSize, the size of each element in the array
;           (r8) DWORD numElements, the number of elements in the array
;           (r9) DWORD indexToRemove, the index of the element to remove
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov rdi, r9 ; index to remove -> rsi
imul rdi, rdx ; index to remove * element size -> rsi
add rdi, rcx ; rsi = array[indextoRemove]

mov rsi, rdi
add rsi, rdx ; rsi = rdi + elementSize

mov rax, r8
imul rax, rdx
add rax, rcx ; rax = array[length]

copyAnotherByte:
cmp rsi, rax
je done

; [rdi] = [rsi]
mov bl, BYTE PTR [rsi]
mov BYTE PTR [rdi], bl

; rdi++, rsi++
inc rsi
inc rdi
jmp copyAnotherByte

done:
ret

arrayRemove endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;extern void arrayCopy(void *destArray, void *sourceArray, int elementSize, int n);
arrayCopy proc
; copies n elements from sourceArray to destArray
; receives: (rcx) QWORD destArray, the array being copied to
;           (rdx) QWORD sourceArray, the array being copied from
;           (r8) DWORD elementSize, the size of each element being copied
;           (r9) DWORD n, the number of elements to copy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

imul r9, r8 ; bytes to copy = elementSize * numElementsToCopy

copyAnother:
cmp r9, 0
je done 

mov al, BYTE PTR [rdx]
mov BYTE PTR [rcx], al

inc rcx
inc rdx
dec r9
jmp copyAnother

done:
ret
arrayCopy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scrambleArray proc uses rbx r12 r13 r14
; randomly rearranges the elements in an array
; receives: (rcx) QWORD array, the offset of the array to scramble
;           (rdx) QWORD elementSize, the size of each element in array
;           (r8) QWORD numElements, the number of elements in array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmp r8, 0 ; numElements == 0
je done

mov rbx, rcx ; rbx = array
mov r13, rdx ; r10 = elementSize
mov r14, r8  ; r11 = numElements

; swap each element with another random element
mov r12, 0 ; current index in array

swapAnother:
cmp r12, r14 ; index == numElements ?
je done

sub rsp, 32 ; add shadow space

call rand ; rax = random integer

xor rdx, rdx ; zero rdx (for division)
div r14 ; (rdx:rax / r14) -> rdx = randomInteger % numElements = randomIndex

; swap 
mov rcx, r12 ; rcx = i
imul rcx, r13 ; rcx  = i * elementSize
add rcx, rbx ; rcx = array[i]
; rdx = randomIndex
imul rdx, r13 ; rdx = randomIndex * elementSize
add rdx, rbx ; rdx = array[randomIndex]
mov r8, r13 ; r8 = elementSize
call swap 

add rsp, 32 ; remove shadow space

inc r12
jmp swapAnother

done:
ret
scrambleArray endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printArray proc
; prints each element in an array, delimited by commas, surrounded in square brackets.
; receives: (rcx) QWORD array, a pointer to the array to print
;           (rdx) QWORD elementSize, the size, in bytes, of each element in array
;           (r8) QWORD numElements, the number of elements in array
;           (r9) QWORD printElementFunction, a pointer to a function that prints a single element
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmp r8, 0 ; numElements == 0
je printEmptyArray

.data
openBracket BYTE "[", 0
closeBracket BYTE "]", 0
delimiter BYTE ", ", 0
emptyArray BYTE "[]", 0

.code
; print open bracket 
pushArgRegs
sub rsp, 32 ; add shadow space
mov rcx, OFFSET openBracket
call printf 
add rsp, 32 ; remove shadow space
popArgRegs


; print each element seperated by a delimeter
mov rax, 0 ; iterator
printAnother:

push rax
pushArgRegs
sub rsp, 32 ; add shadow space

imul rax, rdx ; rax = i * elementSize
add rcx, rax ; rcx = array[i]
call r9 ; print array[i]

add rsp, 32 ; remove shadow space
popArgRegs
pop rax

inc rax
cmp rax, r8
je allElementsPrinted

; print delimiter
push rax
pushArgRegs
sub rsp, 32
mov rcx, OFFSET delimiter
call printf
add rsp, 32
popArgRegs
pop rax

jmp printAnother

allElementsPrinted:

; print close bracket
pushArgRegs
sub rsp, 32 ; add shadow space
mov rcx, OFFSET closeBracket
call printf
add rsp, 32 ; remove shadow space
popArgRegs

done:
ret

printEmptyArray:
; print "[]"
sub rsp, 32
mov rcx, OFFSET emptyArray
call printf
add rsp, 32
ret
printArray endp

end