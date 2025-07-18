(** 骆言C代码生成器上下文模块 - Chinese Programming Language C Code Generator Context Module *)

type codegen_config = {
  c_output_file : string;
  include_debug : bool;
  optimize : bool;
  runtime_path : string;
}
(** 代码生成配置 *)

type codegen_context = {
  config : codegen_config;
  mutable next_var_id : int;
  mutable next_label_id : int;
  mutable includes : string list;
  mutable global_vars : string list;
  mutable functions : string list;
}
(** 代码生成上下文 *)

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

(** 检查字符串是否包含中文字符 *)
let has_chinese_chars name =
  let len = String.length name in
  let i = ref 0 in
  let found = ref false in
  while !i < len && not !found do
    let c = name.[!i] in
    if Char.code c >= 0xE4 && Char.code c <= 0xE9 then found := true;
    incr i
  done;
  !found

(** 转义特殊字符为C安全的字符串 *)
let escape_special_chars c =
  match c with
  | ('0' .. '9' | 'a' .. 'z' | 'A' .. 'Z' | '_') as c -> String.make 1 c
  | ' ' -> "_space_"
  | '-' -> "_dash_"
  | '+' -> "_plus_"
  | '*' -> "_star_"
  | '/' -> "_slash_"
  | '=' -> "_eq_"
  | '!' -> "_excl_"
  | '?' -> "_quest_"
  | '.' -> "_dot_"
  | ',' -> "_comma_"
  | ':' -> "_colon_"
  | ';' -> "_semicolon_"
  | '(' -> "_lparen_"
  | ')' -> "_rparen_"
  | '[' -> "_lbracket_"
  | ']' -> "_rbracket_"
  | '{' -> "_lbrace_"
  | '}' -> "_rbrace_"
  | '<' -> "_lt_"
  | '>' -> "_gt_"
  | '\'' -> "_quote_"
  | '"' -> "_dquote_"
  | '\\' -> "_backslash_"
  | '|' -> "_pipe_"
  | '&' -> "_amp_"
  | '%' -> "_percent_"
  | '^' -> "_caret_"
  | '~' -> "_tilde_"
  | '@' -> "_at_"
  | '#' -> "_hash_"
  | '$' -> "_dollar_"
  | '\n' -> "_newline_"
  | '\r' -> "_carriage_"
  | '\t' -> "_tab_"
  | c when Char.code c >= 32 && Char.code c <= 126 -> Printf.sprintf "_ascii%d_" (Char.code c)
  | c -> String.make 1 c

(** 转义包含中文的标识符 *)
let escape_chinese_identifier name =
  let buf = Buffer.create (String.length name * 2) in
  String.iter (fun c -> Buffer.add_string buf (escape_special_chars c)) name;
  Buffer.contents buf

(** 检查是否为C关键字并添加前缀 *)
let format_c_keyword name =
  match name with
  | "auto" | "break" | "case" | "char" | "const" | "continue" | "default" | "do" | "double" | "else"
  | "enum" | "extern" | "float" | "for" | "goto" | "if" | "int" | "long" | "register" | "return"
  | "short" | "signed" | "sizeof" | "static" | "struct" | "switch" | "typedef" | "union"
  | "unsigned" | "void" | "volatile" | "while" | "inline" | "restrict" | "_Bool" | "_Complex"
  | "_Imaginary" ->
      "luoyan_" ^ name
  | _ -> name

(** 转义标识符名称 *)
let escape_identifier name =
  if has_chinese_chars name then escape_chinese_identifier name else format_c_keyword name

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
