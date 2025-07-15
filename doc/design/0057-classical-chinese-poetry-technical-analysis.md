# RFC 0057: 古典诗词形式技术支持分析与改进建议

## 摘要

本文档通过深入分析骆言编程语言的当前技术架构，识别出支持古典中文诗词形式（四言骈体、五言律诗、七言绝句、音韵、对仗）所需的具体技术改进领域。基于对Parser、Lexer、AST、语义分析器等核心模块的分析，提出了一系列技术实现方案。

## 当前技术架构分析

### 1. Parser模块现状

**现有能力**：
- 已实现模块化Parser架构（Parser_ancient.ml、Parser_expressions.ml等）
- 支持古雅体语法：`夫函数名者受参数焉算法乃表达式是谓`
- 支持文言风格：`吾有一数名曰数值其值42也`
- 支持自然语言函数定义：`定义函数名接受参数`

**限制**：
- 缺乏诗词韵律结构支持
- 无字符数量约束机制
- 缺乏对偶结构验证
- 无音韵分析功能

### 2. Lexer模块现状

**现有能力**：
- 200多个token类型，包括古雅体关键字
- 支持中文标点符号（ChineseLeftParen、ChineseComma等）
- 支持引用标识符（QuotedIdentifierToken）
- 支持中文数字（ChineseNumberToken）

**限制**：
- 缺乏音韵标记token
- 无韵脚检测机制
- 缺乏平仄声调token
- 无诗词结构标记

### 3. AST模块现状

**现有能力**：
- 丰富的表达式类型（expr类型包含25+种表达式）
- 模式匹配支持（pattern类型）
- 函数表达式支持（FunExpr、FunExprWithType）

**限制**：
- 缺乏诗词结构AST节点
- 无韵律约束表达式
- 缺乏对偶结构表示

### 4. 语义分析器现状

**现有能力**：
- 符号表管理（SymbolTable）
- 类型推断（infer_return_type）
- 自然语言函数语义分析（nlf_semantic.ml）

**限制**：
- 无韵律验证
- 缺乏声调分析
- 无对偶结构验证

## 技术改进建议

### 1. Lexer扩展：音韵支持

**新增Token类型**：
```ocaml
(* 音韵相关token *)
| ToneToken of tone_type          (* 声调标记 *)
| RhymeToken of rhyme_type        (* 韵脚标记 *)
| TonalPatternToken of string     (* 平仄模式 *)
| RhymeSchemeToken of string      (* 韵律方案 *)
| PoeticLineBreak                 (* 诗行分隔符 *)
| PoeticStanzaBreak               (* 诗节分隔符 *)
| ParallelStructureStart          (* 对偶结构开始 *)
| ParallelStructureEnd            (* 对偶结构结束 *)

(* 诗词特定标点 *)
| ChinesePoeticPause              (* 、 - 诗词停顿 *)
| ChinesePoeticEnd                (* 。 - 诗句结束 *)
| ChineseRhymeMarker              (* 韵脚标记 *)
```

**音韵分析功能**：
```ocaml
(* 在lexer.ml中添加 *)
let analyze_tone char =
  match char with
  | '一' | '七' | '八' | '三' -> FlatTone  (* 平声 *)
  | '二' | '五' | '六' | '四' -> RisingTone (* 仄声 *)
  | _ -> UnknownTone

let detect_rhyme_ending word =
  let last_char = String.get word (String.length word - 1) in
  match last_char with
  | '安' | '山' | '间' -> RhymeA
  | '诗' | '时' | '知' -> RhymeB
  | _ -> NoRhyme
```

### 2. Parser扩展：诗词结构解析

**新增解析函数**：
```ocaml
(* 在Parser_ancient.ml中添加 *)

(** 解析四言骈体 *)
val parse_four_character_parallel : expr_parser -> parser_state -> expr * parser_state

(** 解析五言律诗 *)
val parse_five_character_regulated : expr_parser -> parser_state -> expr * parser_state

(** 解析七言绝句 *)
val parse_seven_character_quatrain : expr_parser -> parser_state -> expr * parser_state

(** 解析对偶结构 *)
val parse_parallel_structure : expr_parser -> parser_state -> expr * parser_state
```

**实现示例**：
```ocaml
let parse_four_character_parallel parse_expr state =
  (* 期望：定义函数名　接受参数甲　返回结果乙　算法完成 *)
  let function_name, state1 = parse_identifier state in
  let state2 = expect_character_count state1 4 in (* 验证4字符 *)
  let param_name, state3 = parse_identifier state2 in
  let state4 = expect_character_count state3 4 in (* 验证4字符 *)
  let result_expr, state5 = parse_expr state4 in
  let state6 = expect_character_count state5 4 in (* 验证4字符 *)
  let state7 = expect_token state6 AncientCompleteKeyword in
  let state8 = expect_character_count state7 4 in (* 验证4字符 *)
  
  (* 创建带有韵律约束的函数表达式 *)
  let fun_expr = FunExpr ([param_name], result_expr) in
  let poetry_annotated = PoetryAnnotatedExpr (fun_expr, FourCharacterParallel) in
  (LetExpr (function_name, poetry_annotated, VarExpr function_name), state8)
```

