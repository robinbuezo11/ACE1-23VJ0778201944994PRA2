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
in_buffer       db  20, 00
                db  20 dup (0)
number          db  05 dup (30)
exit_option     db  "(S)alir", 0a, "$"
back_option     db  "(R)egresar", 0a, "$"

zeros           db  28 dup (0)

pointer_tmp     dw  0000

; Header
usac            db  "Universidad de San Carlos de Guatemala", 0a, "$"
facul           db  "Facultad de Ingenieria", 0a, "$"
school          db  "Escuela de Vacaciones", 0a, "$"
course          db  "Arquitectura de Computadores y Ensambladores 1", 0a, "$"
student         db  "Robin Omar Buezo Diaz", 0a, "$"

; Login
username        db  "Nombre: ", "$"
carne           db  "Carnet: ", "$"
loginfile_error db  "Error al intentar abrir el archivo", 0a, "$"
loginauth_error db  "Usuario o clave incorrectos", 0a, "$"
login_error     db  "Error al intentar iniciar sesion", 0a, "$"
login_success   db  "Bienvenido, presione 'Enter' ", 0a, "$"
tk_cred         db  0e, "[credenciales]"
tk_usuario      db  07, "usuario"
tk_clave        db  05, "clave"
config_file     db  "PRA2.CNF", 00
handle_conf     dw  00
buffer_line     db  0ff dup (0)
size_line       db  00
status          db  00  ; 00 = cred, 01 = usuario|clave, 02 = usuario|clave, 03 = ask
user            db  0f dup (0)
pass            db  0f dup (0)
user_buffer     db  0e, 00
                db  0e dup (0)
pass_buffer     db  0e, 00
                db  0e dup (0)

; Menu
menu_msg        db  "Ingrese una opcion:", 0a, "$"
products        db  "(P)roductos", 0a, "$"
sales           db  "(V)entas", 0a, "$"
utils           db  "(H)erramientas", 0a, "$"

; Products
products_msg            db  "MENU DE PRODUCTOS", 0a, "$"
products_create_msg     db  "(C)rear producto", 0a, "$"
products_delete_msg     db  "(E)liminar producto", 0a, "$"
products_show_msg       db  "(M)ostrar productos", 0a, "$"
products_file           db  "PROD.BIN", 00
handle_products         dw  0000
product_not_found       db  "Producto no encontrado", 0a, "$"
product_deleted         db  "Producto eliminado exitosamente", 0a, "$"
product_exists_msg      db  "El producto ya existe", 0a, "$"

; Product Structure
product_code            db  04 dup (0)
product_desc            db  20 dup (0)
product_price           db  05 dup (0)
product_stock           db  05 dup (0)
req_product             db  "Ingrese los datos del producto: ", 0a, "$"
req_code                db  "Codigo: ", "$"
req_desc                db  "Descripcion: ", "$"
req_price               db  "Precio: ", "$"
req_stock               db  "Unidades: ", "$"
product_num_price       dw  0000
product_num_stock       dw  0000
product_tmp             db  28 dup (0)


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

; get_string - get string from keyboard
get_string macro buffer
    mov DX, offset buffer
    mov AH, 0a
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
        mov AX, 0000
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

get_pressed_key: ;--------------------------------Start of get_pressed_key
        ; Get pressed key
        ; Output: AL = pressed key
        mov AH, 08
        int 21
        ret
        ;--------------------------------End of get_pressed_key

copy_string: ;------------------------------------Start of copy_string
        ; Copy string
        ; Input: SI = Source string
        ;        DI = Destination string
        ;        CX = length max
        ; Output: SI = Source string
        ;         DI = Source string
        mov AL, [SI]
        mov [DI], AL
        inc SI
        inc DI
        loop copy_string
        ret
        ;------------------------------------End of copy_string

string_to_num: ;----------------------------------Start of string_to_num
        ; Convert string to int
        ; Input: DI = string
        ; Output: AX = int
        mov AX, 0000
        mov CX, 0005
