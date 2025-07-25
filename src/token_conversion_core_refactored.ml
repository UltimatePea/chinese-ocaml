(** Token转换核心模块 - 重构版本
 
    此模块是token_conversion_core.ml的重构版本，采用了更高效的架构：
    - 使用Option类型而非异常处理
    - 模块化设计提升可维护性
    - 统一的模式匹配避免性能开销
    
    技术改进：
    - 消除7层嵌套try-catch链
    - 降低复杂度从303到预期<100
    - 提升可维护性指数从29.18到预期>70
    
    @author 骆言技术债务清理团队 Issue #1256
    @version 2.0
    @since 2025-07-25 *)

(** 模块导入 *)
module Identifiers = Token_conversion_identifiers
module Literals = Token_conversion_literals  
module Keywords = Token_conversion_keywords
module Types = Token_conversion_types
module Classical = Token_conversion_classical

(** 统一的token转换入口 - 使用Option类型优化性能 *)
let convert_token token =
  (* 按频率顺序尝试转换，避免不必要的计算 *)
  match Identifiers.convert_identifier_token_safe token with
  | Some result -> Some result
  | None ->
      match Literals.convert_literal_token_safe token with
      | Some result -> Some result
      | None ->
          match Keywords.convert_basic_keyword_token_safe token with
          | Some result -> Some result
          | None ->
              match Types.convert_type_keyword_token_safe token with
              | Some result -> Some result
              | None ->
                  Classical.convert_classical_token_safe token

(** 批量转换Token列表 - 使用Option类型避免异常 *)
let convert_token_list tokens =
  List.filter_map convert_token tokens

(** 安全的批量转换Token列表 - 返回转换结果和失败token列表 *)
let convert_token_list_safe tokens =
  List.fold_left (fun (converted, failed) token ->
    match convert_token token with
    | Some result -> (result :: converted, failed)
    | None -> (converted, token :: failed)
  ) ([], []) tokens
  |> fun (converted, failed) -> (List.rev converted, List.rev failed)

(** 检查token类型 *)
let get_token_type token =
  if Identifiers.is_identifier_token token then "identifier"
  else if Literals.is_literal_token token then "literal"
  else if Keywords.is_basic_keyword_token token then "keyword"
  else if Types.is_type_keyword_token token then "type"
  else if Classical.is_classical_token token then "classical"
  else "unknown"

(** 转换统计信息 *)
module Statistics = struct
  let get_conversion_stats () =
    let identifiers_count = 2 in
    let literals_count = 5 in  
    let basic_keywords_count = 122 in
    let type_keywords_count = 13 in
    let classical_count = 95 in
    Printf.sprintf {|
统计信息:
- 标识符类型: %d
- 字面量类型: %d  
- 基础关键字类型: %d
- 类型关键字类型: %d
- 古典语言类型: %d
- 总计: %d
|} identifiers_count literals_count basic_keywords_count type_keywords_count classical_count 
      (identifiers_count + literals_count + basic_keywords_count + type_keywords_count + classical_count)
end

(** 向后兼容性模块 - 保持原有接口 *)
module BackwardCompatibility = struct
  (* 重新导出子模块的接口以保持兼容性 *)
  
  module Identifiers = struct
    let convert_identifier_token = Identifiers.convert_identifier_token
  end
  
  module Literals = struct
    let convert_literal_token = Literals.convert_literal_token
  end
  
  module BasicKeywords = struct
    let convert_basic_keyword_token = Keywords.convert_basic_keyword_token
  end
  
  module TypeKeywords = struct
    let convert_type_keyword_token = Types.convert_type_keyword_token
  end
  
  module Classical = struct
    let convert_wenyan_token = Classical.Wenyan.convert_wenyan_token
    let convert_natural_language_token = Classical.Natural.convert_natural_language_token
    let convert_ancient_token = Classical.Ancient.convert_ancient_token
    let convert_classical_token = Classical.convert_classical_token
  end
  
  (* 原有的主转换函数 *)
  let convert_token = convert_token
  let convert_token_list = convert_token_list
  
  (** 向后兼容的转换函数 - 对于无法转换的token返回异常 *)
  let convert_token_list_with_exceptions tokens =
    List.map (fun token ->
      match convert_token token with
      | Some converted -> converted
      | None -> failwith ("无法转换token类型: " ^ (get_token_type token))
    ) tokens
end

(** 性能优化的快速路径转换 *)
module FastPath = struct
  (** 对于已知类型的token，直接调用对应转换器 *)
  let convert_identifier_fast = Identifiers.convert_identifier_token
  let convert_literal_fast = Literals.convert_literal_token
  let convert_keyword_fast = Keywords.convert_basic_keyword_token
  let convert_type_fast = Types.convert_type_keyword_token
  let convert_classical_fast = Classical.convert_classical_token
end