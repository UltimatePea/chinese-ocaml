(** 中央Token注册器 - 统一管理所有Token映射和转换 *)

(* 为了避免循环依赖，我们定义自己的token类型 *)
type local_token =
  (* 字面量 *)
  | IntToken of int
  | FloatToken of float
  | ChineseNumberToken of string
  | StringToken of string
  | BoolToken of bool
  (* 标识符 *)
  | QuotedIdentifierToken of string
  | IdentifierTokenSpecial of string
  (* 基础关键字 *)
  | LetKeyword | RecKeyword | InKeyword | FunKeyword 
  | IfKeyword | ThenKeyword | ElseKeyword | MatchKeyword 
  | WithKeyword | OtherKeyword | AndKeyword | OrKeyword 
  | NotKeyword | TrueKeyword | FalseKeyword
  (* 类型关键字 *)
  | TypeKeyword | PrivateKeyword | IntTypeKeyword | FloatTypeKeyword 
  | StringTypeKeyword | BoolTypeKeyword | UnitTypeKeyword 
  | ListTypeKeyword | ArrayTypeKeyword
  (* 运算符 *)
  | Plus | Minus | Multiply | Divide | Equal | NotEqual 
  | Less | Greater | Arrow
  (* 其他 *)
  | UnknownToken

(** Token映射条目类型 *)
type token_mapping_entry = {
  source_token : string;  (* 源token名称 *)
  target_token : local_token;   (* 目标token类型 *)
  category : string;      (* 分类：literal, identifier, keyword, operator等 *)
  priority : int;         (* 优先级，用于冲突解决 *)
  description : string;   (* 描述信息 *)
}

(** Token注册表 *)
let token_registry = ref []

(** 注册token映射 *)
let register_token_mapping entry =
  token_registry := entry :: !token_registry

(** 查询token映射 *)
let find_token_mapping source_token =
  List.find_opt (fun entry -> entry.source_token = source_token) !token_registry

(** 获取按优先级排序的映射 *)
let get_sorted_mappings () =
  List.sort (fun a b -> compare b.priority a.priority) !token_registry

(** 获取按分类分组的映射 *)
let get_mappings_by_category category =
  List.filter (fun entry -> entry.category = category) !token_registry

(** 统计信息 *)
let get_registry_stats () =
  let total = List.length !token_registry in
  let categories = List.map (fun entry -> entry.category) !token_registry |> 
    List.sort_uniq String.compare in
  let category_counts = List.map (fun cat ->
    (cat, List.length (get_mappings_by_category cat))
  ) categories in
  {|
=== Token注册器统计 ===
注册Token数: %d 个
分类数: %d 个
分类详情: %s
  |} total (List.length categories) 
     (String.concat ", " (List.map (fun (cat, count) -> 
       Printf.sprintf "%s(%d)" cat count) category_counts))

(** 初始化注册器 - 注册所有基础映射 *)
let initialize_registry () =
  (* 清空现有注册 *)
  token_registry := [];
  
  (* 注册字面量tokens *)
  register_token_mapping {
    source_token = "IntToken";
    target_token = IntToken 0;
    category = "literal";
    priority = 100;
    description = "整数字面量";
  };
  
  register_token_mapping {
    source_token = "FloatToken";
    target_token = FloatToken 0.0;
    category = "literal";
    priority = 100;
    description = "浮点数字面量";
  };
  
  register_token_mapping {
    source_token = "StringToken";
    target_token = StringToken "";
    category = "literal";
    priority = 100;
    description = "字符串字面量";
  };
  
  register_token_mapping {
    source_token = "BoolToken";
    target_token = BoolToken false;
    category = "literal";
    priority = 100;
    description = "布尔字面量";
  };
  
  register_token_mapping {
    source_token = "ChineseNumberToken";
    target_token = ChineseNumberToken "";
    category = "literal";
    priority = 100;
    description = "中文数字字面量";
  };
  
  (* 注册标识符tokens *)
  register_token_mapping {
    source_token = "QuotedIdentifierToken";
    target_token = QuotedIdentifierToken "";
    category = "identifier";
    priority = 100;
    description = "引用标识符";
  };
  
  register_token_mapping {
    source_token = "IdentifierTokenSpecial";
    target_token = IdentifierTokenSpecial "";
    category = "identifier";
    priority = 100;
    description = "特殊标识符";
  };
  
  (* 注册基础关键字tokens *)
  let basic_keywords = [
    ("LetKeyword", LetKeyword, "让 - let");
    ("RecKeyword", RecKeyword, "递归 - rec");
    ("InKeyword", InKeyword, "在 - in");
    ("FunKeyword", FunKeyword, "函数 - fun");
    ("IfKeyword", IfKeyword, "如果 - if");
    ("ThenKeyword", ThenKeyword, "那么 - then");
    ("ElseKeyword", ElseKeyword, "否则 - else");
    ("MatchKeyword", MatchKeyword, "匹配 - match");
    ("WithKeyword", WithKeyword, "与 - with");
    ("OtherKeyword", OtherKeyword, "其他 - other");
    ("AndKeyword", AndKeyword, "并且 - and");
    ("OrKeyword", OrKeyword, "或者 - or");
    ("NotKeyword", NotKeyword, "非 - not");
    ("TrueKeyword", TrueKeyword, "真 - true");
    ("FalseKeyword", FalseKeyword, "假 - false");
  ] in
  
  List.iter (fun (name, token, desc) ->
    register_token_mapping {
      source_token = name;
      target_token = token;
      category = "basic_keyword";
      priority = 90;
      description = desc;
    }
  ) basic_keywords;
  
  (* 注册类型关键字tokens *)
  let type_keywords = [
    ("TypeKeyword", TypeKeyword, "类型 - type");
    ("PrivateKeyword", PrivateKeyword, "私有 - private");
    ("IntTypeKeyword", IntTypeKeyword, "整数类型 - int");
    ("FloatTypeKeyword", FloatTypeKeyword, "浮点数类型 - float");
    ("StringTypeKeyword", StringTypeKeyword, "字符串类型 - string");
    ("BoolTypeKeyword", BoolTypeKeyword, "布尔类型 - bool");
    ("UnitTypeKeyword", UnitTypeKeyword, "单元类型 - unit");
    ("ListTypeKeyword", ListTypeKeyword, "列表类型 - list");
    ("ArrayTypeKeyword", ArrayTypeKeyword, "数组类型 - array");
  ] in
  
  List.iter (fun (name, token, desc) ->
    register_token_mapping {
      source_token = name;
      target_token = token;
      category = "type_keyword";
      priority = 85;
      description = desc;
    }
  ) type_keywords;
  
  (* 注册运算符tokens *)
  let operators = [
    ("Plus", Plus, "加法 - +");
    ("Minus", Minus, "减法 - -");
    ("Multiply", Multiply, "乘法 - *");
    ("Divide", Divide, "除法 - /");
    ("Equal", Equal, "等于 - ==");
    ("NotEqual", NotEqual, "不等于 - <>");
    ("Less", Less, "小于 - <");
    ("Greater", Greater, "大于 - >");
    ("Arrow", Arrow, "箭头 - ->");
  ] in
  
  List.iter (fun (name, token, desc) ->
    register_token_mapping {
      source_token = name;
      target_token = token;
      category = "operator";
      priority = 80;
      description = desc;
    }
  ) operators;
  
  Printf.printf "%s\n" (get_registry_stats ())