cycle_string_to_num:
        mov BL, [DI]
        cmp BL, 00
        je end_string_to_num
        sub BL, 30
        mov DX, 000a
        mul DX
        mov BH, 00
        add AX, BX
        inc DI
        loop cycle_string_to_num
end_string_to_num:
        ret
        ;----------------------------------End of string_to_num

int_to_string: ;------------------------------------Start of int_to_string
        ; Convert int to string
        ; Input: AX = int
        ; Output: [number] = string
        mov CX, 0005
        mov DI, offset number
cycle_set30:
        mov BL, 30
        mov [DI], BL
        inc DI
        loop cycle_set30
        
        mov CX, AX
        mov DI, offset number
        add DI, 04
cycle_int_to_string:
        mov BL, [DI]
        inc BL
        mov [DI], BL
        cmp BL, 3a
        je increase_next
        loop cycle_int_to_string
        jmp end_int_to_string
increase_next:
        push DI
increase_next_cycle:
        mov BL, 30
        mov [DI], BL
        dec DI
        mov BL, [DI]
        inc BL
        mov [DI], BL
        cmp BL, 3a
        je increase_next_cycle
        pop DI
        loop cycle_int_to_string
end_int_to_string:
        ret
        ;------------------------------------End of int_to_string

memset: ;----------------------------------------------Start of memset
        ; Set memory
        ; Input: DI = memory
        ;        CX = length
        ;        AL = value
cycle_memset:
        mov [DI], AL
        inc DI
        loop cycle_memset
        ret
        ;----------------------------------------------End of memset

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
        jc error_login_file

        ; Save handle
        mov [handle_conf], AX

        ; Analyze config file
init_lineXline:
        mov DI, offset buffer_line
        mov AL, 00
        mov [size_line], AL
cycle_lineXline: ;---------------- Read line from file
        mov AL, 00
        mov AH, 3f
        mov BX, [handle_conf]
        mov CX, 0001
        mov DX, DI
        int 21
        ; If no more bytes, end
        cmp AX, 0000
        je end_read_line

        ; if byte read is 0a, end
        mov AL, [DI]
        cmp AL, 0d
        je carriage_return
        cmp AL, 0a
        je end_read_line
        mov AL, [size_line]
        inc AL
        mov [size_line], AL
        inc DI
        jmp cycle_lineXline
carriage_return:
        inc DI
        jmp cycle_lineXline
end_read_line: ;--------------------End of read line
        mov AL, 00
        cmp AL, [status]
        je get_cred ;-----------------Get credentials
        mov AL, 01
        cmp AL, [status]
        je get_user_pass ;------------Get user and pass
        mov AL, 02  
        cmp AL, [status]
        je get_user_pass ;------------Get user and pass
        mov AL, 03  
        cmp AL, [status]
        je ask_user_pass ;------------Ask user and pass
get_cred:   ;--------------------------Get credentials
        mov CH, 00
        mov CL, [tk_cred]
        mov SI, offset buffer_line
        mov DI, offset tk_cred
        inc DI
        call compare_string
        cmp DX, 0001
        je exists_cred
        jmp error_login
exists_cred:
        mov AL, [status]
        inc AL
        mov [status], AL
        jmp init_lineXline
get_user_pass:  ;---------------------Get user and pass
        mov CH, 00
        mov CL, [tk_usuario]
        mov SI, offset buffer_line
        mov DI, offset tk_usuario
        inc DI
        call compare_string
        cmp DX, 0001
        je exists_user
        mov CH, 00
        mov CL, [tk_clave]
        mov SI, offset buffer_line
        mov DI, offset tk_clave
        inc DI
        call compare_string
        cmp DX, 0001
        je exists_pass
        jmp error_login
exists_user:    ;--------------------- This is the user
spaces1:
        mov AL, [SI]
        inc SI
        cmp AL, 20
        je spaces1
        cmp AL, 3d
        je get_user_value
        jmp error_login
