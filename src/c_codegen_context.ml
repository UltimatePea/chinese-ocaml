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
    (* 包含中文字符，需要转换为拼音或ASCII形式 *)
    let buf = Buffer.create (String.length name * 2) in
    let rec process_char i =
      if i >= String.length name then
        Buffer.contents buf
      else
        let c = name.[i] in
        (* 简化的中文字符处理 - 仅处理ASCII字符 *)
        if Char.code c < 128 then (
          Buffer.add_char buf c;
          process_char (i + 1)
        ) else (
          Buffer.add_string buf (Printf.sprintf "u%02x" (Char.code c));
          process_char (i + 1)
        )
    in
    process_char 0
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
  | Types.StringType_T -> "luoyan_string_t"
  | Types.BoolType_T -> "luoyan_bool_t"
  | Types.UnitType_T -> "luoyan_unit_t"
  | Types.ListType_T _ -> "luoyan_list_t"
  | Types.ArrayType_T _ -> "luoyan_array_t"
  | Types.FunType_T (_, _) -> "luoyan_function_t"
  | Types.RefType_T _ -> "luoyan_ref_t"
  | Types.TupleType_T _ -> "luoyan_tuple_t"
  | Types.TypeVar_T name -> Printf.sprintf "luoyan_var_%s_t" (escape_identifier name)
  | Types.ConstructType_T (name, _) -> Printf.sprintf "luoyan_user_%s_t" (escape_identifier name)
  | Types.RecordType_T _ -> "luoyan_record_t"
  | Types.ClassType_T (name, _) -> Printf.sprintf "luoyan_class_%s_t" (escape_identifier name)
  | Types.ObjectType_T _ -> "luoyan_object_t"
  | Types.PrivateType_T (name, _) -> Printf.sprintf "luoyan_private_%s_t" (escape_identifier name)
  | Types.PolymorphicVariantType_T _ -> "luoyan_variant_t"