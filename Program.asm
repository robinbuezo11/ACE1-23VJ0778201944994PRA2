.MODEL SMALL
.RADIX 16
.STACK 
;------------------------------ STACK ----------------------------------
;-----------------------------------------------------------------------

.DATA 
;------------------------------ DATA -----------------------------------
;-----------------------------------------------------------------------
; Variables
new_line        db  0a, "$"

; Header
usac            db  "Universidad de San Carlos de Guatemala", 0a, "$"
facul           db  "Facultad de Ingenieria", 0a, "$"
school          db  "Escuela de Vacaciones", 0a, "$"
course          db  "Arquitectura de Computadores y Ensambladores 1", 0a, "$"
student         db  "Robin Omar Buezo Díaz", 0a, "$"

; Login
username        db  "Nombre: ", "$"
carne           db  "Carnet: ", "$"
login_error     db  "Usuario o clave incorrectos", 0a, "$"
login_success   db  "Bienvenido, presione 'Enter' ", 0a, "$"
tk_cred         db  0e, "[credenciales]"
tk_usuario      db  07, "usuario"
tk_clave        db  05, "clave"
config_file     db  "PRA2.CNF", 00
handle_conf     dw  00
buffer_line     db  0ff dup (0)
status          db  00  ; 00 = cred, 01 = usuario|clave, 02 = usuario|clave, 03 = ask
user            db  0f dup (0)
pass            db  0f dup (0)
user_buffer     db  0e dup (0)
pass_buffer     db  0e dup (0)




.CODE
.STARTUP
jmp start
;--------------------------- CODE HERE ---------------------------------
;-----------------------------------------------------------------------

;---------------------------- MACROS -----------------------------------
; print - print string with delimiter $
print macro string
    mov DX, offset string
    mov AH, 09
    int 21
endm

;-------------------------- SUBROUTINES --------------------------------
;-----------------------------------------------------------------------
compare_string: ;--------------------------------Start of compare_string
        ; Compare two strings
        ; Input: SI = string A
        ;        DI = string B
        ;        CX = length max
        ; Output: DX = 01 if equal
        ;         DX = 00 if not equal
        mov AL, [SI]
        cmp AL, [DI]
        jne not_equals
        inc SI
        inc DI
        loop compare_string
        mov DX, 01
        ret
not_equals:
        mov DX, 00
        ret     ;--------------------------------End of compare_string  

;---------------------------- PROGRAM -----------------------------------
start:
        ; Print header
        print usac
        print facul
        print school
        print course
        print student
        print new_line

login: ;----------------------------------------------Start of login
        ; Open config file
        mov AH, 3d
        mov AL, 00
        mov DX, offset config_file
        int 21

        ; If error, close program
        jc close

        ; Save handle
        mov [handle_conf], AX

        ; Analyze config file
        mov DI, offset buffer_line
cycle_lineXline: ;---------------- Read line from file
        mov AH, 3f
        mov BX, [handle_conf]
        mov CX, 01
        mov DX, DI

        ; If no more bytes, end
        cmp AX, 00
        je end_read_line

        ; if byte read is 0a, end
        mov AL, [DI]
        cmp AL, 0a
        je end_read_line
        cmp AL, 0d
        je end_read_line
        inc DI
        jmp cycle_lineXline
end_read_line: ;--------------------End of read line
        mov AL, 00
        cmp AL, status
        je get_cred ;-----------------Get credentials
        mov AL, 01
        cmp AL, status
        je get_user_pass ;------------Get user and pass
        mov AL, 02  
        cmp AL, status
        je get_user_pass ;------------Get user and pass
        mov AL, 03  
        cmp AL, status
        je ask_user_pass ;------------Ask user and pass
get_cred:   ;--------------------------Get credentials
        int 03
        mov CH, 00
        mov CL, [tk_cred]
        mov SI, offset buffer_line
        mov DI, offset tk_cred
        inc DI
        call compare_string
        cmp DX, 01
        je exists_cred
        jmp error_login
exists_cred:
        mov AL, [status]
        inc AL
        mov [status], AL
        jmp cycle_lineXline
get_user_pass:  ;---------------------Get user and pass
        mov CH, 00
        mov CL, [tk_usuario]
        mov SI, offset buffer_line
        mov DI, offset tk_usuario
        inc DI
        call compare_string
        cmp DX, 01
        je exists_user
        mov CH, 00
        mov CL, [tk_clave]
        mov SI, offset buffer_line
        mov DI, offset tk_clave
        inc DI
        call compare_string
        cmp DX, 01
        je exists_pass
        jmp error_login
exists_user:    ;--------------------- This is the user
        mov AL, [status]
        inc AL
        mov [status], AL
spaces1:
        mov AL, [SI]
        cmp AL, 20
        inc SI
        je spaces1
        mov AL, [SI]
        cmp AL, 3d
        inc SI
        je get_user_value
        jmp error_login
get_user_value: ;--------------------- Get user value
spaces2:
        mov AL, [SI]
        cmp AL, 20
        inc SI
        je spaces2
        mov AL, [SI]
        cmp AL, 22
        jne error_login
        inc SI
        mov DI, offset user
        mov CX, 00
        mov BX, 01
loop_user:
        mov AL, [SI]
        cmp AL, 22
        je end_loop_user
        mov [DI+BX], AL
        inc SI
        inc CX
        inc BX
        jmp loop_user
end_loop_user:
        mov [DI], CX
        mov AL, [status]
        inc AL
        mov [status], AL
        jmp cycle_lineXline
exists_pass:    ;--------------------- This is the pass
        mov AL, [status]
        inc AL
        mov [status], AL
spaces3:
        mov AL, [SI]
        cmp AL, 20
        inc SI
        je spaces3
        mov AL, [SI]
        cmp AL, 3d
        inc SI
        je get_pass_value
        jmp error_login
get_pass_value: ;--------------------- Get pass value
spaces4:
        mov AL, [SI]
        cmp AL, 20
        inc SI
        je spaces4
        mov AL, [SI]
        cmp AL, 22
        jne error_login
        inc SI
        mov DI, offset pass
        mov CX, 00
        mov BX, 01
loop_pass:
        mov AL, [SI]
        cmp AL, 22
        je end_loop_pass
        mov [DI+BX], AL
        inc SI
        inc CX
        inc BX
        jmp loop_pass
end_loop_pass:
        mov [DI], CX
        mov AL, [status]
        inc AL
        mov [status], AL
        jmp cycle_lineXline
ask_user_pass: ; ------------- Ask at user the user and pass
        print username
        mov AH, 0a
        mov DX, offset user_buffer
        int 21

        print carne
        mov AH, 0a
        mov DX, offset pass_buffer
        int 21
        
        ; Check if username and password are correct
        mov SI, offset user_buffer
        mov DI, offset user
        mov CX, [DI]
        inc DI
        call compare_string
        cmp DX, 01
        jne error_login

        mov SI, offset pass_buffer
        mov DI, offset pass
        mov CX, [DI]
        inc DI
        call compare_string
        cmp DX, 01
        jne error_login
        jmp success_login
error_login:    ;--------------------- File has to be closed
        print login_error
        jmp close
success_login:  ;--------------------- File has to be closed
        print login_success
        mov AH, 08
        int 21
        cmp AL, 20
        jne success_login
        ;----------------------------------------------End of login
close:
.EXIT
END