get_user_value: ;--------------------- Get user value
spaces2:
        mov AL, [SI]
        inc SI
        cmp AL, 20
        je spaces2
        cmp AL, 22
        jne error_login
        mov DI, offset user
        mov CL, 00
        mov BX, 0001
loop_user:
        mov AL, [SI]
        cmp AL, 22
        je end_loop_user
        mov [DI+BX], AL
        inc SI
        inc CL
        inc BX
        jmp loop_user
end_loop_user:
        mov [DI], CL
        mov AL, [status]
        inc AL
        mov [status], AL
        jmp init_lineXline
exists_pass:    ;--------------------- This is the pass
spaces3:
        mov AL, [SI]
        inc SI
        cmp AL, 20
        je spaces3
        cmp AL, 3d
        je get_pass_value
        jmp error_login
get_pass_value: ;--------------------- Get pass value
spaces4:
        mov AL, [SI]
        inc SI
        cmp AL, 20
        je spaces4
        cmp AL, 22
        jne error_login
        mov DI, offset pass
        mov CL, 00
        mov BX, 0001
loop_pass:
        mov AL, [SI]
        cmp AL, 22
        je end_loop_pass
        mov [DI+BX], AL
        inc SI
        inc CL
        inc BX
        jmp loop_pass
end_loop_pass:
        mov [DI], CL
        mov AL, [status]
        inc AL
        mov [status], AL
        jmp init_lineXline
ask_user_pass: ; ------------- Ask at user the user and pass
        print username
        get_string user_buffer
        print new_line

        print carne
        get_string pass_buffer
        print new_line
        
        ; Check if username and password are correct
        mov SI, offset user_buffer
        add SI, 02
        mov DI, offset user
        mov CX, [DI]
        mov CH, 00
        inc DI
        call compare_string
        cmp DX, 0001
        jne error_login_cred

        mov SI, offset pass_buffer
        add SI, 02
        mov DI, offset pass
        mov CX, [DI]
        mov CH, 00
        inc DI
        call compare_string
        cmp DX, 0001
        jne error_login_cred
        jmp success_login
error_login:    ;--------------------- File has to be closed
        mov BX, [handle_conf]
        mov AH, 3e
        int 21

        print login_error
        jmp close
error_login_file:
        print loginfile_error
        jmp close
error_login_cred:
        print loginauth_error
        jmp error_login
success_login:  ;--------------------- File has to be closed
        mov BX, [handle_conf]
        mov AH, 3e
        int 21

        print login_success
        call get_pressed_key
        cmp AL, 0d
        jne success_login ;------------------ End of login
principal_menu: ;----------------------------------------------Start of principal menu
        print new_line
        print menu_msg
        print products
        print sales
        print utils
        print exit_option
        call get_pressed_key
        cmp AL, 50 ;------------------ Products
        je products_menu
        cmp AL, 70 ;------------------ Products
        je products_menu
        cmp AL, 56 ;------------------ Sales
        je sales_menu
        cmp AL, 76 ;------------------ Sales
        je sales_menu
        cmp AL, 48 ;------------------ Utils
        je utils_menu
        cmp AL, 68 ;------------------ Utils
        je utils_menu
        cmp AL, 53 ;------------------ Exit
        je close
        cmp AL, 73 ;------------------ Exit
        je close
        jmp principal_menu ;------------------ End of principal menu
products_menu: ;----------------------------------------------Start of products menu
        print new_line
        print products_msg
        print products_create_msg
        print products_delete_msg
        print products_show_msg
        print back_option
        call get_pressed_key
        cmp AL, 43 ;------------------ Create
        je products_create
        cmp AL, 63 ;------------------ Create
        je products_create
        cmp AL, 45 ;------------------ Delete
        je products_delete
        cmp AL, 65 ;------------------ Delete
        je products_delete
        cmp AL, 4d ;------------------ Show
        je products_show
        cmp AL, 6d ;------------------ Show
        je products_show
        cmp AL, 52 ;------------------ Back
        je principal_menu
        cmp AL, 72 ;------------------ Back
        je principal_menu
        jmp products_menu ;------------------ End of products menu
