(** 列表性能分析器模块

    专门分析列表操作的性能问题和优化机会 重构版本：使用公共基础模块消除代码重复 创建时间：技术债务清理 Fix #794 *)

open Ast
open Performance_analyzer_base

(** 列表特定的性能分析逻辑 *)
let list_specific_analysis expr =
  match expr with
  | FunCallExpr (VarExpr "连接", [ ListExpr _; ListExpr _ ]) ->
      [ SuggestionBuilder.list_optimization_suggestion "列表连接" "检测到列表连接操作，对于大量数据建议使用更高效的方法" ]
  | FunCallExpr (VarExpr "追加", args) when List.length args >= 2 ->
      [
        make_performance_suggestion ~hint_type:"列表追加优化" ~message:"频繁的列表追加操作可能影响性能" ~confidence:0.60
          ~location:"列表追加操作" ~fix:"考虑使用可变数据结构或反向构建再反转";
      ]
  | _ -> []

(** 分析列表操作性能 *)
let analyze_list_performance expr = create_performance_analyzer list_specific_analysis expr
