(** 骆言Token系统整合重构 - 转换器接口定义 定义统一的Token转换器接口，支持各种Token转换需求 *)

(** 转换器接口签名 *)
module type CONVERTER = sig
  type input
  (** 输入类型 *)

  type output
  (** 输出类型 *)

  val convert : input -> output
  (** 转换函数 *)

  val is_compatible : input -> bool
  (** 兼容性检查 *)

  val name : string
  (** 转换器名称 *)

  val version : string
  (** 转换器版本 *)
end

(** 批量转换器接口 *)
module type BATCH_CONVERTER = sig
  include CONVERTER

  val convert_batch : input list -> output list
  (** 批量转换 *)

  val convert_parallel : input list -> output list
  (** 并行转换 *)
end

(** 可逆转换器接口 *)
module type REVERSIBLE_CONVERTER = sig
  include CONVERTER

  val reverse_convert : output -> input
  (** 反向转换 *)

  val is_reversible : input -> bool
  (** 检查转换是否可逆 *)
end

(** 带错误处理的转换器接口 *)
module type SAFE_CONVERTER = sig
  type input
  (** 输入类型 *)

  type output
  (** 输出类型 *)

  (** 转换错误类型 *)
  type error =
    | IncompatibleInput of string
    | ConversionFailed of string
    | UnsupportedFeature of string

  type 'a result = ('a, error) Result.t
  (** 转换结果类型 *)

  val safe_convert : input -> output result
  (** 安全转换函数 *)

  val safe_convert_batch : input list -> (output list, error list) Result.t
  (** 批量安全转换 *)

  val name : string
  (** 转换器信息 *)

  val version : string
end

(** 转换器工厂 *)
module ConverterFactory = struct
  type 'a converter_entry = {
    name : string;
    version : string;
    converter : 'a;
    compatible_types : string list;
  }
  (** 转换器注册表 *)

  type t = { converters : (string, Obj.t converter_entry) Hashtbl.t }
  (** 注册表类型 *)

  (** 创建转换器工厂 *)
  let create () = { converters = Hashtbl.create 32 }

  (** 注册转换器 *)
  let register factory ~name ~version ~converter ~compatible_types =
    let entry = { name; version; converter = Obj.repr converter; compatible_types } in
    Hashtbl.replace factory.converters name entry

  (** 查找转换器 *)
  let find factory name = Hashtbl.find_opt factory.converters name

  (** 列出所有转换器 *)
  let list_all factory =
    Hashtbl.fold (fun name entry acc -> (name, entry.version) :: acc) factory.converters []
end

(** 转换器链 *)
module ConverterChain = struct
  type ('a, 'b) step = { name : string; convert : 'a -> 'b; is_compatible : 'a -> bool }
  (** 转换步骤 *)

  type 'a chain = 'a -> 'a
  (** 转换链 *)

  (** 创建转换步骤 *)
  let make_step ~name ~convert ~is_compatible = { name; convert; is_compatible }

  (** 组合两个转换步骤 *)
  let compose step1 step2 input =
    if step1.is_compatible input then
      let intermediate = step1.convert input in
      if step2.is_compatible intermediate then step2.convert intermediate
      else failwith ("Step " ^ step2.name ^ " is not compatible")
    else failwith ("Step " ^ step1.name ^ " is not compatible")

  (** 构建转换链 *)
  let build_chain steps =
    List.fold_left (fun chain step -> fun input -> chain (step.convert input)) (fun x -> x) steps
end