products_create: ;----------------------------------------------Start of products create
        print new_line
        print req_product
get_code_product: ;--------------------- Get code product
        int 03
        print new_line
        print req_code
        get_string in_buffer
        mov DI, offset in_buffer ;------ Validate code product, PENDING need to validate if chars are in acceptable range
        inc DI
        mov AL, [DI]
        cmp AL, 00
        je get_code_product
        cmp AL, 05
        jb accept_code_product
        jmp get_code_product
accept_code_product: ;--------------------- Accept code product
        mov DI, offset product_code
        mov SI, offset in_buffer
        inc SI
        mov CH, 00
        mov CL, [SI]
        inc SI
        call copy_string
get_desc_product:
        print new_line
        print req_desc
        get_string in_buffer
        mov DI, offset in_buffer ;------ Validate desc product, PENDING need to validate if chars are in acceptable range
        inc DI
        mov AL, [DI]
        cmp AL, 00
        je get_desc_product
        cmp AL, 21
        jb accept_desc_product
        jmp get_desc_product
accept_desc_product: ;--------------------- Accept desc product
        mov DI, offset product_desc
        mov SI, offset in_buffer
        inc SI
        mov CH, 00
        mov CL, [SI]
        inc SI
        call copy_string
get_price_product:
        print new_line
        print req_price
        get_string in_buffer
        mov DI, offset in_buffer ;------ Validate price product, PENDING need to validate if chars are in acceptable range
        inc DI
        mov AL, [DI]
        cmp AL, 00
        je get_price_product
        cmp AL, 06
        jb accept_price_product
        jmp get_price_product
accept_price_product: ;--------------------- Accept price product
        mov DI, offset product_price
        mov SI, offset in_buffer
        inc SI
        mov CH, 00
        mov CL, [SI]
        inc SI
        call copy_string

        mov DI, offset product_price
        call string_to_num
        mov [product_num_price], AX

        mov DI, offset product_price
        mov CX, 0005
        mov AL, 00
        call memset
get_stock_product:
        print new_line
        print req_stock
        get_string in_buffer
        mov DI, offset in_buffer ;------ Validate stock product, PENDING need to validate if chars are in acceptable range
        inc DI
        mov AL, [DI]
        cmp AL, 00
        je get_stock_product
        cmp AL, 06
        jb accept_stock_product
        jmp get_stock_product
accept_stock_product: ;--------------------- Accept stock product
        print new_line
        mov DI, offset product_stock
        mov SI, offset in_buffer
        inc SI
        mov CH, 00
        mov CL, [SI]
        inc SI
        call copy_string

        mov DI, offset product_stock
        call string_to_num
        mov [product_num_stock], AX

        mov DI, offset product_stock
        mov CX, 0005
        mov AL, 00
        call memset
open_product_file:
        mov AL, 02
        mov AH, 3d
        mov DX, offset products_file
        int 21
        ; If error we need create the file
        jc create_product_file
        ; If not error write at the end of file
        jmp save_product
create_product_file:
        mov CX, 0000
        mov DX, offset products_file
        mov AH, 3c
        int 21
save_product:
        mov [handle_products], AX
        mov BX, [handle_products]
        mov DX, 0000
        mov [pointer_tmp], DX
        ; We go to the end of file
        ; mov CX, 0000
        ; mov DX, 0000
        ; mov AH, 42
        ; mov AL, 02
        ; int 21