(** 验证注册器一致性 *)
let validate_registry () =
  let mappings = !token_registry in
  let duplicates = List.fold_left (fun acc entry ->
    let count = List.length (List.filter (fun e -> e.source_token = entry.source_token) mappings) in
    if count > 1 then entry.source_token :: acc else acc
  ) [] mappings |> List.sort_uniq String.compare in
  
  if duplicates = [] then
    Printf.printf "✅ Token注册器验证通过，无重复映射\n"
  else
    Printf.printf "❌ Token注册器验证失败，发现重复映射: %s\n" 
      (String.concat ", " duplicates)

(** 生成token转换函数 *)
let generate_token_converter () =
  let mappings = get_sorted_mappings () in
  let conversion_cases = List.map (fun entry ->
    Printf.sprintf "  | %s -> %s (* %s *)" 
      entry.source_token 
      (match entry.target_token with
       | LetKeyword -> "LetKeyword"
       | RecKeyword -> "RecKeyword"
       | InKeyword -> "InKeyword"
       | FunKeyword -> "FunKeyword"
       | IfKeyword -> "IfKeyword"
       | ThenKeyword -> "ThenKeyword"
       | ElseKeyword -> "ElseKeyword"
       | MatchKeyword -> "MatchKeyword"
       | WithKeyword -> "WithKeyword"
       | OtherKeyword -> "OtherKeyword"
       | AndKeyword -> "AndKeyword"
       | OrKeyword -> "OrKeyword"
       | NotKeyword -> "NotKeyword"
       | TrueKeyword -> "TrueKeyword"
       | FalseKeyword -> "FalseKeyword"
       | TypeKeyword -> "TypeKeyword"
       | PrivateKeyword -> "PrivateKeyword"
       | IntTypeKeyword -> "IntTypeKeyword"
       | FloatTypeKeyword -> "FloatTypeKeyword"
       | StringTypeKeyword -> "StringTypeKeyword"
       | BoolTypeKeyword -> "BoolTypeKeyword"
       | UnitTypeKeyword -> "UnitTypeKeyword"
       | ListTypeKeyword -> "ListTypeKeyword"
       | ArrayTypeKeyword -> "ArrayTypeKeyword"
       | Plus -> "Plus"
       | Minus -> "Minus"
       | Multiply -> "Multiply"
       | Divide -> "Divide"
       | Equal -> "Equal"
       | NotEqual -> "NotEqual"
       | Less -> "Less"
       | Greater -> "Greater"
       | Arrow -> "Arrow"
       | IntToken _ -> "IntToken value"
       | FloatToken _ -> "FloatToken value"
       | StringToken _ -> "StringToken value"
       | BoolToken _ -> "BoolToken value"
       | ChineseNumberToken _ -> "ChineseNumberToken value"
       | QuotedIdentifierToken _ -> "QuotedIdentifierToken value"
       | IdentifierTokenSpecial _ -> "IdentifierTokenSpecial value"
       | _ -> "UnknownToken")
      entry.description
  ) mappings in
  
  Printf.sprintf {|
(** 自动生成的Token转换函数 *)
let convert_registered_token = function
%s
  | _ -> failwith "未注册的token类型"
|} (String.concat "\n" conversion_cases)