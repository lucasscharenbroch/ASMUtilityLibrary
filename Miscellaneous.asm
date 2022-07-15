.code
;;; C function prototypes
rand proto
clock proto

;;; functions 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
randomizeMemory proc
; sets a number of consecutive bytes to random values
; receives: (rcx) QWORD memory, a pointer to the memory to randomize
;           (rdx) QWORD numBytes, the number of bytes to randomize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test rdx, rdx
jz done

randomizeAnother:
dec rdx

; rax = rand()
push rcx
push rdx
sub rsp, 32 ; add shadow space
call rand
add rsp, 32 ; remove shadow space
pop rdx
pop rcx

mov BYTE PTR [rcx + rdx], al ; move randomized byte into memory

test rdx, rdx
jnz randomizeAnother

done:
ret
randomizeMemory endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getExecutionTime proc
; finds the execution time of a function, in milliseconds.
; receives: (rcx) QWORD function, a pointer to the function to time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sub rsp, 32
; record current milisecond
push rcx
call clock
pop rcx

; execute the function
push rax
call rcx
pop rax

; calculate current time
mov rdx, rax ; startTime -> rdx
push rdx
call clock
pop rdx

; calclate the elapsed milliseconds (startTime -=  currentTime)
sub rax, rdx

add rsp, 32
ret
getExecutionTime endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sleep proc
; waits n milliseconds
; receives (rcx) QWORD n, the number of milliseconds to sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sub rsp, 32

; get current time
push rcx
call clock
pop rcx

add rcx, rax ; rcx = time to sleep until

waitAWhile:
push rcx
call clock
pop rcx
cmp rax, rcx
jl waitAWhile

add rsp, 32
ret
sleep endp

end