(** 骆言语法分析器类型解析模块 - Chinese Programming Language Parser Types *)

open Ast
open Lexer
open Parser_utils

(** 变体类型解析 *)

(** 解析变体标签 *)
let rec parse_variant_labels state acc =
  let token, pos = current_token state in
  match token with
  | QuotedIdentifierToken label ->
      let state1 = advance_parser state in
      let token, _ = current_token state1 in
      if is_type_colon token then
        (* 有类型的变体标签：「标签」 : 类型 *)
        let state2 = advance_parser state1 in
        let type_expr, state3 = parse_type_expression state2 in
        let variant = (label, Some type_expr) in
        let token, _ = current_token state3 in
        if token = Pipe || token = OrKeyword then
          let state4 = advance_parser state3 in
          parse_variant_labels state4 (variant :: acc)
        else (List.rev (variant :: acc), state3)
      else
        (* 无类型的变体标签：「标签」 *)
        let variant = (label, None) in
        let token, _ = current_token state1 in
        if token = Pipe || token = OrKeyword then
          let state2 = advance_parser state1 in
          parse_variant_labels state2 (variant :: acc)
        else (List.rev (variant :: acc), state1)
  | _ -> if List.length acc = 0 then raise (SyntaxError ("期望变体标签", pos)) else (List.rev acc, state)

(** 类型表达式解析 *)

(** 解析基本类型表达式（用于标签参数） *)
and parse_basic_type_expression state =
  let token, pos = current_token state in
  match token with
  | IntTypeKeyword -> (BaseTypeExpr IntType, advance_parser state)
  | FloatTypeKeyword -> (BaseTypeExpr FloatType, advance_parser state)
  | StringTypeKeyword -> (BaseTypeExpr StringType, advance_parser state)
  | BoolTypeKeyword -> (BaseTypeExpr BoolType, advance_parser state)
  | UnitTypeKeyword -> (BaseTypeExpr UnitType, advance_parser state)
  | ListTypeKeyword -> (TypeVar "列表", advance_parser state)
  | ArrayTypeKeyword -> (TypeVar "数组", advance_parser state)
  | VariantKeyword ->
      (* 多态变体类型：变体 「标签1」 | 「标签2」 类型 | ... *)
      let state1 = advance_parser state in
      let variants, state2 = parse_variant_labels state1 [] in
      (PolymorphicVariantType variants, state2)
  | QuotedIdentifierToken name ->
      (* 用户定义的类型必须使用引用语法 *)
      let state1 = advance_parser state in
      (TypeVar name, state1)
  | LeftParen | ChineseLeftParen ->
      (* 括号类型表达式 *)
      let state1 = advance_parser state in
      let inner_type, state2 = parse_basic_type_expression state1 in
      let state3 =
        let token, pos = current_token state2 in
        if is_right_paren token then advance_parser state2 else raise (SyntaxError ("期望右括号", pos))
      in
      (inner_type, state3)
  | _ -> raise (SyntaxError ("期望类型表达式", pos))

(** 解析类型表达式 *)
and parse_type_expression state =
  let parse_primary_type_expression state =
    let token, pos = current_token state in
    match token with
    | IntTypeKeyword -> (BaseTypeExpr IntType, advance_parser state)
    | FloatTypeKeyword -> (BaseTypeExpr FloatType, advance_parser state)
    | StringTypeKeyword -> (BaseTypeExpr StringType, advance_parser state)
    | BoolTypeKeyword -> (BaseTypeExpr BoolType, advance_parser state)
    | UnitTypeKeyword -> (BaseTypeExpr UnitType, advance_parser state)
    | ListTypeKeyword -> (TypeVar "列表", advance_parser state)
    | ArrayTypeKeyword -> (TypeVar "数组", advance_parser state)
    | VariantKeyword ->
        (* 多态变体类型：变体 「标签1」 | 「标签2」 类型 | ... *)
        let state1 = advance_parser state in
        let variants, state2 = parse_variant_labels state1 [] in
        (PolymorphicVariantType variants, state2)
    | QuotedIdentifierToken name ->
        (* 用户定义的类型必须使用引用语法 *)
        let state1 = advance_parser state in
        (TypeVar name, state1)
    | LeftParen | ChineseLeftParen ->
        (* 括号类型表达式 *)
        let state1 = advance_parser state in
        let inner_type, state2 = parse_type_expression state1 in
        let state3 =
          let token, pos = current_token state2 in
          if is_right_paren token then advance_parser state2 else raise (SyntaxError ("期望右括号", pos))
        in
        (inner_type, state3)
    | _ -> raise (SyntaxError ("期望类型表达式", pos))
  in
  let rec parse_function_type left_type state =
    let token, _ = current_token state in
    if is_arrow token then
      let state1 = advance_parser state in
      let right_type, state2 = parse_primary_type_expression state1 in
      let function_type = FunType (left_type, right_type) in
      parse_function_type function_type state2
    else (left_type, state)
  in
  let primary_type, state1 = parse_primary_type_expression state in
  parse_function_type primary_type state1

