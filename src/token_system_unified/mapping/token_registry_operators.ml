(** Token注册器 - 运算符Token注册功能 *)

open Token_definitions_unified
open Token_registry_core

(** 注册运算符Token映射 *)
let register_operator_tokens () =
  (* 基础运算符的映射，使用统一token定义中的适当token类型 *)
  let operators =
    [
      ("Plus", IntToken 1, "加法 - +");
      (* 使用IntToken作为占位符 *)
      ("Minus", IntToken (-1), "减法 - -");
      ("Multiply", IntToken 2, "乘法 - *");
      ("Divide", IntToken 3, "除法 - /");
      ("Equal", BoolToken true, "等于 - ==");
      (* 使用BoolToken作为占位符 *)
      ("NotEqual", BoolToken false, "不等于 - <>");
      ("Less", BoolToken false, "小于 - <");
      ("Greater", BoolToken true, "大于 - >");
      ("Arrow", StringToken "->", "箭头 - ->");
      (* 使用StringToken作为占位符 *)
    ]
  in
  List.iter
    (fun (name, token, desc) ->
      register_token_mapping
        {
          source_token = name;
          target_token = token;
          category = "operator";
          priority = 80;
          description = desc;
        })
    operators

(** 运算符Token的代码生成 *)
let generate_operator_code source_token =
  match source_token with
  | "Plus" -> "Plus"
  | "Minus" -> "Minus"
  | "Multiply" -> "Multiply"
  | "Divide" -> "Divide"
  | "Equal" -> "Equal"
  | "NotEqual" -> "NotEqual"
  | "Less" -> "Less"
  | "Greater" -> "Greater"
  | "Arrow" -> "Arrow"
  | _ -> invalid_arg "generate_operator_code: 不是运算符token"
