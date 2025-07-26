(** Token兼容性关键字映射模块接口 *)

val map_basic_keywords : string -> Yyocamlc_lib.Unified_token_core.unified_token option
val map_wenyan_keywords : string -> Yyocamlc_lib.Unified_token_core.unified_token option
val map_classical_keywords : string -> Yyocamlc_lib.Unified_token_core.unified_token option
val map_natural_language_keywords : string -> Yyocamlc_lib.Unified_token_core.unified_token option
val map_type_keywords : string -> Yyocamlc_lib.Unified_token_core.unified_token option
val map_poetry_keywords : string -> Yyocamlc_lib.Unified_token_core.unified_token option
val map_misc_keywords : string -> Yyocamlc_lib.Unified_token_core.unified_token option
val map_legacy_keyword_to_unified : string -> Yyocamlc_lib.Unified_token_core.unified_token option
