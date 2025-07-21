(** 骆言基础关键字数据模块 - 从keyword_tables.ml重构提取 提供高效的关键字数据存储和访问接口 *)

(** 基础关键字映射表 *)
let basic_keywords =
  [
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
let semantic_keywords =
  [ ("作为", `AsKeyword); ("组合", `CombineKeyword); ("以及", `WithOpKeyword); ("当", `WhenKeyword) ]

(** 错误恢复关键字 *)
let error_recovery_keywords =
  [
    ("默认为", `WithDefaultKeyword);
    ("异常", `ExceptionKeyword);
    ("抛出", `RaiseKeyword);
    ("尝试", `TryKeyword);
    ("捕获", `CatchKeyword);
    ("最终", `FinallyKeyword);
  ]

(** 类型关键字 *)
let type_keywords = [ ("of", `OfKeyword) ]

(** 模块系统关键字 *)
let module_keywords =
  [
    ("模块", `ModuleKeyword);
    ("模块类型", `ModuleTypeKeyword);
    ("引用", `RefKeyword);
    ("包含", `IncludeKeyword);
    ("函子", `FunctorKeyword);
    ("签名", `SigKeyword);
    ("结束", `EndKeyword);
  ]

(** 宏系统关键字 *)
let macro_keywords = [ ("宏", `MacroKeyword); ("展开", `ExpandKeyword) ]

(** wenyan风格关键字 *)
let wenyan_keywords =
  [
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
let wenyan_extended_keywords =
  [
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
let natural_language_keywords =
  [
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
let type_annotation_keywords =
  [
    ("整数", `IntTypeKeyword);
    ("浮点数", `FloatTypeKeyword);
    ("字符串", `StringTypeKeyword);
    ("布尔", `BoolTypeKeyword);
    ("单元", `UnitTypeKeyword);
    ("列表", `ListTypeKeyword);
    ("数组", `ArrayTypeKeyword);
  ]

(** 多态变体关键字 *)
let variant_keywords = [ ("变体", `VariantKeyword); ("标签", `TagKeyword) ]

(** 古雅体关键字 *)
let ancient_keywords =
  [
    ("夫", `AncientDefineKeyword);
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
    ("故", `AncientArrowKeyword);
    ("当", `AncientWhenKeyword);
    ("且", `AncientCommaKeyword);
    ("而后", `AfterThatKeyword);
    ("观毕", `AncientObserveEndKeyword);
    (* 古雅体记录类型关键词 *)
    ("据开始", `AncientRecordStartKeyword);
    ("据结束", `AncientRecordEndKeyword);
    ("据空", `AncientRecordEmptyKeyword);
    ("据更新", `AncientRecordUpdateKeyword);
    ("据毕", `AncientRecordFinishKeyword);
  ]

(** 特殊关键字 - 注意：这个需要特殊处理 *)
let special_keywords = [ 
  ("数值", `IdentifierTokenSpecial);
  (* 内置函数名称 - 添加以支持无引号标识符 *)
  ("打印", `IdentifierTokenSpecial);
  ("读取", `IdentifierTokenSpecial);
  ("读取文件", `IdentifierTokenSpecial);
  ("写入文件", `IdentifierTokenSpecial);
  ("文件存在", `IdentifierTokenSpecial);
  ("列出目录", `IdentifierTokenSpecial);
  ("长度", `IdentifierTokenSpecial);
  ("连接", `IdentifierTokenSpecial);
  ("映射", `IdentifierTokenSpecial);
  ("过滤", `IdentifierTokenSpecial);
  ("折叠", `IdentifierTokenSpecial);
  ("反转", `IdentifierTokenSpecial);
  ("排序", `IdentifierTokenSpecial);
  ("包含", `IdentifierTokenSpecial);
  ("范围", `IdentifierTokenSpecial);
  ("最大值", `IdentifierTokenSpecial);
  ("最小值", `IdentifierTokenSpecial);
  ("求和", `IdentifierTokenSpecial);
  ("字符串长度", `IdentifierTokenSpecial);
  ("字符串连接", `IdentifierTokenSpecial);
  ("字符串分割", `IdentifierTokenSpecial);
  ("字符串包含", `IdentifierTokenSpecial);
  ("字符串反转", `IdentifierTokenSpecial);
  ("字符串匹配", `IdentifierTokenSpecial);
  ("字符串转整数", `IdentifierTokenSpecial);
  ("字符串转浮点数", `IdentifierTokenSpecial);
  ("整数转字符串", `IdentifierTokenSpecial);
  ("整数转浮点数", `IdentifierTokenSpecial);
  ("浮点数转字符串", `IdentifierTokenSpecial);
  ("浮点数转整数", `IdentifierTokenSpecial);
  ("布尔值转字符串", `IdentifierTokenSpecial);
  ("创建数组", `IdentifierTokenSpecial);
  ("数组长度", `IdentifierTokenSpecial);
  ("数组获取", `IdentifierTokenSpecial);
  ("数组设置", `IdentifierTokenSpecial);
  ("数组转列表", `IdentifierTokenSpecial);
  ("列表转数组", `IdentifierTokenSpecial);
  ("复制数组", `IdentifierTokenSpecial);
  ("移除井号注释", `IdentifierTokenSpecial);
  ("移除双斜杠注释", `IdentifierTokenSpecial);
  ("移除块注释", `IdentifierTokenSpecial);
  ("移除英文字符串", `IdentifierTokenSpecial);
  ("移除骆言字符串", `IdentifierTokenSpecial);
  ("过滤ly文件", `IdentifierTokenSpecial)
]

(** 合并所有关键字 *)
let all_keywords_list =
  List.concat
    [
      basic_keywords;
      semantic_keywords;
      error_recovery_keywords;
      type_keywords;
      module_keywords;
      macro_keywords;
      ancient_keywords; (* Moved ancient keywords before wenyan to prioritize AncientEndKeyword *)
      wenyan_keywords;
      wenyan_extended_keywords;
      natural_language_keywords;
      type_annotation_keywords;
      variant_keywords;
      special_keywords;
    ]
