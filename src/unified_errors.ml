(** 骆言统一错误处理系统 - Chinese Programming Language Unified Error Handling System *)

open Compiler_errors

(** 统一错误码定义 *)
type error_code = 
  | SyntaxError of string * position
  | RuntimeError of string * position option
  | TypeError of string * position option
  | LexError of string * position
  | SemanticError of string * position option
  | CompilerInternalError of string

(** 错误结果类型 *)
type 'a result = ('a, error_code) Result.t

(** 将异常转换为Result类型 *)
let to_result f =
  try 
    Result.Ok (f ())
  with
  | Parser_utils.SyntaxError (msg, pos) -> Result.Error (SyntaxError (msg, pos))
  | Value_operations.RuntimeError msg -> Result.Error (RuntimeError (msg, None))
  | Types_errors.TypeError msg -> Result.Error (TypeError (msg, None))
  | Lexer_tokens.LexError (msg, pos) -> Result.Error (LexError (msg, pos))
  | Semantic_errors.SemanticError msg -> Result.Error (SemanticError (msg, None))
  | Compiler_errors.CompilerError error_info -> 
      (match error_info.error with
      | Compiler_errors.SyntaxError (msg, pos) -> Result.Error (SyntaxError (msg, pos))
      | Compiler_errors.RuntimeError (msg, pos_opt) -> Result.Error (RuntimeError (msg, pos_opt))
      | Compiler_errors.TypeError (msg, pos_opt) -> Result.Error (TypeError (msg, pos_opt))
      | Compiler_errors.LexError (msg, pos) -> Result.Error (LexError (msg, pos))
      | Compiler_errors.SemanticError (msg, pos_opt) -> Result.Error (SemanticError (msg, pos_opt))
      | _ -> Result.Error (CompilerInternalError ("未知编译器错误: " ^ Compiler_errors.format_error_message error_info.error)))
  | exn -> Result.Error (CompilerInternalError ("内部错误: " ^ Printexc.to_string exn))

(** 创建运行时错误 *)
let make_runtime_error msg pos_opt =
  Result.Error (RuntimeError (msg, pos_opt))

(** 创建语法错误 *)
let make_syntax_error msg pos =
  Result.Error (SyntaxError (msg, pos))

(** 创建类型错误 *)
let make_type_error msg pos_opt =
  Result.Error (TypeError (msg, pos_opt))

(** 创建词法错误 *)
let make_lex_error msg pos =
  Result.Error (LexError (msg, pos))

(** 创建语义错误 *)
let make_semantic_error msg pos_opt =
  Result.Error (SemanticError (msg, pos_opt))

(** 从错误码中获取消息 *)
let error_message = function
  | SyntaxError (msg, _) -> "语法错误: " ^ msg
  | RuntimeError (msg, _) -> "运行时错误: " ^ msg
  | TypeError (msg, _) -> "类型错误: " ^ msg
  | LexError (msg, _) -> "词法错误: " ^ msg
  | SemanticError (msg, _) -> "语义错误: " ^ msg
  | CompilerInternalError msg -> "编译器内部错误: " ^ msg

(** 从错误码中获取位置 *)
let error_position = function
  | SyntaxError (_, pos) -> Some pos
  | RuntimeError (_, pos_opt) -> pos_opt
  | TypeError (_, pos_opt) -> pos_opt
  | LexError (_, pos) -> Some pos
  | SemanticError (_, pos_opt) -> pos_opt
  | CompilerInternalError _ -> None

(** 将错误码转换为标准异常 *)
let error_to_exception = function
  | SyntaxError (msg, pos) -> Parser_utils.SyntaxError (msg, pos)
  | RuntimeError (msg, _) -> Value_operations.RuntimeError msg
  | TypeError (msg, _) -> Types_errors.TypeError msg
  | LexError (msg, pos) -> Lexer_tokens.LexError (msg, pos)
  | SemanticError (msg, _) -> Semantic_errors.SemanticError msg
  | CompilerInternalError msg -> Failure msg

(** Result 单子操作 *)
module ResultOps = struct
  let bind result f =
    match result with
    | Result.Ok value -> f value
    | Result.Error error -> Result.Error error

  let map f result =
    match result with
    | Result.Ok value -> Result.Ok (f value)
    | Result.Error error -> Result.Error error

  let (>>=) = bind
  let (>|=) result f = map f result

  (** 将多个结果合并，如果有任何错误则返回第一个错误 *)
  let all results =
    let rec loop acc = function
      | [] -> Result.Ok (List.rev acc)
      | Result.Ok value :: rest -> loop (value :: acc) rest
      | Result.Error error :: _ -> Result.Error error
    in
    loop [] results

  (** 尝试第一个操作，失败时尝试第二个 *)
  let or_else first_result second_thunk =
    match first_result with
    | Result.Ok _ as ok -> ok
    | Result.Error _ -> second_thunk ()
end

(** 简化的位置创建函数 *)
let create_position filename line column : position =
  { filename; line; column }

(** 评估位置创建函数 *)
let create_eval_position line_hint : position =
  create_position "<expression_evaluator>" line_hint 0