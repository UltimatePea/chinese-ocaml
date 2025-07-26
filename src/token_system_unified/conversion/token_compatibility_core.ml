(** Token兼容性核心转换模块 - Issue #646 技术债务清理

    此模块提供核心的Token转换逻辑，协调各种映射模块并提供统一转换接口。 这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。

    @author 骆言技术债务清理团队 Issue #646
    @version 1.0
    @since 2025-07-20 *)

(** 核心转换函数 *)
let convert_legacy_token_string token_str _value_opt =
  (* 尝试关键字映射 *)
  match Token_compatibility_keywords.map_legacy_keyword_to_unified token_str with
  | Some token -> Some token
  | None -> (
      (* 尝试运算符映射 *)
      match Token_compatibility_operators.map_legacy_operator_to_unified token_str with
      | Some token -> Some token
      | None -> (
          (* 尝试分隔符映射 *)
          match Token_compatibility_delimiters.map_legacy_delimiter_to_unified token_str with
          | Some token -> Some token
          | None -> (
              (* 尝试字面量映射 *)
              match Token_compatibility_literals.map_legacy_literal_to_unified token_str with
              | Some token -> Some token
              | None -> (
                  (* 尝试标识符映射 *)
                  match Token_compatibility_literals.map_legacy_identifier_to_unified token_str with
                  | Some token -> Some token
                  | None ->
                      (* 尝试特殊Token映射 *)
                      Token_compatibility_literals.map_legacy_special_to_unified token_str))))

(** 创建兼容的带位置Token *)
let make_compatible_positioned_token token_str value_opt filename line column =
  match convert_legacy_token_string token_str value_opt with
  | Some token ->
      let position =
        { Unified_token_core.filename; line; column; offset = 0 (* 暂时设为0，因为接口没有提供offset参数 *) }
      in
      Some { Unified_token_core.token; position; metadata = None (* 暂时不使用metadata *) }
  | None -> None

(** 检查Token字符串是否与统一系统兼容 *)
let is_compatible_with_legacy token_str = convert_legacy_token_string token_str None <> None
