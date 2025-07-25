(** 骆言词法分析器 - 基础数据类型Token *)

type basic_token =
  | IntToken of int              
  | FloatToken of float          
  | ChineseNumberToken of string 
  | StringToken of string        
  | BoolToken of bool            
[@@deriving show, eq]

let to_string = function
  | IntToken i -> string_of_int i
  | FloatToken f -> string_of_float f
  | ChineseNumberToken s -> s
  | StringToken s -> "\"" ^ s ^ "\""
  | BoolToken b -> string_of_bool b

let is_numeric = function
  | IntToken _ | FloatToken _ | ChineseNumberToken _ -> true
  | _ -> false

let is_string = function
  | StringToken _ -> true
  | _ -> false

let from_string s =
  try
    let i = int_of_string s in
    Some (IntToken i)
  with _ ->
    try
      let f = float_of_string s in
      Some (FloatToken f)
    with _ ->
      if s = "true" then Some (BoolToken true)
      else if s = "false" then Some (BoolToken false)
      else None