### 3. AST扩展：诗词结构表示

**新增AST节点**：
```ocaml
(* 在ast.ml中添加 *)

(** 诗词结构类型 *)
type poetry_form =
  | FourCharacterParallel          (* 四言骈体 *)
  | FiveCharacterRegulated         (* 五言律诗 *)
  | SevenCharacterQuatrain         (* 七言绝句 *)
  | CustomPoetryForm of string     (* 自定义诗词形式 *)

(** 音韵信息 *)
type prosody_info = {
  tone_pattern : tone_type list;    (* 声调模式 *)
  rhyme_scheme : rhyme_type list;   (* 韵律方案 *)
  character_count : int;            (* 字符数量 *)
  line_count : int;                 (* 行数 *)
}

(** 对偶结构信息 *)
type parallel_structure = {
  left_part : expr;                 (* 上联/左半部分 *)
  right_part : expr;                (* 下联/右半部分 *)
  parallel_type : parallel_type;    (* 对偶类型 *)
}

(** 扩展表达式类型 *)
type expr =
  | ... (* 现有表达式类型 *)
  | PoetryAnnotatedExpr of expr * poetry_form      (* 带诗词形式标注的表达式 *)
  | ProsodyConstraintExpr of expr * prosody_info   (* 带音韵约束的表达式 *)
  | ParallelStructureExpr of parallel_structure    (* 对偶结构表达式 *)
  | RhymeGroupExpr of expr list * rhyme_type       (* 韵脚组表达式 *)
  | TonalPatternExpr of expr * tone_type list      (* 声调模式表达式 *)
```

### 4. 语义分析器扩展：韵律验证

**新增验证模块**：
```ocaml
(* 创建新文件：src/Poetry_semantic.ml *)

(** 诗词语义验证器 *)
module PoetrySemanticValidator = struct
  
  (** 验证四言骈体结构 *)
  let validate_four_character_parallel expr =
    let rec check_character_count expr expected =
      match expr with
      | VarExpr name -> String.length name = expected
      | FunCallExpr (VarExpr name, _) -> String.length name = expected
      | _ -> false
    in
    (* 验证每个部分都是4字符 *)
    check_character_count expr 4

  (** 验证音韵一致性 *)
  let validate_rhyme_consistency exprs rhyme_scheme =
    let extract_rhyme_from_expr expr =
      (* 从表达式中提取韵脚 *)
      match expr with
      | VarExpr name -> detect_rhyme_ending name
      | _ -> NoRhyme
    in
    let rhymes = List.map extract_rhyme_from_expr exprs in
    (* 验证韵脚模式 *)
    List.for_all2 (fun actual expected -> actual = expected) rhymes rhyme_scheme

  (** 验证对偶结构 *)
  let validate_parallel_structure left_expr right_expr =
    let get_structure_pattern expr =
      (* 分析表达式的结构模式 *)
      match expr with
      | BinaryOpExpr (_, op, _) -> op
      | FunCallExpr (_, args) -> List.length args
      | _ -> 0
    in
    let left_pattern = get_structure_pattern left_expr in
    let right_pattern = get_structure_pattern right_expr in
    (* 验证结构对称性 *)
    left_pattern = right_pattern

  (** 验证声调平仄 *)
  let validate_tonal_pattern expr expected_pattern =
    let rec extract_tones expr =
      match expr with
      | VarExpr name -> 
          String.to_seq name |> Seq.map analyze_tone |> List.of_seq
      | BinaryOpExpr (left, _, right) ->
          extract_tones left @ extract_tones right
      | _ -> []
    in
    let actual_tones = extract_tones expr in
    List.for_all2 (fun actual expected -> actual = expected) actual_tones expected_pattern

end
```

### 5. 标准库扩展：诗词辅助函数

**新增诗词相关函数**：
```ocaml
(* 在标准库中添加 *)

(** 韵脚检测函数 *)
let 检测韵脚 word =
  detect_rhyme_ending word

(** 声调分析函数 *)
let 分析声调 character =
  analyze_tone character

(** 字符数量验证函数 *)
let 验证字符数 text expected_count =
  String.length text = expected_count

(** 对偶结构生成函数 *)
let 生成对偶 left_part right_part =
  ParallelStructureExpr {
    left_part = left_part;
    right_part = right_part;
    parallel_type = Syntactic;
  }

(** 诗词格式化函数 *)
let 格式化诗词 poetry_expr form =
  match form with
  | FourCharacterParallel ->
      (* 四言骈体格式化 *)
      format_four_character_parallel poetry_expr
  | FiveCharacterRegulated ->
      (* 五言律诗格式化 *)
      format_five_character_regulated poetry_expr
  | SevenCharacterQuatrain ->
      (* 七言绝句格式化 *)
      format_seven_character_quatrain poetry_expr
```

