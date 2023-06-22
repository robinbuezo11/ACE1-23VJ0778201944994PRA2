.MODEL SMALL
.RADIX 16
.STACK 
;------------------------------ STACK ----------------------------------
;-----------------------------------------------------------------------

.DATA 
;------------------------------ DATA -----------------------------------
;-----------------------------------------------------------------------
; Variables
new_line    db  0a, "$"

; Header
usac       db  "Universidad de San Carlos de Guatemala", 0a, "$"
facul      db  "Facultad de Ingenieria", 0a, "$"
school     db  "Escuela de Vacaciones", 0a, "$"
course     db  "Arquitectura de Computadores y Ensambladores 1", 0a, "$"
student    db  "Robin Omar Buezo Díaz", 0a, "$"

; Login
username   db  "Nombre: ", "$"
carne      db  "Carnet: ", "$"

.CODE
.STARTUP
;--------------------------- CODE HERE ---------------------------------
;-----------------------------------------------------------------------

;---------------------------- MACROS -----------------------------------
; print - print string with delimiter $
print macro string
    mov DX, offset string
    mov AH, 09
    int 21
endm

;---------------------------- PROGRAM -----------------------------------
start:
    ; Print header
    print usac
    print facul
    print school
    print course
    print student
    print new_line

login:
    print username


.EXIT
END