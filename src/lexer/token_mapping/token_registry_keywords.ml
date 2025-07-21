(** Token注册器 - 关键字Token注册功能 *)

open Token_definitions_unified
open Token_registry_core

(** 注册基础关键字Token映射 *)
let register_basic_keywords () =
  let basic_keywords =
    [
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
    ]
  in
  List.iter
    (fun (name, token, desc) ->
      register_token_mapping
        {
          source_token = name;
          target_token = token;
          category = "basic_keyword";
          priority = 90;
          description = desc;
        })
    basic_keywords

(** 注册类型关键字Token映射 *)
let register_type_keywords () =
  let type_keywords =
    [
      ("TypeKeyword", TypeKeyword, "类型 - type");
      ("PrivateKeyword", PrivateKeyword, "私有 - private");
      ("IntTypeKeyword", IntTypeKeyword, "整数类型 - int");
      ("FloatTypeKeyword", FloatTypeKeyword, "浮点数类型 - float");
      ("StringTypeKeyword", StringTypeKeyword, "字符串类型 - string");
      ("BoolTypeKeyword", BoolTypeKeyword, "布尔类型 - bool");
      ("UnitTypeKeyword", UnitTypeKeyword, "单元类型 - unit");
      ("ListTypeKeyword", ListTypeKeyword, "列表类型 - list");
      ("ArrayTypeKeyword", ArrayTypeKeyword, "数组类型 - array");
    ]
  in
  List.iter
    (fun (name, token, desc) ->
      register_token_mapping
        {
          source_token = name;
          target_token = token;
          category = "type_keyword";
          priority = 85;
          description = desc;
        })
    type_keywords

(** 基础关键字Token的代码生成 *)
let generate_basic_keyword_code = function
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
  | _ -> invalid_arg "generate_basic_keyword_code: 不是基础关键字token"

(** 类型关键字Token的代码生成 *)
let generate_type_keyword_code = function
  | TypeKeyword -> "TypeKeyword"
  | PrivateKeyword -> "PrivateKeyword"
  | IntTypeKeyword -> "IntTypeKeyword"
  | FloatTypeKeyword -> "FloatTypeKeyword"
  | StringTypeKeyword -> "StringTypeKeyword"
  | BoolTypeKeyword -> "BoolTypeKeyword"
  | UnitTypeKeyword -> "UnitTypeKeyword"
  | ListTypeKeyword -> "ListTypeKeyword"
  | ArrayTypeKeyword -> "ArrayTypeKeyword"
  | _ -> invalid_arg "generate_type_keyword_code: 不是类型关键字token"
