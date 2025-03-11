; Copied directly from the documentation
; Declare the string constant as a global constant.
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"

@.str2 = private unnamed_addr constant [6 x i8] c"None\0A\00"

; External declaration of the puts function
declare i32 @puts(i8* nocapture) nounwind; Module declaration
declare i32 @printf(i8*, ...)

; Declare the malloc function
declare i8* @malloc(i64)

; Define the triple structure type
%triple = type { %triple*, i32, %triple* }

; Define the pair structure type
%pair = type {i32, i32}

; Define the function type
%fn_type = type %pair (i32)

; Define optional pair type
%opt_pair = type {i1, i32}

; Function declaration for map_get
define %opt_pair @map_get(%triple* %l, i32 %key, %fn_type* %f) {
    %cmp = icmp eq %triple* %l, null    
    br i1 %cmp, label %if_null, label %if_not_null

if_null:
    ret %opt_pair {i1 0, i32 0}

if_not_null:
    %l_key = call %pair %f(i32 %key)
    %rest = extractvalue %pair %l_key, 0
    %br = extractvalue %pair %l_key, 1
    %br_i1 = icmp eq i32 %br, 1
    br i1 %br_i1, label %br_right, label %br_left

br_right:
    %l_right = getelementptr %triple, %triple* %l, i32 0, i32 2
    %res_right = call %opt_pair @map_get(%triple* %l_right, i32 %rest, %fn_type* %f)
    ret %opt_pair %res_right

br_left:
    %l_left = getelementptr %triple, %triple* %l, i32 0, i32 1
    %res_left = call %opt_pair @map_get(%triple* %l_left, i32 %rest, %fn_type* %f)
    ret %opt_pair %res_left
}

; Definition of main function
define i32 @main() { ; i32()*
    ; Convert [13 x i8]* to i8  *...
    %cast210 = getelementptr [4 x i8],[4 x i8]* @.str, i64 0, i64 0
    %cast211 = getelementptr [6 x i8],[6 x i8]* @.str2, i64 0, i64 0

    ; Call puts function to write out the string to stdout.

    %res = call %opt_pair @map_get(%triple* null, i32 1, %fn_type* null)
    %res_i1 = extractvalue %opt_pair %res, 0
    br i1 %res_i1, label %if_not_null, label %if_null

if_null:
    call i32 (i8*, ...) @printf(i8* %cast211)
    ret i32 0

if_not_null:
    %v = extractvalue %opt_pair %res, 1
    call i32 (i8*, ...) @printf(i8* %cast210,  i32 %v)
    ret i32 0
}
