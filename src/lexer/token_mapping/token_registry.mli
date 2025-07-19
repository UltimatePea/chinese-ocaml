(** 中央Token注册器接口 - 统一管理所有Token映射和转换 *)

(* 为了避免循环依赖，我们定义自己的token类型 *)
type local_token =
  (* 字面量 *)
  | IntToken of int
  | FloatToken of float
  | ChineseNumberToken of string
  | StringToken of string
  | BoolToken of bool
  (* 标识符 *)
  | QuotedIdentifierToken of string
  | IdentifierTokenSpecial of string
  (* 基础关键字 *)
  | LetKeyword | RecKeyword | InKeyword | FunKeyword 
  | IfKeyword | ThenKeyword | ElseKeyword | MatchKeyword 
  | WithKeyword | OtherKeyword | AndKeyword | OrKeyword 
  | NotKeyword | TrueKeyword | FalseKeyword
  (* 类型关键字 *)
  | TypeKeyword | PrivateKeyword | IntTypeKeyword | FloatTypeKeyword 
  | StringTypeKeyword | BoolTypeKeyword | UnitTypeKeyword 
  | ListTypeKeyword | ArrayTypeKeyword
  (* 运算符 *)
  | Plus | Minus | Multiply | Divide | Equal | NotEqual 
  | Less | Greater | Arrow
  (* 其他 *)
  | UnknownToken

(** Token映射条目类型 *)
type token_mapping_entry = {
  source_token : string;  (* 源token名称 *)
  target_token : local_token;   (* 目标token类型 *)
  category : string;      (* 分类：literal, identifier, keyword, operator等 *)
  priority : int;         (* 优先级，用于冲突解决 *)
  description : string;   (* 描述信息 *)
}

(** 注册token映射 *)
val register_token_mapping : token_mapping_entry -> unit

(** 查询token映射 *)
val find_token_mapping : string -> token_mapping_entry option

(** 获取按优先级排序的映射 *)
val get_sorted_mappings : unit -> token_mapping_entry list

(** 获取按分类分组的映射 *)
val get_mappings_by_category : string -> token_mapping_entry list

(** 获取注册器统计信息 *)
val get_registry_stats : unit -> string

(** 初始化注册器 - 注册所有基础映射 *)
val initialize_registry : unit -> unit

(** 验证注册器一致性 *)
val validate_registry : unit -> unit

(** 生成token转换函数 *)
val generate_token_converter : unit -> string