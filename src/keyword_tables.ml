(** 骆言关键字表模块 - Chinese Programming Language Keyword Tables *)

(** 字符串比较模块 *)
module StringCompare = struct
  type t = string
  let compare = String.compare
end

(** 字符串Map模块 *)
module StringMap = Map.Make(StringCompare)

(** 字符串Set模块 *)
module StringSet = Set.Make(StringCompare)

(** 关键字映射模块 *)
module Keywords = struct
  (** 基础关键字映射表 *)
  let basic_keywords = [
    ("让", `LetKeyword);
    ("递归", `RecKeyword);
    ("在", `InKeyword);
    ("函数", `FunKeyword);
    ("如果", `IfKeyword);
    ("那么", `ThenKeyword);
    ("否则", `ElseKeyword);
    ("匹配", `MatchKeyword);
    ("与", `WithKeyword);
    ("其他", `OtherKeyword);
    ("类型", `TypeKeyword);
    ("私有", `PrivateKeyword);
    ("真", `TrueKeyword);
    ("假", `FalseKeyword);
    ("并且", `AndKeyword);
    ("或者", `OrKeyword);
    ("非", `NotKeyword);
  ]

  (** 语义类型系统关键字 *)
  let semantic_keywords = [
    ("作为", `AsKeyword);
    ("组合", `CombineKeyword);
    ("以及", `WithOpKeyword);
    ("当", `WhenKeyword);
  ]

  (** 错误恢复关键字 *)
  let error_recovery_keywords = [
    ("默认为", `WithDefaultKeyword);
    ("异常", `ExceptionKeyword);
    ("抛出", `RaiseKeyword);
    ("尝试", `TryKeyword);
    ("捕获", `CatchKeyword);
    ("最终", `FinallyKeyword);
  ]

  (** 类型关键字 *)
  let type_keywords = [
    ("of", `OfKeyword);
  ]

  (** 模块系统关键字 *)
  let module_keywords = [
    ("模块", `ModuleKeyword);
    ("模块类型", `ModuleTypeKeyword);
    ("引用", `RefKeyword);
    ("包含", `IncludeKeyword);
    ("函子", `FunctorKeyword);
    ("签名", `SigKeyword);
    ("结束", `EndKeyword);
  ]

  (** 宏系统关键字 *)
  let macro_keywords = [
    ("宏", `MacroKeyword);
    ("展开", `ExpandKeyword);
  ]

  (** wenyan风格关键字 *)
  let wenyan_keywords = [
    ("吾有", `HaveKeyword);
    ("一", `OneKeyword);
    ("名曰", `NameKeyword);
    ("设", `SetKeyword);
    ("也", `AlsoKeyword);
    ("乃", `ThenGetKeyword);
    ("曰", `CallKeyword);
    ("其值", `ValueKeyword);
    ("为", `AsForKeyword);
    ("数", `NumberKeyword);
  ]

  (** wenyan扩展关键字 *)
  let wenyan_extended_keywords = [
    ("欲行", `WantExecuteKeyword);
    ("必先得", `MustFirstGetKeyword);
    ("為是", `ForThisKeyword);
    ("遍", `TimesKeyword);
    ("云云", `EndCloudKeyword);
    ("若", `IfWenyanKeyword);
    ("者", `ThenWenyanKeyword);
    ("大于", `GreaterThanWenyan);
    ("小于", `LessThanWenyan);
    ("之", `OfParticle);
  ]

  (** 自然语言函数定义关键字 *)
  let natural_language_keywords = [
    ("定义", `DefineKeyword);
    ("接受", `AcceptKeyword);
    ("时返回", `ReturnWhenKeyword);
    ("否则返回", `ElseReturnKeyword);
    ("不然返回", `ElseReturnKeyword);
    ("乘以", `MultiplyKeyword);
    ("除以", `DivideKeyword);
    ("加上", `AddToKeyword);
    ("减去", `SubtractKeyword);
    ("等于", `EqualToKeyword);
    ("小于等于", `LessThanEqualToKeyword);
    ("首元素", `FirstElementKeyword);
    ("剩余", `RemainingKeyword);
    ("空", `EmptyKeyword);
    ("字符数量", `CharacterCountKeyword);
    ("输入", `InputKeyword);
    ("输出", `OutputKeyword);
    ("减一", `MinusOneKeyword);
    ("加", `PlusKeyword);
    ("其中", `WhereKeyword);
    ("小", `SmallKeyword);
    ("应得", `ShouldGetKeyword);
  ]

  (** 基本类型关键字 *)
  let type_annotation_keywords = [
    ("整数", `IntTypeKeyword);
    ("浮点数", `FloatTypeKeyword);
    ("字符串", `StringTypeKeyword);
    ("布尔", `BoolTypeKeyword);
    ("单元", `UnitTypeKeyword);
    ("列表", `ListTypeKeyword);
    ("数组", `ArrayTypeKeyword);
  ]

  (** 多态变体关键字 *)
  let variant_keywords = [
    ("变体", `VariantKeyword);
    ("标签", `TagKeyword);
  ]

  (** 古雅体关键字 *)
  let ancient_keywords = [
    ("夫", `AncientDefineKeyword);
    ("也", `AncientEndKeyword);
    ("算法", `AncientAlgorithmKeyword);
    ("竟", `AncientCompleteKeyword);
    ("观", `AncientObserveKeyword);
    ("性", `AncientNatureKeyword);
    ("则", `AncientThenKeyword);
    ("余者", `AncientOtherwiseKeyword);
    ("答", `AncientAnswerKeyword);
    ("合", `AncientCombineKeyword);
    ("为一", `AncientAsOneKeyword);
    ("取", `AncientTakeKeyword);
    ("受", `AncientReceiveKeyword);
    ("其", `AncientParticleThe);
    ("焉", `AncientParticleFun);
    ("名曰", `AncientCallItKeyword);
    ("列开始", `AncientListStartKeyword);
    ("列结束", `AncientListEndKeyword);
    ("其一", `AncientItsFirstKeyword);
    ("其二", `AncientItsSecondKeyword);
    ("其三", `AncientItsThirdKeyword);
    ("空空如也", `AncientEmptyKeyword);
    ("有首有尾", `AncientHasHeadTailKeyword);
    ("首名为", `AncientHeadNameKeyword);
    ("尾名为", `AncientTailNameKeyword);
    ("则答", `AncientThusAnswerKeyword);
    ("并加", `AncientAddToKeyword);
    ("观察毕", `AncientObserveEndKeyword);
    ("始", `AncientBeginKeyword);
    ("毕", `AncientEndCompleteKeyword);
    ("乃", `AncientIsKeyword);
    ("故", `AncientArrowKeyword);
    ("当", `AncientWhenKeyword);
    ("且", `AncientCommaKeyword);
    ("而后", `AfterThatKeyword);
    ("观毕", `AncientObserveEndKeyword);
  ]


  (** 特殊关键字 - 注意：这个需要特殊处理 *)
  let special_keywords = [
    ("数值", `IdentifierTokenSpecial);
  ]

  (** 合并所有关键字 *)
  let all_keywords_list = 
    basic_keywords @ semantic_keywords @ error_recovery_keywords @ 
    type_keywords @ module_keywords @ macro_keywords @ 
    wenyan_keywords @ wenyan_extended_keywords @ natural_language_keywords @
    type_annotation_keywords @ variant_keywords @ ancient_keywords @
    special_keywords

  (** 高效关键字映射表 - 使用Map替代List.assoc *)
  let keyword_map = 
    List.fold_left (fun acc (key, value) -> 
      StringMap.add key value acc
    ) StringMap.empty all_keywords_list

  (** 高效关键字查找 - 使用Map替代线性查找 *)
  let find_keyword str = StringMap.find_opt str keyword_map

  (** 检查是否为关键字 *)
  let is_keyword str = StringMap.mem str keyword_map

  (** 获取所有关键字列表 *)
  let all_keywords () = StringMap.bindings keyword_map |> List.map fst
end

(** 保留词模块 *)
module ReservedWords = struct
  (** 保留词表（优先于关键字处理，避免复合词被错误分割）*)
  let reserved_words_list = [
    (* 基本数据类型相关（不包含基础类型关键字）*)
    "浮点";
    "字符";
    (* 数学函数和类型转换函数 *)
    "对数";
    "自然对数";
    "十进制对数";
    "平方根";
    "正弦";
    "余弦";
    "正切";
    "反正弦";
    "反余弦";
    "反正切";
    "绝对值";
    "幂运算";
    "指数";
    "取整";
    "向上取整";
    "向下取整";
    "四舍五入";
    "最大公约数";
    "最小公倍数";
    "字符串到整数";
    "字符串到浮点数";
    "整数到字符串";
    "浮点数到字符串";
    "字符串连接";
    "字符串长度";
    "字符串分割";
    "字符串替换";
    "字符串比较";
    "子字符串";
    "大写转换";
    "小写转换";
    "去除空白";
    (* 其他重要的保留词... *)
    "空字符串";
    "数据类型";
  ]

  (** 高效保留词集合 *)
  let reserved_words_set = 
    List.fold_left (fun acc word -> 
      StringSet.add word acc
    ) StringSet.empty reserved_words_list

  (** 检查是否为保留词 *)
  let is_reserved_word str = StringSet.mem str reserved_words_set

  (** 获取所有保留词列表 *)
  let all_reserved_words () = reserved_words_list
end