(** 类型定义解析 *)

(** 解析类型定义 *)
let rec parse_type_definition state =
  let token, _ = current_token state in
  match token with
  | Pipe | ChinesePipe ->
      (* Algebraic type with variants: | Constructor1 | Constructor2 of type | ... *)
      parse_variant_constructors state []
  | PrivateKeyword ->
      (* Private type: 私有 type_expr *)
      let state1 = advance_parser state in
      let type_expr, state2 = parse_type_expression state1 in
      (PrivateType type_expr, state2)
  | VariantKeyword ->
      (* Polymorphic variant type: 变体 「标签1」 | 「标签2」 类型 | ... *)
      let state1 = advance_parser state in
      let variants, state2 = parse_variant_labels state1 [] in
      (PolymorphicVariantTypeDef variants, state2)
  | _ ->
      (* Type alias: existing_type *)
      let type_expr, state1 = parse_type_expression state in
      (AliasType type_expr, state1)

(** 解析变体构造器列表 *)
and parse_variant_constructors state constructors =
  let token, _ = current_token state in
  match token with
  | Pipe | ChinesePipe -> (
      let state1 = advance_parser state in
      let constructor_name, state2 = parse_identifier_allow_keywords state1 in
      let token, _ = current_token state2 in
      match token with
      | OfKeyword ->
          (* Constructor with type: | Name of type *)
          let state3 = advance_parser state2 in
          let type_expr, state4 = parse_type_expression state3 in
          let new_constructor = (constructor_name, Some type_expr) in
          parse_variant_constructors state4 (new_constructor :: constructors)
      | _ ->
          (* Constructor without type: | Name *)
          let new_constructor = (constructor_name, None) in
          parse_variant_constructors state2 (new_constructor :: constructors))
  | _ ->
      (* End of constructors *)
      (AlgebraicType (List.rev constructors), state)

(** 模块类型解析 *)

(** 跳过换行符函数 *)
let rec skip_newlines state =
  let token, _ = current_token state in
  if token = EOF then state
  else if token = Semicolon || token = ChineseSemicolon then skip_newlines (advance_parser state)
  else state

(** 解析模块类型 *)
and parse_module_type state =
  let token, _pos = current_token state in
  match token with
  | SigKeyword ->
      let state1 = advance_parser state in
      let signature_items, state2 = parse_signature_items [] state1 in
      let state3 = expect_token state2 EndKeyword in
      (Signature signature_items, state3)
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      (ModuleTypeName name, state1)
  | _ ->
      let token, pos = current_token state in
      raise (SyntaxError ("期望模块类型定义，但遇到 " ^ show_token token, pos))

(** 解析签名项列表 *)
and parse_signature_items items state =
  let state = skip_newlines state in
  let token, _pos = current_token state in
  if token = EndKeyword then (List.rev items, state)
  else
    let item, state1 = parse_signature_item state in
    let state2 = skip_newlines state1 in
    parse_signature_items (item :: items) state2

(** 解析单个签名项 *)
and parse_signature_item state =
  let token, _pos = current_token state in
  match token with
  | LetKeyword ->
      (* 值签名: 让 名称 : 类型 *)
      let state1 = advance_parser state in
      let name, state2 = parse_identifier_allow_keywords state1 in
      let state3 = expect_token state2 Colon in
      let type_expr, state4 = parse_type_expression state3 in
      (SigValue (name, type_expr), state4)
  | TypeKeyword ->
      (* 类型签名: 类型 名称 [= 定义] *)
      let state1 = advance_parser state in
      let name, state2 = parse_identifier_allow_keywords state1 in
      let token, _ = current_token state2 in
      if token = Assign then
        let state3 = advance_parser state2 in
        let type_def, state4 = parse_type_definition state3 in
        (SigTypeDecl (name, Some type_def), state4)
      else (SigTypeDecl (name, None), state2)
  | ModuleKeyword ->
      (* 模块签名: 模块 名称 : 模块类型 *)
      let state1 = advance_parser state in
      let name, state2 = parse_identifier_allow_keywords state1 in
      let state3 = expect_token state2 Colon in
      let module_type, state4 = parse_module_type state3 in
      (SigModule (name, module_type), state4)
  | ExceptionKeyword ->
      (* 异常签名: 异常 名称 [of 类型] *)
      let state1 = advance_parser state in
      let name, state2 = parse_identifier_allow_keywords state1 in
      let token, _ = current_token state2 in
      if token = OfKeyword then
        let state3 = advance_parser state2 in
        let type_expr, state4 = parse_type_expression state3 in
        (SigException (name, Some type_expr), state4)
      else (SigException (name, None), state2)
  | _ ->
      let token, pos = current_token state in
      raise (SyntaxError ("期望签名项，但遇到 " ^ show_token token, pos))
