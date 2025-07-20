(** Token注册器 - 字面量Token注册功能 *)

open Token_definitions_unified
open Token_registry_core

(** 注册字面量Token映射 *)
let register_literal_tokens () =
  let literals = [
    ("IntToken", IntToken 0, "整数字面量");
    ("FloatToken", FloatToken 0.0, "浮点数字面量");
    ("StringToken", StringToken "", "字符串字面量");
    ("BoolToken", BoolToken false, "布尔字面量");
    ("ChineseNumberToken", ChineseNumberToken "", "中文数字字面量");
  ] in
  List.iter (fun (name, token, desc) ->
    register_token_mapping {
      source_token = name;
      target_token = token;
      category = "literal";
      priority = 100;
      description = desc;
    }
  ) literals

(** 字面量Token的代码生成 *)
let generate_literal_token_code = function
  | IntToken _ -> "IntToken value"
  | FloatToken _ -> "FloatToken value"
  | StringToken _ -> "StringToken value"
  | BoolToken _ -> "BoolToken value"
  | ChineseNumberToken _ -> "ChineseNumberToken value"
  | _ -> invalid_arg "generate_literal_token_code: 不是字面量token"