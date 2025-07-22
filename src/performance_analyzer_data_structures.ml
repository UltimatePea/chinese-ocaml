(** 数据结构性能分析器模块

    专门分析数据结构使用效率 重构版本：使用公共基础模块消除代码重复 创建时间：技术债务清理 Fix #794 *)

open Ast
open Performance_analyzer_base
open Utils.Base_formatter

(** 数据结构特定的性能分析逻辑 *)
let data_structures_specific_analysis expr =
  match expr with
  | ListExpr exprs when List.length exprs > 1000 ->
      [
        make_performance_suggestion ~hint_type:"大型列表优化"
          ~message:(performance_creation_pattern (List.length exprs) "列表")
          ~confidence:0.70 ~location:"列表创建" ~fix:"考虑使用数组或其他更高效的数据结构";
      ]
  | RecordExpr fields when List.length fields > 50 ->
      [
        make_performance_suggestion ~hint_type:"大型记录优化"
          ~message:(performance_field_pattern (List.length fields) "记录")
          ~confidence:0.65 ~location:"记录创建" ~fix:"考虑拆分为多个小记录或使用其他数据结构";
      ]
  | FunCallExpr (VarExpr "查找", [ ListExpr _; _ ]) ->
      [
        make_performance_suggestion ~hint_type:"线性查找优化" ~message:"在列表中进行线性查找，对于大型数据集效率较低"
          ~confidence:0.60 ~location:"列表查找" ~fix:"考虑使用映射表、集合或其他支持快速查找的数据结构";
      ]
  | _ -> []

(** 分析数据结构使用效率 *)
let analyze_data_structure_efficiency expr =
  create_performance_analyzer data_structures_specific_analysis expr
