(** Token注册器 - 标识符Token注册功能 *)

open Token_definitions_unified
open Token_registry_core

(** 注册标识符Token映射 *)
let register_identifier_tokens () =
  let identifiers =
    [
      ("QuotedIdentifierToken", QuotedIdentifierToken "", "引用标识符");
      ("IdentifierTokenSpecial", IdentifierTokenSpecial "", "特殊标识符");
    ]
  in
  List.iter
    (fun (name, token, desc) ->
      register_token_mapping
        {
          source_token = name;
          target_token = token;
          category = "identifier";
          priority = 100;
          description = desc;
        })
    identifiers

(** 标识符Token的代码生成 *)
let generate_identifier_token_code = function
  | QuotedIdentifierToken _ -> "QuotedIdentifierToken value"
  | IdentifierTokenSpecial _ -> "IdentifierTokenSpecial value"
  | _ -> invalid_arg "generate_identifier_token_code: 不是标识符token"
