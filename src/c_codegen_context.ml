(** 骆言C代码生成器上下文模块 - Chinese Programming Language C Code Generator Context Module *)

(** 代码生成配置 *)
type codegen_config = {
  c_output_file : string;
  include_debug : bool;
  optimize : bool;
  runtime_path : string;
}

(** 代码生成上下文 *)
type codegen_context = {
  config : codegen_config;
  mutable next_var_id : int;
  mutable next_label_id : int;
  mutable includes : string list;
  mutable global_vars : string list;
  mutable functions : string list;
}

(** 创建代码生成上下文 *)
let create_context config =
  {
    config;
    next_var_id = 0;
    next_label_id = 0;
    includes = [ "luoyan_runtime.h" ];
    global_vars = [];
    functions = [];
  }

(** 生成唯一变量名 *)
let gen_var_name ctx prefix =
  let id = ctx.next_var_id in
  ctx.next_var_id <- id + 1;
  Printf.sprintf "luoyan_var_%s_%d" prefix id

(** 生成唯一标签名 *)
let gen_label_name ctx prefix =
  let id = ctx.next_label_id in
  ctx.next_label_id <- id + 1;
  Printf.sprintf "luoyan_label_%s_%d" prefix id

(** 转义标识符名称 *)
let escape_identifier name =
  (* 检查是否包含中文字符 *)
  let has_chinese = ref false in
  let len = String.length name in
  let i = ref 0 in
  while !i < len && not !has_chinese do
    let c = name.[!i] in
    (* 检查UTF-8编码的中文字符 *)
    if Char.code c >= 0xE4 && Char.code c <= 0xE9 then
      has_chinese := true;
    incr i
  done;
  
  if !has_chinese then (
    (* 包含中文字符，但保留原样 *)
    let buf = Buffer.create (String.length name * 2) in
    String.iter
      (function
        | ('0' .. '9' | 'a' .. 'z' | 'A' .. 'Z' | '_') as c -> Buffer.add_char buf c
        | ' ' -> Buffer.add_string buf "_space_"
        | '-' -> Buffer.add_string buf "_dash_"
        | '+' -> Buffer.add_string buf "_plus_"
        | '*' -> Buffer.add_string buf "_star_"
        | '/' -> Buffer.add_string buf "_slash_"
        | '=' -> Buffer.add_string buf "_eq_"
        | '!' -> Buffer.add_string buf "_excl_"
        | '?' -> Buffer.add_string buf "_quest_"
        | '.' -> Buffer.add_string buf "_dot_"
        | ',' -> Buffer.add_string buf "_comma_"
        | ':' -> Buffer.add_string buf "_colon_"
        | ';' -> Buffer.add_string buf "_semicolon_"
        | '(' -> Buffer.add_string buf "_lparen_"
        | ')' -> Buffer.add_string buf "_rparen_"
        | '[' -> Buffer.add_string buf "_lbracket_"
        | ']' -> Buffer.add_string buf "_rbracket_"
        | '{' -> Buffer.add_string buf "_lbrace_"
        | '}' -> Buffer.add_string buf "_rbrace_"
        | '<' -> Buffer.add_string buf "_lt_"
        | '>' -> Buffer.add_string buf "_gt_"
        | '\'' -> Buffer.add_string buf "_quote_"
        | '"' -> Buffer.add_string buf "_dquote_"
        | '\\' -> Buffer.add_string buf "_backslash_"
        | '|' -> Buffer.add_string buf "_pipe_"
        | '&' -> Buffer.add_string buf "_amp_"
        | '%' -> Buffer.add_string buf "_percent_"
        | '^' -> Buffer.add_string buf "_caret_"
        | '~' -> Buffer.add_string buf "_tilde_"
        | '@' -> Buffer.add_string buf "_at_"
        | '#' -> Buffer.add_string buf "_hash_"
        | '$' -> Buffer.add_string buf "_dollar_"
        | '\n' -> Buffer.add_string buf "_newline_"
        | '\r' -> Buffer.add_string buf "_carriage_"
        | '\t' -> Buffer.add_string buf "_tab_"
        | c when Char.code c >= 32 && Char.code c <= 126 ->
            (* 其他ASCII可打印字符，转义为安全形式 *)
            Buffer.add_string buf (Printf.sprintf "_ascii%d_" (Char.code c))
        | c ->
            (* 保留中文和其他Unicode字符 *)
            Buffer.add_char buf c)
      name;
    Buffer.contents buf
  ) else (
    (* 不含中文字符，检查是否为C关键字 *)
    match name with
    | "auto" | "break" | "case" | "char" | "const" | "continue" | "default" | "do"
    | "double" | "else" | "enum" | "extern" | "float" | "for" | "goto" | "if"
    | "int" | "long" | "register" | "return" | "short" | "signed" | "sizeof" | "static"
    | "struct" | "switch" | "typedef" | "union" | "unsigned" | "void" | "volatile" | "while"
    | "inline" | "restrict" | "_Bool" | "_Complex" | "_Imaginary" ->
        "luoyan_" ^ name
    | _ -> name
  )

(** 将骆言类型转换为C类型 *)
let c_type_of_luoyan_type = function
  | Types.IntType_T -> "luoyan_int_t"
  | Types.FloatType_T -> "luoyan_float_t"
  | Types.StringType_T -> "luoyan_string_t*"
  | Types.BoolType_T -> "luoyan_bool_t"
  | Types.UnitType_T -> "void"
  | Types.ListType_T _ -> "luoyan_list_t*"
  | Types.ArrayType_T _ -> "luoyan_array_t*"
  | Types.FunType_T (_, _) -> "luoyan_function_t*"
  | Types.RefType_T _ -> "luoyan_ref_t*"
  | Types.TupleType_T _ -> "luoyan_tuple_t*"
  | Types.TypeVar_T name -> Printf.sprintf "luoyan_var_%s_t*" (escape_identifier name)
  | Types.ConstructType_T (name, _) -> Printf.sprintf "luoyan_user_%s_t*" (escape_identifier name)
  | Types.RecordType_T _ -> "luoyan_record_t*"
  | Types.ClassType_T (name, _) -> Printf.sprintf "luoyan_class_%s_t*" (escape_identifier name)
  | Types.ObjectType_T _ -> "luoyan_object_t*"
  | Types.PrivateType_T (name, _) -> Printf.sprintf "luoyan_private_%s_t*" (escape_identifier name)
  | Types.PolymorphicVariantType_T _ -> "luoyan_variant_t*"
