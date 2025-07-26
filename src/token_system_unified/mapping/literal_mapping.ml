(** 骆言Token系统整合重构 - 字面量映射管理 提供字面量的识别、解析和转换功能 *)

open Yyocamlc_lib.Token_types

(** 字面量映射模块 *)
module LiteralMapping = struct
  (** 中文数字映射 *)
  let chinese_digit_mapping =
    [
      ("零", 0);
      ("〇", 0);
      ("一", 1);
      ("壹", 1);
      ("二", 2);
      ("贰", 2);
      ("两", 2);
      ("三", 3);
      ("叁", 3);
      ("四", 4);
      ("肆", 4);
      ("五", 5);
      ("伍", 5);
      ("六", 6);
      ("陆", 6);
      ("七", 7);
      ("柒", 7);
      ("八", 8);
      ("捌", 8);
      ("九", 9);
      ("玖", 9);
    ]

  let chinese_unit_mapping =
    [
      ("十", 10);
      ("拾", 10);
      ("百", 100);
      ("佰", 100);
      ("千", 1000);
      ("仟", 1000);
      ("万", 10000);
      ("亿", 100000000);
    ]

  (** 中文布尔值映射 *)
  let chinese_bool_mapping =
    [
      ("真", true);
      ("是", true);
      ("对", true);
      ("有", true);
      ("假", false);
      ("否", false);
      ("错", false);
      ("无", false);
    ]

  (** 英文布尔值映射 *)
  let english_bool_mapping =
    [
      ("true", true);
      ("True", true);
      ("TRUE", true);
      ("false", false);
      ("False", false);
      ("FALSE", false);
    ]

  (** 创建查找表 *)
  let chinese_digit_table =
    let tbl = Hashtbl.create 32 in
    List.iter (fun (k, v) -> Hashtbl.add tbl k v) chinese_digit_mapping;
    tbl

  let chinese_unit_table =
    let tbl = Hashtbl.create 16 in
    List.iter (fun (k, v) -> Hashtbl.add tbl k v) chinese_unit_mapping;
    tbl

  let chinese_bool_table =
    let tbl = Hashtbl.create 16 in
    List.iter (fun (k, v) -> Hashtbl.add tbl k v) chinese_bool_mapping;
    tbl

  let english_bool_table =
    let tbl = Hashtbl.create 16 in
    List.iter (fun (k, v) -> Hashtbl.add tbl k v) english_bool_mapping;
    tbl

  (** 尝试解析整数 *)
  let try_parse_int text = try Some (int_of_string text) with Failure _ -> None

  (** 尝试解析浮点数 *)
  let try_parse_float text = try Some (float_of_string text) with Failure _ -> None

  (** 检查是否为字符串字面量 *)
  let is_string_literal text =
    let len = String.length text in
    len >= 2
    && ((text.[0] = '"' && text.[len - 1] = '"')
       || (text.[0] = '\'' && text.[len - 1] = '\'')
       || String.length text >= 6
          && String.sub text 0 3 = "\"\"\""
          && String.sub text (len - 3) 3 = "\"\"\"")

  (** 提取字符串内容 *)
  let extract_string_content text =
    let len = String.length text in
    if len >= 6 && String.sub text 0 3 = "\"\"\"" then String.sub text 3 (len - 6) (* 三重引号字符串 *)
    else if len >= 2 then String.sub text 1 (len - 2) (* 普通字符串 *)
    else text

  (** 查找中文数字 *)
  let lookup_chinese_digit text = Hashtbl.find_opt chinese_digit_table text

  (** 查找中文单位 *)
  let lookup_chinese_unit text = Hashtbl.find_opt chinese_unit_table text

  (** 简化版中文数字解析 *)
  let parse_simple_chinese_number text =
    (* 这里实现一个简化版本，只处理基本的中文数字 *)
    match lookup_chinese_digit text with
    | Some digit -> Some digit
    | None -> (
        match lookup_chinese_unit text with
        | Some unit -> Some unit
        | None ->
            (* 尝试组合解析，如"十二"、"二十"等 *)
            if String.contains text (String.get "十" 0) then
              try
                let parts = String.split_on_char (String.get "十" 0) text in
                match parts with
                | [ ""; right ] -> (
                    (* "十二" -> 12 *)
                    match lookup_chinese_digit right with
                    | Some d -> Some (10 + d)
                    | None -> Some 10)
                | [ left; "" ] -> (
                    (* "二十" -> 20 *)
                    match lookup_chinese_digit left with
                    | Some d -> Some (d * 10)
                    | None -> None)
                | [ left; right ] -> (
                    (* "二十三" -> 23 *)
                    match (lookup_chinese_digit left, lookup_chinese_digit right) with
                    | Some l, Some r -> Some ((l * 10) + r)
                    | _ -> None)
                | _ -> None
              with _ -> None
            else None)

  (** 检查是否为中文数字 *)
  let is_chinese_number text =
    match parse_simple_chinese_number text with Some _ -> true | None -> false

  (** 查找中文布尔值 *)
  let lookup_chinese_bool text = Hashtbl.find_opt chinese_bool_table text

  (** 查找英文布尔值 *)
  let lookup_english_bool text = Hashtbl.find_opt english_bool_table text

  (** 通用布尔值查找 *)
  let lookup_bool text =
    match lookup_chinese_bool text with Some b -> Some b | None -> lookup_english_bool text

  (** 字面量识别和解析 *)
  let parse_literal text =
    (* 尝试按优先级解析不同类型的字面量 *)
    if is_string_literal text then Some (Literals.StringToken (extract_string_content text))
    else
      match try_parse_int text with
      | Some i -> Some (Literals.IntToken i)
      | None -> (
          match try_parse_float text with
          | Some f -> Some (Literals.FloatToken f)
          | None -> (
              match lookup_bool text with
              | Some b -> Some (Literals.BoolToken b)
              | None -> if is_chinese_number text then Some (Literals.ChineseNumberToken text) else None))

  (** 字面量转换为字符串 *)
  let literal_to_string = function
    | Literals.IntToken i -> string_of_int i
    | Literals.FloatToken f -> string_of_float f
    | Literals.StringToken s -> "\"" ^ s ^ "\""
    | Literals.BoolToken true -> "真"
    | Literals.BoolToken false -> "假"
    | Literals.ChineseNumberToken s -> s
    | Literals.UnitToken -> "()"
    | Literals.NullToken -> "null" 
    | Literals.CharToken c -> "'" ^ String.make 1 c ^ "'"

  (** 字面量转换为英文字符串 *)
  let literal_to_english_string = function
    | Literals.IntToken i -> string_of_int i
    | Literals.FloatToken f -> string_of_float f
    | Literals.StringToken s -> "\"" ^ s ^ "\""
    | Literals.BoolToken true -> "true"
    | Literals.BoolToken false -> "false"
    | Literals.ChineseNumberToken s -> s (* 保持原样 *)
    | Literals.UnitToken -> "()"
    | Literals.NullToken -> "null" 
    | Literals.CharToken c -> "'" ^ String.make 1 c ^ "'"

  (** 检查字面量类型 *)
  let is_numeric_literal = function
    | Literals.IntToken _ | Literals.FloatToken _ | Literals.ChineseNumberToken _ -> true
    | Literals.UnitToken | Literals.NullToken -> true
    | Literals.StringToken _ | Literals.CharToken _ | Literals.BoolToken _ -> false

  let is_string_literal_token = function Literals.StringToken _ -> true | _ -> false
  let is_boolean_literal = function Literals.BoolToken _ -> true | _ -> false

  (** 获取字面量值 *)
  let get_literal_value = function
    | Literals.IntToken i -> `Int i
    | Literals.FloatToken f -> `Float f
    | Literals.StringToken s -> `String s
    | Literals.BoolToken b -> `Bool b
    | Literals.ChineseNumberToken s -> (
        match parse_simple_chinese_number s with Some i -> `Int i | None -> `String s)
    | Literals.UnitToken -> `Unit
    | Literals.NullToken -> `Null
    | Literals.CharToken c -> `Char c

  (** 字面量比较 *)
  let compare_literals lit1 lit2 =
    match (get_literal_value lit1, get_literal_value lit2) with
    | `Int i1, `Int i2 -> compare i1 i2
    | `Float f1, `Float f2 -> compare f1 f2
    | `String s1, `String s2 -> String.compare s1 s2
    | `Bool b1, `Bool b2 -> compare b1 b2
    | _ -> 0 (* 不同类型暂时返回相等 *)

  (** 获取所有支持的中文数字 *)
  let get_all_chinese_digits () = List.map fst chinese_digit_mapping

  (** 获取所有支持的中文单位 *)
  let get_all_chinese_units () = List.map fst chinese_unit_mapping

  (** 字面量统计信息 *)
  let get_literal_stats () =
    {|
支持的中文数字: |}
    ^ string_of_int (List.length chinese_digit_mapping)
    ^ {|
支持的中文单位: |}
    ^ string_of_int (List.length chinese_unit_mapping)
    ^ {|
支持的中文布尔值: |}
    ^ string_of_int (List.length chinese_bool_mapping)
    ^ {|
支持的英文布尔值: |}
    ^ string_of_int (List.length english_bool_mapping)
end

(** 字面量验证器 *)
module LiteralValidator = struct
  (** 验证整数范围 *)
  let validate_int_range i ~min_val ~max_val = i >= min_val && i <= max_val

  (** 验证浮点数范围 *)
  let validate_float_range f ~min_val ~max_val = f >= min_val && f <= max_val

  (** 验证字符串长度 *)
  let validate_string_length s ~max_length = String.length s <= max_length

  (** 验证字符串字符集 *)
  let validate_string_charset s ~allowed_chars =
    String.for_all (fun c -> String.contains allowed_chars c) s

  (** 全面验证字面量 *)
  let validate_literal = function
    | Literals.IntToken i -> validate_int_range i ~min_val:min_int ~max_val:max_int
    | Literals.FloatToken f -> not (classify_float f = FP_nan)
    | Literals.StringToken s -> validate_string_length s ~max_length:1000
    | Literals.BoolToken _ -> true
    | Literals.ChineseNumberToken s ->
        LiteralMapping.is_chinese_number s && validate_string_length s ~max_length:10
    | Literals.UnitToken | Literals.NullToken -> true
    | Literals.CharToken _ -> true
end
