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
      token = ErrorHandling RaiseKeyword;
      category = "错误处理";
    };
    {
      chinese_text = "尝试";
      english_alias = Some "try";
      token = ErrorHandling TryKeyword;
      category = "错误处理";
    };
    {
      chinese_text = "捕获";
      english_alias = Some "catch";
      token = ErrorHandling CatchKeyword;
      category = "错误处理";
    };
    {
      chinese_text = "最终";
      english_alias = Some "finally";
      token = ErrorHandling FinallyKeyword;
      category = "错误处理";
    };
  ]

(** 模块系统关键字映射 *)
let module_system_keywords =
  [
    {
      chinese_text = "模块";
      english_alias = Some "module";
      token = ModuleSystem ModuleKeyword;
      category = "模块系统";
    };
    {
      chinese_text = "模块类型";
      english_alias = Some "module_type";
      token = ModuleSystem ModuleTypeKeyword;
      category = "模块系统";
    };
    {
      chinese_text = "签名";
      english_alias = Some "sig";
      token = ModuleSystem SigKeyword;
      category = "模块系统";
    };
    {
      chinese_text = "结束";
      english_alias = Some "end";
      token = ModuleSystem EndKeyword;
      category = "模块系统";
    };
    {
      chinese_text = "函子";
      english_alias = Some "functor";
      token = ModuleSystem FunctorKeyword;
      category = "模块系统";
    };
    {
      chinese_text = "包含";
      english_alias = Some "include";
      token = ModuleSystem IncludeKeyword;
      category = "模块系统";
    };
    {
      chinese_text = "引用";
      english_alias = Some "ref";
      token = ModuleSystem RefKeyword;
      category = "模块系统";
    };
  ]

(** 宏系统关键字映射 *)
let macro_system_keywords =
  [
    {
      chinese_text = "宏";
      english_alias = Some "macro";
      token = MacroSystem MacroKeyword;
      category = "宏系统";
    };
    {
      chinese_text = "展开";
      english_alias = Some "expand";
      token = MacroSystem ExpandKeyword;
      category = "宏系统";
    };
  ]

(** 文言文关键字映射 *)
let wenyan_keywords =
  [
    { chinese_text = "吾有"; english_alias = None; token = Wenyan HaveKeyword; category = "文言文" };
    { chinese_text = "一"; english_alias = None; token = Wenyan OneKeyword; category = "文言文" };
    { chinese_text = "名曰"; english_alias = None; token = Wenyan NameKeyword; category = "文言文" };
    { chinese_text = "设"; english_alias = None; token = Wenyan SetKeyword; category = "文言文" };
    { chinese_text = "也"; english_alias = None; token = Wenyan AlsoKeyword; category = "文言文" };
    { chinese_text = "乃"; english_alias = None; token = Wenyan ThenGetKeyword; category = "文言文" };
    { chinese_text = "曰"; english_alias = None; token = Wenyan CallKeyword; category = "文言文" };
    { chinese_text = "其值"; english_alias = None; token = Wenyan ValueKeyword; category = "文言文" };
    { chinese_text = "为"; english_alias = None; token = Wenyan AsForKeyword; category = "文言文" };
    { chinese_text = "数"; english_alias = None; token = Wenyan NumberKeyword; category = "文言文" };
    {
      chinese_text = "欲行";
      english_alias = None;
      token = Wenyan WantExecuteKeyword;
      category = "文言文";
    };
    {
      chinese_text = "必先得";
      english_alias = None;
      token = Wenyan MustFirstGetKeyword;
      category = "文言文";
    };
    { chinese_text = "為是"; english_alias = None; token = Wenyan ForThisKeyword; category = "文言文" };
    { chinese_text = "遍"; english_alias = None; token = Wenyan TimesKeyword; category = "文言文" };
    { chinese_text = "云云"; english_alias = None; token = Wenyan EndCloudKeyword; category = "文言文" };
    { chinese_text = "若"; english_alias = None; token = Wenyan IfWenyanKeyword; category = "文言文" };
    { chinese_text = "者"; english_alias = None; token = Wenyan ThenWenyanKeyword; category = "文言文" };
    {
      chinese_text = "大于";
      english_alias = None;
      token = Wenyan GreaterThanWenyan;
      category = "文言文";
    };
    { chinese_text = "小于"; english_alias = None; token = Wenyan LessThanWenyan; category = "文言文" };
  ]

(** 古雅体关键字映射 (部分) *)
let ancient_keywords =
  [
    {
      chinese_text = "夫";
      english_alias = None;
      token = Ancient AncientDefineKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "算法";
      english_alias = None;
      token = Ancient AncientAlgorithmKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "竟";
      english_alias = None;
      token = Ancient AncientCompleteKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "观";
      english_alias = None;
      token = Ancient AncientObserveKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "性";
      english_alias = None;
      token = Ancient AncientNatureKeyword;
      category = "古雅体";
    };
    { chinese_text = "若"; english_alias = None; token = Ancient AncientIfKeyword; category = "古雅体" };
    {
      chinese_text = "则";
      english_alias = None;
      token = Ancient AncientThenKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "余者";
      english_alias = None;
      token = Ancient AncientOtherwiseKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "答";
      english_alias = None;
      token = Ancient AncientAnswerKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "递归";
      english_alias = None;
      token = Ancient AncientRecursiveKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "合";
      english_alias = None;
      token = Ancient AncientCombineKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "为一";
      english_alias = None;
      token = Ancient AncientAsOneKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "取";
      english_alias = None;
      token = Ancient AncientTakeKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "受";
      english_alias = None;
      token = Ancient AncientReceiveKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "之";
      english_alias = None;
      token = Ancient AncientParticleOf;
      category = "古雅体";
    };
    {
      chinese_text = "焉";
      english_alias = None;
      token = Ancient AncientParticleFun;
      category = "古雅体";
    };
    {
      chinese_text = "其";
      english_alias = None;
      token = Ancient AncientParticleThe;
      category = "古雅体";
    };
    {
      chinese_text = "空空如也";
      english_alias = None;
      token = Ancient AncientEmptyKeyword;
      category = "古雅体";
    };
    { chinese_text = "乃"; english_alias = None; token = Ancient AncientIsKeyword; category = "古雅体" };
    {
      chinese_text = "故";
      english_alias = None;
      token = Ancient AncientArrowKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "当";
      english_alias = None;
      token = Ancient AncientWhenKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "且";
      english_alias = None;
      token = Ancient AncientCommaKeyword;
      category = "古雅体";
    };
    {
      chinese_text = "而后";
      english_alias = None;
      token = Ancient AfterThatKeyword;
      category = "古雅体";
    };
  ]

