(** 骆言编译器错误处理系统 - 错误恢复策略模块
    重构自error_handler.ml，第五阶段系统一致性优化：长函数重构
    
    @author 骆言技术债务清理团队
    @version 1.0 (重构版)
    @since 2025-07-20 Issue #718 长函数重构 *)

open Compiler_errors
open Error_handler_types
open Error_handler_statistics

(** 根据配置确定恢复策略 *)
let determine_recovery_strategy error_type =
  let runtime_cfg = Config.get_runtime_config () in
  if not runtime_cfg.error_recovery then Abort
  else
    match error_type with
    | LexError (_, _) -> SkipAndContinue
    | ParseError (_, _) -> SyncToNextStatement
    | SyntaxError (_, _) -> SyncToNextStatement
    | PoetryParseError (_, _) -> SkipAndContinue
    | TypeError (_, _) -> SkipAndContinue
    | SemanticError (_, _) -> SkipAndContinue
    | CodegenError (_, _) -> TryAlternative "使用默认代码生成"
    | RuntimeError (_, _) -> RequestUserInput
    | ExceptionRaised (_, _) -> RequestUserInput
    | InternalError _ -> Abort
    | UnimplementedFeature (_, _) -> TryAlternative "使用替代实现"
    | IOError (_, _) -> TryAlternative "重试IO操作"

(** 错误恢复执行 *)
let attempt_recovery enhanced_error =
  let runtime_cfg = Config.get_runtime_config () in
  if not runtime_cfg.error_recovery then false
  else
    match enhanced_error.recovery_strategy with
    | SkipAndContinue ->
        global_stats.recovered_errors <- global_stats.recovered_errors + 1;
        true
    | SyncToNextStatement ->
        (* 这里应该实现具体的语法同步逻辑 *)
        global_stats.recovered_errors <- global_stats.recovered_errors + 1;
        true
    | TryAlternative _ ->
        (* 这里应该实现替代方案逻辑 *)
        global_stats.recovered_errors <- global_stats.recovered_errors + 1;
        true
    | RequestUserInput ->
        (* 这里可以实现用户交互逻辑 *)
        false
    | Abort -> false

(** 检查是否应该继续处理错误 *)
let should_continue_processing () =
  let runtime_cfg = Config.get_runtime_config () in
  runtime_cfg.continue_on_error
  && global_stats.total_errors < runtime_cfg.max_error_count
  && global_stats.fatal_errors = 0