(** Token兼容性运算符映射模块 - Issue #646 技术债务清理

    此模块负责处理各种运算符的映射转换，包括算术、比较、逻辑、赋值等运算符。 这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。

    @author 骆言技术债务清理团队 Issue #646
    @version 1.0
    @since 2025-07-20 *)

open Unified_token_core

(** 运算符映射 *)
let map_legacy_operator_to_unified = function
  (* 算术运算符 *)
  | "PlusOp" -> Some PlusOp
  | "MinusOp" -> Some MinusOp
  | "MultOp" -> Some MultiplyOp
  | "DivOp" -> Some DivideOp
  | "ModOp" -> Some ModOp
  | "PowerOp" -> Some PowerOp
  (* 比较运算符 *)
  | "EqualOp" -> Some EqualOp
  | "NotEqualOp" -> Some NotEqualOp
  | "LessOp" -> Some LessOp
  | "GreaterOp" -> Some GreaterOp
  | "LessEqualOp" -> Some LessEqualOp
  | "GreaterEqualOp" -> Some GreaterEqualOp
  (* 逻辑运算符 *)
  | "AndOp" -> Some LogicalAndOp
  | "OrOp" -> Some LogicalOrOp
  | "NotOp" -> Some LogicalNotOp
  (* 赋值运算符 *)
  | "AssignOp" -> Some AssignOp
  | "RefAssignOp" -> Some AssignOp (* 暂时映射到普通赋值 *)
  (* 其他运算符 *)
  | "ConsOp" -> Some ConsOp (* :: *)
  | "ArrowOp" -> Some ArrowOp (* -> *)
  | "PipeRightOp" -> Some PipeOp (* |> *)
  | "PipeLeftOp" -> Some PipeBackOp (* <| *)
  (* 不支持的运算符 *)
  | _ -> None
