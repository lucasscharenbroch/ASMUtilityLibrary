.code
;;; C function prototypes
malloc PROTO
free PROTO

;;; macros
mPushAllQ macro
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r8
    push r9
    push r10
    push r11
endm

mPopAllQ macro
    pop r11
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
endm

;;; functions 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
insertionSort proc uses rbx
; sorts an array of integers using repeated swaps 
; recieves: (rcx) QWORD array, a pointer to an integer array
;           (rdx) QWORD size, the number of integers in array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov rax, 1 ; rax -> i = 1
insertNextIndex:

mov rbx, rax ; rbx -> j = i
swapElementBack:
and rbx, rbx
jz continue

mov r8, rbx
dec r8 ; r8 = j-1
mov r9d, DWORD PTR [rcx + rbx * 4] ; array[j]
cmp r9d, DWORD PTR [rcx + r8 * 4] ; array[j-1]
jge continue ; only swap if array[j] < array[j-1]

; swap array[j] and array[j-1]
; r9d already = array[j]
xchg DWORD PTR [rcx + r8 * 4], r9d
mov DWORD PTR [rcx + rbx * 4], r9d

; j--
dec rbx
jmp swapElementBack

continue:

inc rax
cmp rax, rdx
jne insertNextIndex

ret
insertionSort endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
binaryCountingSort proc uses rbx r10 r11 r12 r13
; sorts the array based on bitToSortBy (used as a helper by binaryRadixSort)
; receives: (rcx) QWORD array, a pointer to an array of integers
;           (rdx) QWORD length, an integer length of array
;           (r8) QWORD bitToCount, the bit [0, 31] to sort by
;           (r9) QWORD ascending, whether to put 0s (ascending) or 1s (decending) first in the array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test rdx, rdx
jz done ; length == 0

; check each element's bitToCount, count the number of zeroes.
mov r10, 0 ; r10 = zeroCount
mov rbx, rcx ; rbx = array
mov cl, r8b ; cl = bitToCount
mov rax, 0 ; rax = iterator

checkAnother:
mov r11d, DWORD PTR [rbx + rax * 4] ; array[i]
shr r11d, cl
and r11d, 1b 
jnz continue1 ; ignore if the bit is 1
inc r10      ; otherwise, zeroCount++

continue1:
inc rax
cmp rax, rdx ; i == length
jne checkAnother

; partition the array for inserting elements
; r10 = position to insert zeroes
; r11 = position to insert ones
test r9, r9 ; ascending ?
jz descending
; ascending
mov r11, r10 ; insert ones starting at zeroCount
mov r10, 0   ; insert zeroes starting at 0
jmp afterPartition
descending:
; insert zeroes at length - zeroCount
neg r10 ; -zeroCount
add r10, rdx ; length - zeroCount
mov r11, 0 ; insert ones at 0
afterPartition:

; malloc space for a new array
mPushAllQ ; push rax-r11, rdi, rsi
mov rcx, rdx
shl rcx, 2 ; rcx = length * 4
sub rsp, 32 ; add shadow space
call malloc
mov r12, rax ; new pointer -> r12 (r12 = newArray)
add rsp, 32 ; remove shadow space
mPopAllQ ; pop rax-r11, rdi, rsi

; copy elements from the old array to the new array based on their bitToCount 
; (rbx = array)
; (cl = bitToCount)
mov rax, 0 ; rax = iterator

moveAnother:
mov r13d, DWORD PTR [rbx + rax * 4] ; array[i]
shr r13d, cl
and r13d, 1b 
jnz moveToOnes
;moveToZeroes
; newArray[zeroPosition++] = array[i]
; (r10 = zeroPosition)
mov r13d, DWORD PTR [rbx + rax * 4] ; r13d = array[i]
mov DWORD PTR [r12 + r10 * 4], r13d ; array[zeroPosition] = r13 = array[i]
inc r10 ; zeroPosition++

jmp continue2
moveToOnes:
; newArray[onePosition++] = array[i]
; (r11 = onePosition)
mov r13d, DWORD PTR [rbx + rax * 4] ; r13 = array[i]
mov DWORD PTR [r12 + r11 * 4], r13d ; array[onePosition] = r13 (= array[i])
inc r11 ; onePosition++

continue2:
inc rax
cmp rax, rdx ; i == length
jne moveAnother

; copy newArray to array
mov rax, 0 ; rax = iterator

copyAnother:
mov r13d, DWORD PTR [r12 + rax * 4] ; r13 = newArray[i]
mov DWORD PTR [rbx + rax * 4], r13d ; array[i] = r13 (= newArray[i])

inc rax
cmp rax, rdx ; iterator == length ?
jne copyAnother

; free newArray
mov rcx, r12 ; rcx = newArray
sub rsp, 32 ; add shadow space
call free
add rsp, 32 ; remove shadow space

done:
ret
binaryCountingSort endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
binaryRadixSort proc uses r10 r11 r12 r13 r14
; radix-sorts an array of integers
; receives: (rcx) QWORD array, a pointer to the integer array to sort
;           (rdx) QWORD length, an integer, the length of the array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; sort the array by sign bit (devide into negatives and positives)
push rcx
push rdx
mov r8, 31 ; bitToCount = sign bit
mov r9, 0  ; ascending = false (negatives first)
sub rsp, 32 ; add shadow space
call binaryCountingSort
add rsp, 32 ; remove shadow space
pop rdx
pop rcx

; find the first positive number's index
mov rax, -1
checkIfPositive:
inc rax
cmp rax, rdx ; rax == arrayLength
je continue
mov r10d, DWORD PTR [rcx + rax * 4]
test r10d, r10d
js checkIfPositive

continue:

; partition array into (negativeArray and positiveArray)
; (rax = index of the first positive number = negativeArrayLength)
; (rcx = negativeArray)
; (rdx = negativeArrayLength + positiveArrayLength)
mov r10, rcx ; r10 = negativeArray
mov r11, rax ; r11 = negativeArrayLength
lea r12, [rcx + rax * 4] ; r12 = positiveArray
mov r13, rdx ; r13 = positiveArrayLength + negativeArrayLength
sub r13, rax ;                           - negativeArrayLength
             ; r13 = positiveArrayLength

; counting sort both arrays (positiveArray and negativeArray) for bits 0-30 
mov r14, 0 ; bit to count
sub rsp, 32 ; shadow space
mov r9, 1 ; ascending
sortAnother:

; negativeArray
mov rcx, r10
mov rdx, r11
mov r8, r14 ; bit to count
; (r9 = ascending)
call binaryCountingSort

; positiveArray
mov rcx, r12
mov rdx, r13 
mov r8, r14
; (r9 = ascending)
call binaryCountingSort

inc r14
cmp r14, 31
jne sortAnother
add rsp, 32

ret
binaryRadixSort endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bubbleSort proc uses r10 r11
; sorts an array of integers using bubble sort
; receives (rcx) QWORD array, an array of integers to be sorted
;          (rdx) QWORD length, the length of array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dec rdx
bubbleAnother:
mov rax, 0 ; iterator

checkAnother:
lea r8, [rcx + rax * 4]
inc rax
lea r9, [rcx + rax * 4]

mov r10d, DWORD PTR [r9]
cmp DWORD PTR [r8], r10d
jle continue
; swap  [r8] and [r9]
mov r11d, DWORD PTR [r8]
mov DWORD PTR [r8], r10d
mov DWORD PTR [r9], r11d

continue:
cmp rax, rdx
jne checkAnother

dec rdx
cmp rdx, 0
jg bubbleAnother

ret
bubbleSort endp

end