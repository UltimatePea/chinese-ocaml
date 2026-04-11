(** ===== Token类型 ===== *)

type token =
  | TImport   of string
  | TComment  of string
  | TKeyword  of string * string
  | TIdent    of string * string
  | TModIdent of string * string
  | TString   of string
  | TRaw      of string
  | TNum      of string
  | TOp       of string

val pp_token    : token -> string
val print_tokens: token list -> string

val tokenize : ?basedir:string -> string -> token list

(** ===== 标识符转换 ===== *)

val mangle : string -> string
val mangle_module : string -> string

val transpile : ?basedir:string -> ?annotate:bool -> string -> string