(** 自然语言关键字映射 (部分) *)
let natural_language_keywords =
  [
    {
      chinese_text = "定义";
      english_alias = Some "define";
      token = NaturalLanguage DefineKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "接受";
      english_alias = Some "accept";
      token = NaturalLanguage AcceptKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "时返回";
      english_alias = Some "return_when";
      token = NaturalLanguage ReturnWhenKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "否则返回";
      english_alias = Some "else_return";
      token = NaturalLanguage ElseReturnKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "乘以";
      english_alias = Some "multiply";
      token = NaturalLanguage MultiplyKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "除以";
      english_alias = Some "divide";
      token = NaturalLanguage DivideKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "加上";
      english_alias = Some "add_to";
      token = NaturalLanguage AddToKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "减去";
      english_alias = Some "subtract";
      token = NaturalLanguage SubtractKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "等于";
      english_alias = Some "equal_to";
      token = NaturalLanguage EqualToKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "小于等于";
      english_alias = Some "lte";
      token = NaturalLanguage LessThanEqualToKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "首元素";
      english_alias = Some "first_element";
      token = NaturalLanguage FirstElementKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "剩余";
      english_alias = Some "remaining";
      token = NaturalLanguage RemainingKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "空";
      english_alias = Some "empty";
      token = NaturalLanguage EmptyKeyword;
      category = "自然语言";
    };
    {
      chinese_text = "字符数量";
      english_alias = Some "char_count";
      token = NaturalLanguage CharacterCountKeyword;
      category = "自然语言";
    };
  ]

(** 获取所有关键字映射 *)
let get_all_keyword_mappings () =
  core_language_keywords @ semantic_keywords @ error_handling_keywords @ module_system_keywords
  @ macro_system_keywords @ wenyan_keywords @ ancient_keywords @ natural_language_keywords

(** 创建查找映射表 *)
let create_lookup_tables () =
  let all_mappings = get_all_keyword_mappings () in
  let text_to_token = Hashtbl.create 256 in
  let token_to_text = Hashtbl.create 256 in

  List.iter
    (fun mapping ->
      (* 添加中文文本映射 *)
      Hashtbl.add text_to_token mapping.chinese_text mapping.token;
      Hashtbl.add token_to_text mapping.token mapping.chinese_text;

      (* 添加英文别名映射 *)
      match mapping.english_alias with
      | Some alias -> Hashtbl.add text_to_token alias mapping.token
      | None -> ())
    all_mappings;

  (text_to_token, token_to_text)

(** 全局查找表 *)
let text_to_token_table, token_to_text_table = create_lookup_tables ()

(** 关键字转换器实现 *)
let keyword_converter =
  let module KeywordConverter = struct
    let name = "unified_keyword_converter"
    let converter_type = KeywordConverter

    let string_to_token config text =
      let search_text = if config.case_sensitive then text else String.lowercase_ascii text in
      try
        let token = Hashtbl.find text_to_token_table search_text in
        ok_result token
      with Not_found -> error_result (UnknownToken (text, None))

    let token_to_string _config token =
      try
        let text = Hashtbl.find token_to_text_table token in
        ok_result text
      with Not_found -> error_result (ConversionError ("keyword_token", "string"))

    let can_handle_string text =
      Hashtbl.mem text_to_token_table text
      || Hashtbl.mem text_to_token_table (String.lowercase_ascii text)

    let can_handle_token token = Hashtbl.mem token_to_text_table token

    let supported_tokens () =
      let tokens = ref [] in
      Hashtbl.iter (fun token _ -> tokens := token :: !tokens) token_to_text_table;
      !tokens
  end in
  (module KeywordConverter : CONVERTER)

(** 根据类别获取关键字 *)
let get_keywords_by_category category =
  get_all_keyword_mappings ()
  |> List.filter (fun mapping -> mapping.category = category)
  |> List.map (fun mapping -> mapping.token)

(** 获取所有支持的类别 *)
let get_supported_categories () =
  get_all_keyword_mappings ()
  |> List.map (fun mapping -> mapping.category)
  |> List.sort_uniq String.compare

(** 检查是否为关键字Token *)
let is_keyword_token token = match keyword_converter with (module C) -> C.can_handle_token token

(** 获取关键字统计信息 *)
let get_keyword_stats () =
  let mappings = get_all_keyword_mappings () in
  let categories = get_supported_categories () in
  let stats_by_category =
    List.map
      (fun cat ->
        let count = List.length (List.filter (fun m -> m.category = cat) mappings) in
        (cat, count))
      categories
  in
  ("total", List.length mappings) :: stats_by_category
