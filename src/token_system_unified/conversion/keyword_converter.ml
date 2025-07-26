(** 骆言编译器 - 关键字转换器
    
    专门处理各类关键字Token的转换，
    整合原本分散在token_conversion_keywords.ml等文件中的功能。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Yyocamlc_lib.Error_types
open Token_converter
open Token_system_unified_core.Token_types

type keyword_mapping = {
  chinese_text : string;  (** 中文文本 *)
  english_alias : string option;  (** 英文别名 *)
  token : token;  (** 对应的Token *)
  category : string;  (** 关键字类别 *)
}
(** 关键字映射表类型 *)

(** 核心语言关键字映射 *)
let core_language_keywords =
  [
    {
      chinese_text = "让";
      english_alias = Some "let";
      token = KeywordToken Keywords.LetKeyword;
      category = "基础语言";
    };
    {
      chinese_text = "递归";
      english_alias = Some "rec";
      token = KeywordToken Keywords.RecKeyword;
      category = "基础语言";
    };
    {
      chinese_text = "在";
      english_alias = Some "in";
      token = KeywordToken Keywords. InKeyword;
      category = "基础语言";
    };
    {
      chinese_text = "函数";
      english_alias = Some "fun";
      token = KeywordToken Keywords. FunKeyword;
      category = "基础语言";
    };
    {
      chinese_text = "参数";
      english_alias = Some "param";
      token = KeywordToken Keywords. ParamKeyword;
      category = "基础语言";
    };
    {
      chinese_text = "如果";
      english_alias = Some "if";
      token = KeywordToken Keywords. IfKeyword;
      category = "控制流";
    };
    {
      chinese_text = "那么";
      english_alias = Some "then";
      token = KeywordToken Keywords. ThenKeyword;
      category = "控制流";
    };
    {
      chinese_text = "否则";
      english_alias = Some "else";
      token = KeywordToken Keywords. ElseKeyword;
      category = "控制流";
    };
    {
      chinese_text = "匹配";
      english_alias = Some "match";
      token = KeywordToken Keywords. MatchKeyword;
      category = "控制流";
    };
    {
      chinese_text = "与";
      english_alias = Some "with";
      token = KeywordToken Keywords. WithKeyword;
      category = "控制流";
    };
    {
      chinese_text = "其他";
      english_alias = Some "other";
      token = KeywordToken Keywords. OtherKeyword;
      category = "控制流";
    };
    {
      chinese_text = "类型";
      english_alias = Some "type";
      token = KeywordToken Keywords. TypeKeyword;
      category = "类型系统";
    };
    {
      chinese_text = "私有";
      english_alias = Some "private";
      token = KeywordToken Keywords. PrivateKeyword;
      category = "类型系统";
    };
    {
      chinese_text = "之";
      english_alias = Some "of";
      token = KeywordToken Keywords. OfKeyword;
      category = "类型系统";
    };
    {
      chinese_text = "真";
      english_alias = Some "true";
      token = KeywordToken Keywords. TrueKeyword;
      category = "逻辑";
    };
    {
      chinese_text = "假";
      english_alias = Some "false";
      token = KeywordToken Keywords. FalseKeyword;
      category = "逻辑";
    };
    {
      chinese_text = "并且";
      english_alias = Some "and";
      token = KeywordToken Keywords. AndKeyword;
      category = "逻辑";
    };
    {
      chinese_text = "或者";
      english_alias = Some "or";
      token = KeywordToken Keywords. OrKeyword;
      category = "逻辑";
    };
    {
      chinese_text = "非";
      english_alias = Some "not";
      token = KeywordToken Keywords. NotKeyword;
      category = "逻辑";
    };
  ]

(** 语义关键字映射 *)
let semantic_keywords =
  [
    { chinese_text = "作为"; english_alias = Some "as"; token = KeywordToken Keywords.AsKeyword; category = "语义" };
    {
      chinese_text = "组合";
      english_alias = Some "combine";
      token = KeywordToken Keywords.CombineKeyword;
      category = "语义";
    };
    {
      chinese_text = "以及";
      english_alias = Some "with_op";
      token = KeywordToken Keywords.WithOpKeyword;
      category = "语义";
    };
    {
      chinese_text = "当";
      english_alias = Some "when";
      token = KeywordToken Keywords.WhenKeyword;
      category = "语义";
    };
  ]

(** 错误处理关键字映射 *)
let error_handling_keywords =
  [
    {
      chinese_text = "否则返回";
      english_alias = Some "or_else";
      token = KeywordToken Keywords.OrElseKeyword;
      category = "错误处理";
    };
    {
      chinese_text = "默认为";
      english_alias = Some "with_default";
      token = KeywordToken Keywords.WithDefaultKeyword;
      category = "错误处理";
    };
    {
      chinese_text = "异常";
      english_alias = Some "exception";
      token = KeywordToken Keywords.ExceptionKeyword;
      category = "错误处理";
    };
    {
      chinese_text = "抛出";
      english_alias = Some "raise";
      token = KeywordToken (Keywords.RaiseKeyword);
      category = "错误处理";
    };
    {
      chinese_text = "尝试";
      english_alias = Some "try";
      token = KeywordToken (Keywords.TryKeyword);
      category = "错误处理";
    };
    {
      chinese_text = "捕获";
      english_alias = Some "catch";
      token = KeywordToken (Keywords.CatchKeyword);
      category = "错误处理";
    };
    {
      chinese_text = "最终";
      english_alias = Some "finally";
      token = KeywordToken (Keywords.FinallyKeyword);
      category = "错误处理";
    };
  ]

(** 模块系统关键字映射 *)
let module_system_keywords =
  [
    {
      chinese_text = "模块";
      english_alias = Some "module";
      token = KeywordToken (Keywords.ModuleKeyword);
      category = "模块系统";
    };
    {
      chinese_text = "模块类型";
      english_alias = Some "module_type";
      token = KeywordToken (Keywords.ModuleTypeKeyword);
      category = "模块系统";
    };
    {
      chinese_text = "签名";
      english_alias = Some "sig";
      token = KeywordToken (Keywords.SigKeyword);
      category = "模块系统";
    };
    {
      chinese_text = "结束";
      english_alias = Some "end";
      token = KeywordToken (Keywords.EndKeyword);
      category = "模块系统";
    };
    {
      chinese_text = "函子";
      english_alias = Some "functor";
      token = KeywordToken (Keywords.FunctorKeyword);
      category = "模块系统";
    };
    {
      chinese_text = "包含";
      english_alias = Some "include";
      token = KeywordToken (Keywords.IncludeKeyword);
      category = "模块系统";
    };
    {
      chinese_text = "引用";
      english_alias = Some "ref";
      token = KeywordToken (Keywords.RecKeyword);
      category = "模块系统";
    };
  ]

(** 宏系统关键字映射 *)
let macro_system_keywords =
  [
    {
      chinese_text = "宏";
      english_alias = Some "macro";
      token = KeywordToken Keywords.MacroKeyword;
      category = "宏系统";
    };
    {
      chinese_text = "展开";
      english_alias = Some "expand";
      token = KeywordToken Keywords.ExpandKeyword;
      category = "宏系统";
    };
  ]

(** 文言文关键字映射 - 简化版本 *)
let wenyan_keywords =
  [
    { chinese_text = "吾有"; english_alias = None; token = KeywordToken Keywords.WenyanHave; category = "文言文" };
    { chinese_text = "今"; english_alias = None; token = KeywordToken Keywords.WenyanNow; category = "文言文" };
    { chinese_text = "是"; english_alias = None; token = KeywordToken Keywords.WenyanIs; category = "文言文" };
    { chinese_text = "非"; english_alias = None; token = KeywordToken Keywords.WenyanNot; category = "文言文" };
    { chinese_text = "凡"; english_alias = None; token = KeywordToken Keywords.WenyanAll; category = "文言文" };
    { chinese_text = "或"; english_alias = None; token = KeywordToken Keywords.WenyanSome; category = "文言文" };
    { chinese_text = "为"; english_alias = None; token = KeywordToken Keywords.WenyanFor; category = "文言文" };
    { chinese_text = "若"; english_alias = None; token = KeywordToken Keywords.WenyanIf; category = "文言文" };
    { chinese_text = "则"; english_alias = None; token = KeywordToken Keywords.WenyanThen; category = "文言文" };
    { chinese_text = "不然"; english_alias = None; token = KeywordToken Keywords.WenyanElse; category = "文言文" };
  ]

(** 古典体关键字映射 - 简化版本 *)
let ancient_keywords =
  [
    { chinese_text = "令"; english_alias = None; token = KeywordToken Keywords.ClassicalLet; category = "古典体" };
    { chinese_text = "在"; english_alias = None; token = KeywordToken Keywords.ClassicalIn; category = "古典体" };
    { chinese_text = "为"; english_alias = None; token = KeywordToken Keywords.ClassicalBe; category = "古典体" };
    { chinese_text = "行"; english_alias = None; token = KeywordToken Keywords.ClassicalDo; category = "古典体" };
    { chinese_text = "终"; english_alias = None; token = KeywordToken Keywords.ClassicalEnd; category = "古典体" };
  ]

(** 主要关键字转换函数 *)
let convert_keyword chinese_text =
  let all_keywords = 
    core_language_keywords @ 
    semantic_keywords @
    error_handling_keywords @
    module_system_keywords @
    macro_system_keywords @ 
    wenyan_keywords @ 
    ancient_keywords
  in
  let rec find_keyword = function
    | [] -> None
    | {chinese_text = text; token; _} :: rest ->
        if text = chinese_text then Some token
        else find_keyword rest
  in
  find_keyword all_keywords

(** 获取所有关键字映射 *)
let get_all_keyword_mappings () =
  core_language_keywords @ 
  semantic_keywords @
  error_handling_keywords @
  module_system_keywords @
  macro_system_keywords @ 
  wenyan_keywords @ 
  ancient_keywords

(** 按类别获取关键字 *)
let get_keywords_by_category category =
  let all_keywords = get_all_keyword_mappings () in
  List.filter_map (fun {category = cat; token; _} -> 
    if cat = category then Some token else None
  ) all_keywords

(** 关键字转换器模块 *)
let keyword_converter = 
  let module KeywordConverter = struct
    let name = "关键字转换器"
    let converter_type = Token_converter.KeywordConverter
    
    let string_to_token _config text =
      match convert_keyword text with
      | Some token -> Ok token
      | None -> Error ("未知关键字: " ^ text)
    
    let token_to_string token = show_token token
    let supports_bidirectional = true
    let get_conversion_stats () = (0, 0, 0.0)
  end in
  (module KeywordConverter : CONVERTER)
