(** Token调度核心模块
 *
 *  从token_conversion_core.ml重构而来，提供向后兼容性和统一的调度接口
 *  
 *  @author 骆言技术债务清理团队 Issue #1276
 *  @version 2.0
 *  @since 2025-07-25 *)

(** 向后兼容性保证 - 重新导出原有接口 *)

(** 标识符转换模块向后兼容接口 *)
module Identifiers = struct
  let convert_identifier_token = Identifier_converter.convert_identifier_token
end

(** 字面量转换模块向后兼容接口 *)
module Literals = struct
  let convert_literal_token = Literal_converter.convert_literal_token  
end

(** 基础关键字转换模块向后兼容接口 *)
module BasicKeywords = struct
  let convert_basic_keyword_token = Keyword_converter.convert_basic_keyword_token
end

(** 类型关键字转换模块向后兼容接口 *)
module TypeKeywords = struct
  let convert_type_keyword_token = Keyword_converter.convert_type_keyword_token
end

(** 古典语言转换模块向后兼容接口 *)
module Classical = struct
  let convert_wenyan_token = Classical_converter.convert_wenyan_token
  let convert_natural_language_token = Classical_converter.convert_natural_language_token
  let convert_ancient_token = Classical_converter.convert_ancient_token
  let convert_classical_token = Classical_converter.convert_classical_token
end

(** 主要转换接口 - 通过注册器提供 *)
let convert_token = Conversion_registry.convert_token
let convert_token_list = Conversion_registry.convert_token_list
let get_conversion_stats = Conversion_registry.get_conversion_stats

(** 向后兼容的异常导出 *)
exception Unknown_identifier_token = Identifier_converter.Unknown_identifier_token
exception Unknown_literal_token = Literal_converter.Unknown_literal_token  
exception Unknown_basic_keyword_token = Keyword_converter.Unknown_basic_keyword_token
exception Unknown_type_keyword_token = Keyword_converter.Unknown_type_keyword_token
exception Unknown_classical_token = Classical_converter.Unknown_classical_token