find_zero:
        mov CX, 28
        mov DX, offset product_tmp
        mov AH, 3f
        int 21
        cmp AX, 0000 ;------------------ End of file
        je write_product

        mov DX, [pointer_tmp] ;----------- We move the pointer
        add DX, 0028
        mov [pointer_tmp], DX

        mov DI, offset product_tmp ;-------- Verify if product already exist
        mov SI, offset product_code
        mov CX, 0004
        call compare_string
        cmp DX, 0001
        je product_exists

        mov AL, 00      ;------------------ Verify if product is valid
        cmp [product_tmp], AL
        jne find_zero

        mov DX, [pointer_tmp] ;------------------ Position the pointer at the beginning of the product
        sub DX, 0028
        mov CX, 0000
        mov BX, [handle_products]
        mov AX, 4200
        int 21
        jmp write_product
product_exists:
        print new_line
        print product_exists_msg
        jmp not_write_product
write_product:
        ; We write the product
        mov CX, 0024
        mov DX, offset product_code
        mov AH, 40
        int 21
        mov CX, 0004
        mov DX, offset product_num_price
        mov AH, 40
        int 21
not_write_product:
        ; We close the file
        mov AH, 3e
        int 21
        ; We clean the variables
        mov DI, offset product_tmp
        mov CX, 0028
        mov AL, 00
        call memset
        mov DI, offset product_code
        mov CX, 0004
        mov AL, 00
        call memset
        mov DI, offset product_desc
        mov CX, 0020
        mov AL, 00
        call memset
        jmp products_menu ;------------------ End of products create
products_delete: ;----------------------------------------------Start of products delete
        mov DX, 0000
        mov [pointer_tmp], DX
get_code_delete: ;--------------------- Get code product to delete
        print new_line
        print req_code
        get_string in_buffer
        mov DI, offset in_buffer ;------ Validate code product, PENDING need to validate if chars are in acceptable range
        inc DI
        mov AL, [DI]
        cmp AL, 00
        je get_code_delete
        cmp AL, 05
        jb accept_code_delete
        jmp get_code_delete
accept_code_delete: ;--------------------- Accept code product to delete
        mov AL, 02
        mov AH, 3d
        mov DX, offset products_file
        int 21
        mov [handle_products], AX
find_cycle:
        int 03
        mov BX, [handle_products]
        mov CX, 0024
        mov DX, offset product_code
        mov AH, 3f
        int 21
        mov BX, [handle_products]
        mov CX, 0004
        mov DX, offset product_num_price
        mov AH, 3f
        int 21
        cmp AX, 0000 ;------------------ End of file
        je delete_not_found
        
        mov DX, [pointer_tmp] ;----------- We move the pointer
        add DX, 0028
        mov [pointer_tmp], DX
        
        mov AL, 00      ;------------------ Verify if product is valid
        cmp [product_code], AL
        je find_cycle

        mov SI, offset in_buffer ;------ Verify if code is equal
        add SI, 0002
        mov DI, offset product_code
        mov CX, 0004
        call compare_string
        cmp DX, 0001
        je delete_product
        jmp find_cycle
delete_product:
        mov DX, [pointer_tmp] ;------------------ Position the pointer at the beginning of the product
        sub DX, 0028
        mov CX, 0000
        mov BX, [handle_products]
        mov AX, 4200
        int 21

        mov CX, 0028 ;------------------ Write 0's to the product
        mov DX, offset zeros
        mov AH, 40
        int 21
        mov DI, offset product_code
        mov CX, 0004
        mov AL, 00
        call memset
        print new_line
        print product_deleted
        jmp close_delete
delete_not_found:
        print new_line
        print product_not_found
close_delete:
        mov AH, 3e
        int 21
        jmp products_menu ;------------------ End of products delete
products_show: ;----------------------------------------------Start of products show
        mov AL, 00
        mov AH, 3d
        mov DX, offset products_file
        int 21
        mov [handle_products], AX
        ; SHOW 5 PRODUCTS AND WAIT FOR KEY
        ;       IF KEY IS 'ENTER' SHOW NEXT 5 PRODUCTS
        ;       IF KEY IS 'q' RETURN TO PRODUCTS MENU
        
sales_menu: ;-------------------------------------------------Start of sales menu

utils_menu: ;------------------------------------------------Start of utils menu

close:
.EXIT
END