### 6. 错误处理和提示改进

**诗词相关错误信息**：
```ocaml
(* 在compiler_errors.ml中添加 *)

type poetry_error =
  | CharacterCountMismatch of int * int  (* 实际字符数 * 期望字符数 *)
  | RhymeSchemeViolation of string       (* 韵律方案违规 *)
  | TonalPatternError of string          (* 声调模式错误 *)
  | ParallelStructureImbalance of string (* 对偶结构不平衡 *)
  | PoeticFormConstraintViolation of string (* 诗词形式约束违规 *)

let format_poetry_error error =
  match error with
  | CharacterCountMismatch (actual, expected) ->
      Printf.sprintf "字符数量不匹配：实际 %d 字符，期望 %d 字符" actual expected
  | RhymeSchemeViolation msg ->
      Printf.sprintf "韵律方案违规：%s" msg
  | TonalPatternError msg ->
      Printf.sprintf "声调模式错误：%s" msg
  | ParallelStructureImbalance msg ->
      Printf.sprintf "对偶结构不平衡：%s" msg
  | PoeticFormConstraintViolation msg ->
      Printf.sprintf "诗词形式约束违规：%s" msg
```

## 实施计划

### 第一阶段：基础音韵支持（2-3周）

1. **Lexer扩展**：
   - 添加音韵相关token类型
   - 实现基础音韵分析函数
   - 添加诗词特定标点支持

2. **AST扩展**：
   - 添加诗词结构AST节点
   - 实现音韵信息表示
   - 添加对偶结构支持

### 第二阶段：Parser诗词结构支持（3-4周）

1. **Parser扩展**：
   - 实现四言骈体解析器
   - 实现五言律诗解析器
   - 实现七言绝句解析器
   - 实现对偶结构解析器

2. **语义验证**：
   - 创建诗词语义验证模块
   - 实现韵律一致性检查
   - 实现声调平仄验证

### 第三阶段：高级功能与优化（2-3周）

1. **标准库扩展**：
   - 添加诗词辅助函数
   - 实现诗词格式化工具
   - 创建韵脚检测函数

2. **错误处理改进**：
   - 添加诗词相关错误类型
   - 实现智能错误提示
   - 提供诗词修正建议

### 第四阶段：测试与文档（1-2周）

1. **测试覆盖**：
   - 创建诗词解析测试用例
   - 添加音韵验证测试
   - 实现对偶结构测试

2. **文档编写**：
   - 编写诗词编程指南
   - 创建API文档
   - 提供示例代码

## 示例代码

### 四言骈体函数定义
```luoyan
夫快排者　受列表焉　算法乃
　　观其长短　若小则返　大则分之　递归合并
是谓快排
```

### 五言律诗算法
```luoyan
定义排序法　　/* 5字 */
接受数组参　　/* 5字 */
遍历比较值　　/* 5字 */
交换位置定　　/* 5字 */
返回有序组　　/* 5字 */
算法乃完成　　/* 5字 */
```

### 七言绝句数据结构
```luoyan
吾有一树结构七字名　　/* 7字 */
其根节点指向左右分　　/* 7字 */
左子树存储小值数据　　/* 7字 */
右子树存储大值完成　　/* 7字 */
```

### 对偶结构函数
```luoyan
生成对偶 (
  左部分: 夫加法者受二数焉,
  右部分: 夫减法者受二数焉
)
```

## 技术挑战与解决方案

### 1. 性能挑战
- **问题**：音韵分析可能影响编译性能
- **解决方案**：实现延迟音韵分析，仅在启用诗词模式时进行

### 2. 兼容性挑战
- **问题**：诗词语法与现有语法的兼容性
- **解决方案**：实现渐进式语法支持，可选择启用诗词模式

### 3. 复杂性挑战
- **问题**：诗词规则复杂，难以形式化
- **解决方案**：实现分层验证，从基础字符数量到高级音韵规则

## 结论

通过以上技术改进，骆言编程语言将能够支持古典中文诗词形式，实现真正的"诗词编程"。这不仅是技术创新，更是文化传承的重要实践。

建议按照分阶段实施计划，逐步完善诗词支持功能，最终实现维护者所期望的艺术性编程语言目标。

---

**作者**：Claude Assistant  
**时间**：2025年7月15日  
**版本**：1.0  
**状态**：技术建议书