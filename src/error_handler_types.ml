(** 骆言编译器错误处理系统 - 类型定义模块
    重构自error_handler.ml，第五阶段系统一致性优化：长函数重构
    
    @author 骆言技术债务清理团队
    @version 1.0 (重构版)
    @since 2025-07-20 Issue #718 长函数重构 *)

open Compiler_errors

(** 错误恢复策略类型 *)
type recovery_strategy =
  | SkipAndContinue  (** 跳过错误，继续处理 *)
  | SyncToNextStatement  (** 同步到下一语句边界 *)
  | TryAlternative of string  (** 尝试替代方案 *)
  | RequestUserInput  (** 请求用户输入 *)
  | Abort  (** 终止处理 *)

type error_context = {
  source_file : string;  (** 源文件名 *)
  function_name : string;  (** 出错的函数名 *)
  module_name : string;  (** 出错的模块名 *)
  timestamp : float;  (** 错误发生时间 *)
  call_stack : string list;  (** 调用栈 *)
  user_data : (string * string) list;  (** 用户自定义数据 *)
}
(** 错误上下文信息 *)

type enhanced_error_info = {
  base_error : error_info;  (** 基础错误信息 *)
  context : error_context;  (** 错误上下文 *)
  recovery_strategy : recovery_strategy;  (** 恢复策略 *)
  attempt_count : int;  (** 重试次数 *)
  related_errors : enhanced_error_info list;  (** 相关错误 *)
}
(** 增强的错误信息 *)

type error_statistics = {
  mutable total_errors : int;
  mutable warnings : int;
  mutable errors : int;
  mutable fatal_errors : int;
  mutable recovered_errors : int;
  mutable start_time : float;
}
(** 错误统计信息 *)

(** 创建错误上下文 *)
let create_context ?(source_file = "<unknown>") ?(function_name = "<unknown>")
    ?(module_name = "<unknown>") ?(call_stack = []) ?(user_data = []) () =
  { source_file; function_name; module_name; timestamp = Unix.time (); call_stack; user_data }

(** 创建增强错误信息 *)
let create_enhanced_error ?(recovery_strategy = SkipAndContinue) ?(attempt_count = 0)
    ?(related_errors = []) base_error context =
  { base_error; context; recovery_strategy; attempt_count; related_errors }

(** 错误模式匹配助手 *)
let is_recoverable enhanced_error =
  match enhanced_error.recovery_strategy with Abort -> false | _ -> true

let is_fatal enhanced_error = enhanced_error.base_error.severity = Fatal