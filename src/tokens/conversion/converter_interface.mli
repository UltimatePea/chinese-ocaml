(** 骆言Token系统整合重构 - 转换器接口定义 *)

(** 转换器接口签名 *)
module type CONVERTER = sig
  type input
  type output
  val convert : input -> output
  val is_compatible : input -> bool
  val name : string
  val version : string
end

(** 批量转换器接口 *)
module type BATCH_CONVERTER = sig
  include CONVERTER
  val convert_batch : input list -> output list
  val convert_parallel : input list -> output list
end

(** 可逆转换器接口 *)
module type REVERSIBLE_CONVERTER = sig
  include CONVERTER
  val reverse_convert : output -> input
  val is_reversible : input -> bool
end

(** 带错误处理的转换器接口 *)
module type SAFE_CONVERTER = sig
  type input
  type output
  type error = 
    | IncompatibleInput of string
    | ConversionFailed of string
    | UnsupportedFeature of string
  type 'a result = ('a, error) Result.t
  val safe_convert : input -> output result
  val safe_convert_batch : input list -> (output list, error list) Result.t
  val name : string
  val version : string
end

(** 转换器工厂 *)
module ConverterFactory : sig
  type 'a converter_entry = {
    name : string;
    version : string;
    converter : 'a;
    compatible_types : string list;
  }
  
  type t
  
  val create : unit -> t
  val register : t -> name:string -> version:string -> converter:'a -> compatible_types:string list -> unit
  val find : t -> string -> Obj.t converter_entry option
  val list_all : t -> (string * string) list
end

(** 转换器链 *)
module ConverterChain : sig
  type ('a, 'b) step = {
    name : string;
    convert : 'a -> 'b;
    is_compatible : 'a -> bool;
  }
  
  type 'a chain = 'a -> 'a
  
  val make_step : name:string -> convert:('a -> 'b) -> is_compatible:('a -> bool) -> ('a, 'b) step
  val compose : ('a, 'b) step -> ('b, 'c) step -> 'a -> 'c
  val build_chain : ('a, 'a) step list -> 'a chain
end