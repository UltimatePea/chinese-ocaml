(** 简化的Token映射器 - 避免循环依赖的简单实现 *)

(** 简化的token类型，避免依赖主要的lexer_tokens *)
type simple_token =
  | IntToken of int
  | StringToken of string  
  | KeywordToken of string
  | OperatorToken of string
  | UnknownToken of string

(** Token映射条目 *)
type mapping_entry = {
  name : string;
  category : string;
  description : string;
}

(** 简单的token映射表 *)
let token_mappings = [
  { name = "LetKeyword"; category = "keyword"; description = "让 - let" };
  { name = "IfKeyword"; category = "keyword"; description = "如果 - if" };
  { name = "ThenKeyword"; category = "keyword"; description = "那么 - then" };
  { name = "ElseKeyword"; category = "keyword"; description = "否则 - else" };
  { name = "Plus"; category = "operator"; description = "加法 - +" };
  { name = "Minus"; category = "operator"; description = "减法 - -" };
  { name = "Equal"; category = "operator"; description = "等于 - ==" };
]

(** 查找token映射 *)
let find_mapping name = 
  List.find_opt (fun entry -> entry.name = name) token_mappings

(** 简单的token转换 *)
let convert_token name int_value string_value =
  match find_mapping name with
  | Some entry ->
      (match entry.category with
       | "keyword" -> KeywordToken name
       | "operator" -> OperatorToken name  
       | _ -> UnknownToken name)
  | None ->
      (match name with
       | "IntToken" when int_value <> None -> 
           IntToken (Option.get int_value)
       | "StringToken" when string_value <> None -> 
           StringToken (Option.get string_value)
       | _ -> UnknownToken name)

(** 获取统计信息 *)
let get_stats () =
  let total = List.length token_mappings in
  let categories = List.map (fun e -> e.category) token_mappings 
    |> List.sort_uniq String.compare in
  Printf.sprintf "注册Token数: %d, 分类: %s" total (String.concat ", " categories)

(** 测试函数 *)
let test_mapping () =
  Printf.printf "=== 简化Token映射器测试 ===\n";
  Printf.printf "%s\n" (get_stats ());
  
  let test_cases = [
    ("LetKeyword", None, None);
    ("IfKeyword", None, None);
    ("Plus", None, None);
    ("IntToken", Some 42, None);
    ("StringToken", None, Some "测试");
    ("UnknownToken", None, None);
  ] in
  
  List.iter (fun (name, int_val, str_val) ->
    let result = convert_token name int_val str_val in
    Printf.printf "映射 %s -> %s\n" name 
      (match result with
       | IntToken i -> Printf.sprintf "IntToken(%d)" i
       | StringToken s -> Printf.sprintf "StringToken(%s)" s
       | KeywordToken k -> Printf.sprintf "KeywordToken(%s)" k
       | OperatorToken o -> Printf.sprintf "OperatorToken(%s)" o
       | UnknownToken u -> Printf.sprintf "UnknownToken(%s)" u)
  ) test_cases