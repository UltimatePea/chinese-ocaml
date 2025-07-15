(** 骆言词法分析器 - Chinese Programming Language Lexer *)

(** 词元类型 *)
type token =
  (* 字面量 *)
  | IntToken of int
  | FloatToken of float
  | StringToken of string
  | BoolToken of bool
  
  (* 标识符 *)
  | IdentifierToken of string
  | QuotedIdentifierToken of string   (* 「标识符」 *)
  | IdentifierTokenSpecial of string  (* 特殊保护的标识符，如"数值" *)
  
  (* 关键字 *)
  | LetKeyword                  (* 让 - let *)
  | RecKeyword                  (* 递归 - rec *)
  | InKeyword                   (* 在 - in *)
  | FunKeyword                  (* 函数 - fun *)
  | IfKeyword                   (* 如果 - if *)
  | ThenKeyword                 (* 那么 - then *)
  | ElseKeyword                 (* 否则 - else *)
  | MatchKeyword                (* 匹配 - match *)
  | WithKeyword                 (* 与 - with *)
  | OtherKeyword                (* 其他 - other/wildcard *)
  | TypeKeyword                 (* 类型 - type *)
  | TrueKeyword                 (* 真 - true *)
  | FalseKeyword                (* 假 - false *)
  | AndKeyword                  (* 并且 - and *)
  | OrKeyword                   (* 或者 - or *)
  | NotKeyword                  (* 非 - not *)
  
  (* 语义类型系统关键字 *)
  | AsKeyword                   (* 作为 - as *)
  | CombineKeyword              (* 组合 - combine *)
  | WithOpKeyword               (* 以及 - with_op *)
  | WhenKeyword                 (* 当 - when *)
  
  (* 错误恢复关键字 *)
  | OrElseKeyword               (* 否则返回 - or_else *)
  | WithDefaultKeyword          (* 默认为 - with_default *)
  
  (* 异常处理关键字 *)
  | ExceptionKeyword            (* 异常 - exception *)
  | RaiseKeyword                (* 抛出 - raise *)
  | TryKeyword                  (* 尝试 - try *)
  | CatchKeyword                (* 捕获 - catch/with *)
  | FinallyKeyword              (* 最终 - finally *)
  
  (* 类型关键字 *)
  | OfKeyword                   (* of - for type constructors *)
  
  (* 模块系统关键字 *)
  | ModuleKeyword               (* 模块 - module *)
  | ModuleTypeKeyword           (* 模块类型 - module type *)
  | SigKeyword                  (* 签名 - sig *)
  | EndKeyword                  (* 结束 - end *)
  | FunctorKeyword              (* 函子 - functor *)
  
  (* 可变性关键字 *)
  | RefKeyword                  (* 引用 - ref *)

  (* 新增模块系统关键字 *)
  | IncludeKeyword              (* 包含 - include *)
  
  (* 宏系统关键字 *)
  | MacroKeyword                (* 宏 - macro *)
  | ExpandKeyword               (* 展开 - expand *)
  
  (* wenyan风格关键字 *)
  | HaveKeyword                 (* 吾有 - I have *)
  | OneKeyword                  (* 一 - one *)
  | NameKeyword                 (* 名曰 - name it *)
  | SetKeyword                  (* 设 - set *)
  | AlsoKeyword                 (* 也 - also/end particle *)
  | ThenGetKeyword              (* 乃 - then/thus *)
  | CallKeyword                 (* 曰 - called/said *)
  | ValueKeyword                (* 其值 - its value *)
  | AsForKeyword                (* 为 - as for/regarding *)
  | NumberKeyword               (* 数 - number *)
  
  (* wenyan扩展关键字 *)
  | WantExecuteKeyword          (* 欲行 - want to execute *)
  | MustFirstGetKeyword         (* 必先得 - must first get *)
  | ForThisKeyword              (* 為是 - for this *)
  | TimesKeyword                (* 遍 - times/iterations *)
  | EndCloudKeyword             (* 云云 - end marker *)
  | IfWenyanKeyword             (* 若 - if (wenyan style) *)
  | ThenWenyanKeyword           (* 者 - then particle *)
  | GreaterThanWenyan           (* 大于 - greater than *)
  | LessThanWenyan              (* 小于 - less than *)
  
  (* 古雅体关键字 - Ancient Chinese Literary Style *)
  | AncientDefineKeyword        (* 夫...者 - ancient function definition *)
  | AncientEndKeyword           (* 是谓 - ancient end marker *)
  | AncientAlgorithmKeyword     (* 算法 - algorithm *)
  | AncientCompleteKeyword      (* 竟 - complete/finish *)
  | AncientObserveKeyword       (* 观 - observe/examine *)
  | AncientNatureKeyword        (* 性 - nature/essence *)
  | AncientIfKeyword            (* 若 - if (ancient style) *)
  | AncientThenKeyword          (* 则 - then (ancient) *)
  | AncientOtherwiseKeyword     (* 余者 - otherwise/others *)
  | AncientAnswerKeyword        (* 答 - answer/return *)
  | AncientRecursiveKeyword     (* 递归 - recursive (ancient) *)
  | AncientCombineKeyword       (* 合 - combine *)
  | AncientAsOneKeyword         (* 为一 - as one *)
  | AncientTakeKeyword          (* 取 - take/get *)
  | AncientReceiveKeyword       (* 受 - receive *)
  | AncientParticleOf           (* 之 - possessive particle *)
  | AncientParticleFun          (* 焉 - function parameter particle *)
  | AncientParticleThe          (* 其 - its/the *)
  | AncientCallItKeyword        (* 名曰 - call it *)
  | AncientListStartKeyword     (* 列开始 - list start *)
  | AncientListEndKeyword       (* 列结束 - list end *)
  | AncientItsFirstKeyword      (* 其一 - its first *)
  | AncientItsSecondKeyword     (* 其二 - its second *)
  | AncientItsThirdKeyword      (* 其三 - its third *)
  | AncientEmptyKeyword         (* 空空如也 - empty as void *)
  | AncientHasHeadTailKeyword   (* 有首有尾 - has head and tail *)
  | AncientHeadNameKeyword      (* 首名为 - head named as *)
  | AncientTailNameKeyword      (* 尾名为 - tail named as *)
  | AncientThusAnswerKeyword    (* 则答 - thus answer *)
  | AncientAddToKeyword         (* 并加 - and add *)
  | AncientObserveEndKeyword    (* 观察毕 - observation complete *)
  | AncientBeginKeyword         (* 始 - begin *)
  | AncientEndCompleteKeyword   (* 毕 - complete *)
  | AncientIsKeyword            (* 乃 - is/thus *)
  | AncientArrowKeyword         (* 故 - therefore/thus *)
  | AncientWhenKeyword          (* 当 - when *)
  | AncientCommaKeyword         (* 且 - and/also *)
  | AncientPeriodKeyword        (* 也 - particle for end of statement *)
  | AfterThatKeyword            (* 而后 - after that/then *)
  
  (* 自然语言函数定义关键字 *)
  | DefineKeyword               (* 定义 - define *)
  | AcceptKeyword               (* 接受 - accept *)
  | ReturnWhenKeyword           (* 时返回 - return when *)
  | ElseReturnKeyword           (* 否则返回 - else return *)
  | MultiplyKeyword             (* 乘以 - multiply *)
  | AddToKeyword                (* 加上 - add to *)
  | SubtractKeyword             (* 减去 - subtract *)
  | IsKeyword                   (* 为 - is *)
  | EqualToKeyword              (* 等于 - equal to *)
  | LessThanEqualToKeyword      (* 小于等于 - less than or equal to *)
  | FirstElementKeyword         (* 首元素 - first element *)
  | RemainingKeyword            (* 剩余 - remaining *)
  | EmptyKeyword                (* 空 - empty *)
  | CharacterCountKeyword       (* 字符数量 - character count *)
  | OfParticle                  (* 之 - possessive particle *)
  | TopicMarker                 (* 者 - topic marker *)
  
  (* 新增自然语言函数定义关键字 *)
  | InputKeyword                (* 输入 - input *)
  | OutputKeyword               (* 输出 - output *)
  | MinusOneKeyword             (* 减一 - minus one *)
  | PlusKeyword                 (* 加 - plus *)
  | WhereKeyword                (* 其中 - where *)
  | SmallKeyword                (* 小 - small *)
  
  (* 基本类型关键字 *)
  | IntTypeKeyword              (* 整数 - int *)
  | FloatTypeKeyword            (* 浮点数 - float *)
  | StringTypeKeyword           (* 字符串 - string *)
  | BoolTypeKeyword             (* 布尔 - bool *)
  | UnitTypeKeyword             (* 单元 - unit *)
  | ListTypeKeyword             (* 列表 - list *)
  | ArrayTypeKeyword            (* 数组 - array *)
  
  
  (* 运算符 *)
  | Plus                        (* + *)
  | Minus                       (* - *)
  | Multiply                    (* * *)
  | Star                        (* * - alias for Multiply *)
  | Divide                      (* / *)
  | Slash                       (* / - alias for Divide *)
  | Modulo                      (* % *)
  | Concat                      (* ^ - 字符串连接 *)
  | Assign                      (* = *)
  | Equal                       (* == *)
  | NotEqual                    (* <> *)
  | Less                        (* < *)
  | LessEqual                   (* <= *)
  | Greater                     (* > *)
  | GreaterEqual                (* >= *)
  | Arrow                       (* -> *)
  | DoubleArrow                 (* => *)
  | Dot                         (* . *)
  | DoubleDot                   (* .. *)
  | TripleDot                   (* ... *)
  | Bang                        (* ! - for dereferencing *)
  | RefAssign                   (* := - for reference assignment *)
  
  (* 分隔符 *)
  | LeftParen                   (* ( *)
  | RightParen                  (* ) *)
  | LeftBrace                   (* { *)
  | RightBrace                  (* } *)
  | Comma                       (* , *)
  | Semicolon                   (* ; *)
  | Colon                       (* : *)
  | Pipe                        (* | *)
  | Underscore                  (* _ *)
  | LeftArray                   (* [| *)
  | RightArray                  (* |] *)
  | AssignArrow                 (* <- *)
  | LeftQuote                   (* 「 *)
  | RightQuote                  (* 」 *)
  
  (* 中文标点符号 *)
  | ChineseLeftParen            (* （ *)
  | ChineseRightParen           (* ） *)
  | ChineseComma                (* ， *)
  | ChineseSemicolon            (* ； *)
  | ChineseColon                (* ： *)
  | ChinesePipe                 (* ｜ *)
  | ChineseLeftArray            (* 「| *)
  | ChineseRightArray           (* |」 *)
  | ChineseLeftBracket          (* 【 *)
  | ChineseRightBracket         (* 】 *)
  | ChineseArrow                (* → *)
  | ChineseDoubleArrow          (* ⇒ *)
  | ChineseAssignArrow          (* ← *)
  
  (* 特殊 *)
  | Newline
  | EOF
[@@deriving show, eq]

(** 位置信息 *)
type position = {
  line: int;
  column: int;
  filename: string;
} [@@deriving show, eq]

(** 带位置的词元 *)
type positioned_token = token * position [@@deriving show, eq]

(** 词法错误 *)
exception LexError of string * position

(** 关键字映射表 *)
let keyword_table = [
  ("让", LetKeyword);
  ("递归", RecKeyword);
  ("在", InKeyword);
  ("函数", FunKeyword);
  ("如果", IfKeyword);
  ("那么", ThenKeyword);
  ("否则", ElseKeyword);
  ("匹配", MatchKeyword);
  ("与", WithKeyword);
  ("其他", OtherKeyword);
  ("类型", TypeKeyword);
  ("真", TrueKeyword);
  ("假", FalseKeyword);
  ("并且", AndKeyword);
  ("或者", OrKeyword);
  ("非", NotKeyword);
  
  (* 语义类型系统关键字 *)
  ("作为", AsKeyword);
  ("组合", CombineKeyword);
  ("以及", WithOpKeyword);
  ("当", WhenKeyword);
  
  (* 错误恢复关键字 *)
  ("默认为", WithDefaultKeyword);
  ("异常", ExceptionKeyword);
  ("抛出", RaiseKeyword);
  ("尝试", TryKeyword);
  ("捕获", CatchKeyword);
  ("最终", FinallyKeyword);
  ("of", OfKeyword);
  
  (* 模块系统关键字 *)
  ("模块", ModuleKeyword);
  ("模块类型", ModuleTypeKeyword);
  ("引用", RefKeyword);
  ("包含", IncludeKeyword);
  ("函子", FunctorKeyword);
  ("签名", SigKeyword);
  ("结束", EndKeyword);
  
  (* 宏系统关键字 *)
  ("宏", MacroKeyword);
  ("展开", ExpandKeyword);
  
  (* wenyan风格关键字 *)
  ("吾有", HaveKeyword);
  ("一", OneKeyword);
  ("名曰", NameKeyword);
  ("设", SetKeyword);
  ("也", AlsoKeyword);
  ("乃", ThenGetKeyword);
  ("曰", CallKeyword);
  ("其值", ValueKeyword);
  ("为", AsForKeyword);
  ("数值", IdentifierTokenSpecial "数值");
  ("数", NumberKeyword);
  
  (* wenyan扩展关键字 *)
  ("欲行", WantExecuteKeyword);
  ("必先得", MustFirstGetKeyword);
  ("為是", ForThisKeyword);
  ("遍", TimesKeyword);
  ("云云", EndCloudKeyword);
  ("若", IfWenyanKeyword);
  ("者", ThenWenyanKeyword);
  ("大于", GreaterThanWenyan);
  ("小于", LessThanWenyan);
  ("之", OfParticle);
  
  (* 自然语言函数定义关键字 *)
  ("定义", DefineKeyword);
  ("接受", AcceptKeyword);
  ("时返回", ReturnWhenKeyword);
  ("否则返回", ElseReturnKeyword);
  ("不然返回", ElseReturnKeyword);
  ("乘以", MultiplyKeyword);
  ("加上", AddToKeyword);
  ("减去", SubtractKeyword);
  ("等于", EqualToKeyword);
  ("小于等于", LessThanEqualToKeyword);
  ("首元素", FirstElementKeyword);
  ("剩余", RemainingKeyword);
  ("空", EmptyKeyword);
  ("字符数量", CharacterCountKeyword);
  
  (* 新增自然语言函数定义关键字 *)
  ("输入", InputKeyword);
  ("输出", OutputKeyword);
  ("减一", MinusOneKeyword);
  ("加", PlusKeyword);
  ("其中", WhereKeyword);
  ("小", SmallKeyword);
  
  (* 基本类型关键字 *)
  ("整数", IntTypeKeyword);
  ("浮点数", FloatTypeKeyword);
  ("字符串", StringTypeKeyword);
  ("布尔", BoolTypeKeyword);
  ("单元", UnitTypeKeyword);
  ("列表", ListTypeKeyword);
  ("数组", ArrayTypeKeyword);
  
  (* 古雅体关键字映射 - Ancient Chinese Literary Style *)
  ("夫", AncientDefineKeyword);
  ("者", AncientDefineKeyword);  (* 作为夫...者结构的一部分 *)
  ("是谓", AncientEndKeyword);
  ("算法", AncientAlgorithmKeyword);
  ("竟", AncientCompleteKeyword);
  ("观", AncientObserveKeyword);
  ("性", AncientNatureKeyword);
  ("则", AncientThenKeyword);
  ("余者", AncientOtherwiseKeyword);
  ("答", AncientAnswerKeyword);
  ("合", AncientCombineKeyword);
  ("为一", AncientAsOneKeyword);
  ("取", AncientTakeKeyword);
  ("受", AncientReceiveKeyword);
  ("其", AncientParticleThe);
  ("焉", AncientParticleFun);
  ("名曰", AncientCallItKeyword);
  ("列开始", AncientListStartKeyword);
  ("列结束", AncientListEndKeyword);
  ("其一", AncientItsFirstKeyword);
  ("其二", AncientItsSecondKeyword);
  ("其三", AncientItsThirdKeyword);
  ("空空如也", AncientEmptyKeyword);
  ("有首有尾", AncientHasHeadTailKeyword);
  ("首名为", AncientHeadNameKeyword);
  ("尾名为", AncientTailNameKeyword);
  ("则答", AncientThusAnswerKeyword);
  ("并加", AncientAddToKeyword);
  ("观察毕", AncientObserveEndKeyword);
  ("始", AncientBeginKeyword);
  ("毕", AncientEndCompleteKeyword);
  ("乃", AncientIsKeyword);
  ("故", AncientArrowKeyword);
  ("当", AncientWhenKeyword);
  ("且", AncientCommaKeyword);
  ("而后", AfterThatKeyword);
  ("观毕", AncientObserveEndKeyword);
]

(** 保留词表（优先于关键字处理，避免复合词被错误分割）*)
let reserved_words = [
  (* 基本数据类型相关（不包含基础类型关键字）*)
  "浮点"; "字符"; (* 保留复合词，但不包含基础类型关键字 *)
  
  (* 数学函数和类型转换函数 *)
  "对数"; "自然对数"; "十进制对数"; "平方根"; 
  "正弦"; "余弦"; "正切"; "反正弦"; "反余弦"; "反正切";
  "绝对值"; "幂运算"; "指数"; "取整"; "向上取整"; 
  "向下取整"; "四舍五入"; "最大公约数"; "最小公倍数";
  "字符串到整数"; "字符串到浮点数"; "整数到字符串"; "浮点数到字符串";
  "字符串连接"; "字符串长度"; "字符串分割"; "字符串替换"; "字符串比较";
  "子字符串"; "大写转换"; "小写转换"; "去除空白";
  
  (* 数学函数结果变量名（避免"值"后缀被错误分割）*)
  "平方根值"; "对数值"; "自然对数值"; "十进制对数值"; "指数值";
  "正弦值"; "余弦值"; "正切值"; "反正弦值"; "反余弦值"; "反正切值";
  "绝对值结果"; "幂运算值"; "取整值"; "向上取整值"; 
  "向下取整值"; "四舍五入值"; "最大公约数值"; "最小公倍数值";
  "数组长度值";
  
  (* 复合标识符（避免被关键字分割）*)
  "外部函数"; "内部函数"; "嵌套函数"; "辅助函数"; "主函数"; "深度函数";
  "输入参数"; "输出结果"; "返回值"; "局部变量"; "全局变量"; "空字符串";
  "数据类型"; "结果类型"; "函数类型"; "列表类型"; "数组类型"; "负数"; "大数";
  "去空白"; "去除空白"; "大写转换"; "小写转换";
  
  (* 数-开头的复合标识符 *)
  "数值"; "数字"; "数组"; "数学"; "数量"; "数据"; 
  "数组长度"; "数学模块"; "数字列表"; "数组操作"; "数组访问"; "数组更新";
  "数学函数"; "数字字面量"; "数组字面量"; "数组索引"; "数组元素";
  "数字变量"; "数组变量"; "数学计算"; "数值计算"; "数组函数";
  
  (* 包含"一"的常用标识符 *)
  "第一个"; "第一"; "统一"; "唯一"; "第一次"; "第一行"; "第一列"; "第一元素";
  "一致性"; "一样"; "一般"; "一起"; "一下"; "一些"; "一种"; "一个"; "任意一个";
  "最后一个"; "最后一次"; "最后一行"; "最后一列"; "下一个"; "上一个"; "另一个";
  "第二个"; "第三个"; "第四个"; "第五个"; "每一个"; "这一个"; "那一个";
  
  (* 古雅体复合词汇 - Ancient Chinese Literary Compounds *)
  "空空如也"; "有首有尾"; "首名为"; "尾名为"; "则答"; "并加"; "观察毕";
  "列开始"; "列结束"; "其一"; "其二"; "其三"; "余者"; "为一";
  "算法竟"; "是谓"; "夫者"; "古雅体"; "当时";
  
  (* 包含"数"的常用变量名 *)
  "数组1"; "数组2"; "数组3"; "数组4"; "数组5"; "数组6"; "数组7"; "数组8"; "数组9";
  "数字1"; "数字2"; "数字3"; "数字4"; "数字5"; "数字6"; "数字7"; "数字8"; "数字9";
  "数据1"; "数据2"; "数据3"; "数据4"; "数据5"; "数量1"; "数量2"; "数量3";
  
  (* 包含数字的常用变量名 *)
  "创建5"; "创建3"; "创建10"; "长度5"; "长度3"; "长度10"; "大小5"; "大小3"; "大小10";
  "副本1"; "副本2"; "副本3"; "结果1"; "结果2"; "结果3"; "值1"; "值2"; "值3";
  
  (* 其他包含"数"的复合标识符 *)
  "原数组"; "新数组"; "临时数组"; "空数组"; "整数组"; "字符数组"; "布尔数组";
  "副本"; "复制数组"; "原数据"; "新数据"; "临时数据";
  
  (* 构造器相关复合标识符 *)
  "带参数构造器"; "无参数构造器"; "构造器值"; "构造器表达式"; "构造器函数";
  "带参数"; "无参数"; "参数列表"; "参数值"; "参数类型"; "构造器模式";
  
  (* 模块类型相关复合标识符 *)
  "模块类型1"; "模块类型2"; "模块类型3"; "签名类型"; "类型签名"; "模块签名";
  "抽象类型"; "具体类型"; "类型定义"; "类型别名"; "类型参数";
  "数据接口"; "基础接口"; "扩展接口"; "安全接口"; "集合接口"; "操作接口";
  "数据类型"; "接口类型"; "模块接口"; "类型接口"; "函数接口";
  
  (* wenyan语法相关复合标识符 *)
  "数值"; "数字"; "字符串值"; "布尔值"; "整数值"; "浮点数值";
  "变量值"; "函数值"; "列表值"; "数组值"; "记录值"; "元组值";
  
  (* 自然语言函数定义相关复合标识符 *)
  "输入参数"; "输入值"; "输入数据"; "输入变量"; "输入列表"; "输入数组";
  "输出结果"; "输出值"; "输出数据"; "输出变量"; "输出列表"; "输出数组";
  "减一操作"; "减一结果"; "加法操作"; "加法结果";
  "其中包含"; "其中定义"; "其中计算"; "其中处理";
  "小于判断"; "小于比较"; "小于操作";
  
  (* 测试和函数相关复合标识符 *)
  "测试数字"; "测试函数"; "测试变量"; "测试数据"; "测试结果"; "测试用例";
  "测试方法"; "测试对象"; "测试模块"; "测试类型"; "测试代码"; "测试程序";
  
  (* 异常处理相关复合标识符 *)
  "匹配失败"; "处理错误"; "抛出异常"; "捕获异常"; "异常处理"; "错误处理";
  
  (* 面向对象相关复合标识符（包含关键字的方法名等）*)
  "介绍自己"; "展示自己"; "描述自己"; "表达自己"; "定义自己"; "修改自己"; "更新自己";
  "获取自己"; "设置自己"; "创建自己"; "销毁自己"; "初始化自己"; "重置自己"; "复制自己";
  "比较自己"; "克隆自己"; "保存自己"; "加载自己"; "验证自己"; "检查自己"; "测试自己"
]

(** 检查是否为保留词 *)
let is_reserved_word str = List.mem str reserved_words

(** 查找关键字 *)
let find_keyword str =
  try Some (List.assoc str keyword_table)
  with Not_found -> None


(** 是否为中文字符 *)
let is_chinese_char c =
  let code = Char.code c in
  (* CJK Unified Ideographs range: U+4E00-U+9FFF *)
  (* But for UTF-8 bytes, we need to check differently *)
  code >= 0xE4 || (code >= 0xE5 && code <= 0xE9)

(** 是否为字母或中文 *)
let is_letter_or_chinese c =
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || is_chinese_char c

(** 是否为数字 *)
let is_digit c = c >= '0' && c <= '9'

(** 是否为全宽数字 *)
let is_fullwidth_digit_utf8 s =
  if String.length s = 3 then
    (* 全宽数字的UTF-8编码：０(EF BC 90) 到 ９(EF BC 99) *)
    let byte1 = Char.code s.[0] in
    let byte2 = Char.code s.[1] in  
    let byte3 = Char.code s.[2] in
    byte1 = 0xEF && byte2 = 0xBC && byte3 >= 0x90 && byte3 <= 0x99
  else
    false

(** 将全宽数字转换为ASCII数字 *)
let fullwidth_digit_to_ascii s =
  if is_fullwidth_digit_utf8 s then
    let byte3 = Char.code s.[2] in
    String.make 1 (Char.chr (byte3 - 0x90 + Char.code '0'))
  else
    s


(** 是否为空白字符 - 空格仍需跳过，但不用于关键字消歧 *)
let is_whitespace c = c = ' ' || c = '\t' || c = '\r'

(** 是否为分隔符字符 - 用于关键字边界检查（不包括空格） *)
let is_separator_char c = c = '\t' || c = '\r' || c = '\n'

(** 词法分析器状态 *)
type lexer_state = {
  input: string;
  length: int;
  position: int;
  current_line: int;
  current_column: int;
  filename: string;
}

(** 创建词法状态 *)
let create_lexer_state input filename = {
  input;
  length = String.length input;
  position = 0;
  current_line = 1;
  current_column = 1;
  filename;
}

(** 尝试从当前位置匹配最长的关键字 *)
let try_match_keyword state =
  let rec try_keywords keywords best_match =
    match keywords with
    | [] -> best_match
    | (keyword, token) :: rest ->
      let keyword_len = String.length keyword in
      if state.position + keyword_len <= state.length then
        let substring = String.sub state.input state.position keyword_len in
        if substring = keyword then
          (* 检查关键字边界 *)
          let next_pos = state.position + keyword_len in
          let is_complete_word = 
            if next_pos >= state.length then true (* 文件结尾 *)
            else
              let next_char = state.input.[next_pos] in
              (* 对于中文关键字，检查边界 *)
              if String.for_all (fun c -> Char.code c >= 128) keyword then
                (* 中文关键字：检查下一个字符是否可能形成更长的关键字 *)
                (* 简单方法：如果下一个字符也是中文字符，检查是否有更长的匹配 *)
                let next_is_chinese = Char.code next_char >= 128 in
                if next_is_chinese then
                  (* 检查是否为引用标识符的引号，如果是则认为关键字完整 *)
                  let is_quote_punctuation = 
                    (Char.code next_char = 0xE3 && 
                     next_pos + 2 < state.length &&
                     Char.code state.input.[next_pos + 1] = 0x80 &&
                     (Char.code state.input.[next_pos + 2] = 0x8C || (* 「 *)
                      Char.code state.input.[next_pos + 2] = 0x8D || (* 」 *)
                      Char.code state.input.[next_pos + 2] = 0x8E || (* 『 *)
                      Char.code state.input.[next_pos + 2] = 0x8F))   (* 』 *)
                  in
                  if is_quote_punctuation then
                    true (* 引号字符，关键字完整 *)
                  else
                    (* 检查是否存在实际匹配输入的更长关键字 *)
                    let has_actual_longer_match = List.exists (fun (kw, _) -> 
                      String.length kw > keyword_len && 
                      String.sub kw 0 keyword_len = keyword &&
                      state.position + String.length kw <= state.length &&
                      String.sub state.input state.position (String.length kw) = kw
                    ) keyword_table in
                    not has_actual_longer_match
                else
                  true (* 下一个字符不是中文，当前关键字完整 *)
              else
                (* 英文关键字：检查边界，中文字符被视为有效边界 *)
                let next_is_chinese = Char.code next_char >= 128 in
                if next_is_chinese then
                  true (* 中文字符是英文关键字的有效边界 *)
                else
                  is_separator_char next_char || not (is_letter_or_chinese next_char || is_digit next_char)
          in
          if is_complete_word then
            match best_match with
            | None -> try_keywords rest (Some (keyword, token, keyword_len))
            | Some (_, _, best_len) when keyword_len > best_len ->
              try_keywords rest (Some (keyword, token, keyword_len))
            | Some _ -> try_keywords rest best_match
          else
            try_keywords rest best_match
        else
          try_keywords rest best_match
      else
        try_keywords rest best_match
  in
  try_keywords keyword_table None

(** 获取当前字符 *)
let current_char state =
  if state.position >= state.length then None
  else Some state.input.[state.position]

(** 向前移动 *)
let advance state =
  if state.position >= state.length then state
  else
    let c = state.input.[state.position] in
    if c = '\n' then
      { state with position = state.position + 1; current_line = state.current_line + 1; current_column = 1 }
    else
      { state with position = state.position + 1; current_column = state.current_column + 1 }

(** 跳过单个注释 *)
let skip_comment state =
  let rec skip_until_close state depth =
    match current_char state with
    | None -> raise (LexError ("Unterminated comment", { line = state.current_line; column = state.current_column; filename = state.filename }))
    | Some '(' ->
      let state1 = advance state in
      (match current_char state1 with
       | Some '*' -> skip_until_close (advance state1) (depth + 1)
       | _ -> skip_until_close state1 depth)
    | Some '*' ->
      let state1 = advance state in
      (match current_char state1 with
       | Some ')' -> 
         if depth = 1 then advance state1 
         else skip_until_close (advance state1) (depth - 1)
       | _ -> skip_until_close state1 depth)
    | Some _ -> skip_until_close (advance state) depth
  in
  skip_until_close state 1

(** 检查UTF-8字符匹配 *)
let check_utf8_char state _byte1 byte2 byte3 =
  state.position + 2 < state.length &&
  Char.code state.input.[state.position + 1] = byte2 &&
  Char.code state.input.[state.position + 2] = byte3

(** 跳过中文注释 「：注释内容：」 *)
let skip_chinese_comment state =
  let rec skip_until_close state =
    match current_char state with
    | None -> raise (LexError ("Unterminated Chinese comment", { line = state.current_line; column = state.current_column; filename = state.filename }))
    | Some c when Char.code c = 0xEF ->
      if check_utf8_char state 0xEF 0xBC 0x9A then
        (* 找到 ： *)
        let state1 = { state with position = state.position + 3; current_column = state.current_column + 1 } in
        (match current_char state1 with
         | Some c when Char.code c = 0xE3 ->
           if check_utf8_char state1 0xE3 0x80 0x8D then
             (* 找到 ：」 组合，注释结束 *)
             { state1 with position = state1.position + 3; current_column = state1.current_column + 1 }
           else
             skip_until_close state1
         | _ -> skip_until_close state1)
      else
        skip_until_close (advance state)
    | Some _ -> skip_until_close (advance state)
  in
  skip_until_close state

(** 跳过空白字符和注释 *)
let rec skip_whitespace_and_comments state =
  match current_char state with
  | Some c when is_whitespace c -> skip_whitespace_and_comments (advance state)
  | Some '(' ->
    let state1 = advance state in
    (match current_char state1 with
     | Some '*' -> skip_whitespace_and_comments (skip_comment (advance state1))
     | _ -> state)  (* 不是注释，返回原状态 *)
  | Some c when Char.code c = 0xE3 ->
    (* 检查中文注释 「： *)
    if check_utf8_char state 0xE3 0x80 0x8C then
      (* 找到 「 *)
      let state1 = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      (match current_char state1 with
       | Some c when Char.code c = 0xEF ->
         if check_utf8_char state1 0xEF 0xBC 0x9A then
           (* 找到 「： 组合，开始中文注释 *)
           let state2 = { state1 with position = state1.position + 3; current_column = state1.current_column + 1 } in
           skip_whitespace_and_comments (skip_chinese_comment state2)
         else
           state  (* 不是中文注释，返回原状态 *)
       | _ -> state)  (* 不是中文注释，返回原状态 *)
    else
      state
  | _ -> state


(* 判断一个UTF-8字符串是否为中文字符（CJK Unified Ideographs） *)
let is_chinese_utf8 s =
  match Uutf.decode (Uutf.decoder (`String s)) with
  | `Uchar u ->
      let code = Uchar.to_int u in
      code >= 0x4E00 && code <= 0x9FFF
  | _ -> false

(* 读取下一个UTF-8字符，返回字符和新位置 *)
let next_utf8_char input pos =
  let dec = Uutf.decoder (`String (String.sub input pos (String.length input - pos))) in
  match Uutf.decode dec with
  | `Uchar u ->
      let buf = Buffer.create 8 in
      Uutf.Buffer.add_utf_8 buf u;
      let s = Buffer.contents buf in
      let len = Bytes.length (Bytes.of_string s) in
      (s, pos + len)
  | _ -> ("", pos)



(* 中文数字映射 *)
let chinese_numbers = [
  ("零", 0); ("一", 1); ("二", 2); ("三", 3); ("四", 4);
  ("五", 5); ("六", 6); ("七", 7); ("八", 8); ("九", 9); ("十", 10);
  ("百", 100); ("千", 1000); ("万", 10000)
]

(* 检查是否为中文数字 *)
let is_chinese_number identifier =
  try
    let number = List.assoc identifier chinese_numbers in
    Some number
  with Not_found -> None

(* 简化的标识符读取：在关键字边界处停止 *)
let read_identifier_utf8 state =
  let rec loop pos acc =
    if pos >= state.length then (acc, pos)
    else
      let (ch, next_pos) = next_utf8_char state.input pos in
      if ch = "" then (acc, pos)
      else if
        (String.length ch = 1 && is_letter_or_chinese ch.[0]) || is_chinese_utf8 ch || (String.length ch = 1 && is_digit ch.[0]) || ch = "_"
      then 
        (* 如果已经有累积字符，检查当前字符是否为关键字的开始 *)
        if acc <> "" && Char.code ch.[0] >= 128 then
          (* 首先检查当前累积的字符是否已经是一个中文数字 *)
          (match is_chinese_number acc with
           | Some _ -> 
             (* 当前累积的已经是一个中文数字，应该停止读取 *)
             (acc, pos)
           | None ->
             (* 不是中文数字，检查从当前位置是否开始一个关键字 *)
             let temp_state = { state with position = pos; current_column = state.current_column + (pos - state.position) } in
             (match try_match_keyword temp_state with
              | Some (_keyword, _token, _len) -> 
                (* 找到关键字匹配，在关键字边界停止 *)
                (acc, pos)
              | None -> 
                (* 没有关键字匹配，继续读取 *)
                loop next_pos (acc ^ ch)))
        else
          (* 英文或第一个字符，直接继续 *)
          loop next_pos (acc ^ ch)
      else (acc, pos)
  in
  let (id, new_pos) = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  (id, { state with position = new_pos; current_column = new_col })

(** 读取引用标识符 *)
let read_quoted_identifier state =
  let rec loop pos acc =
    if pos >= state.length then
      raise (LexError ("未闭合的引用标识符", { line = state.current_line; column = state.current_column; filename = state.filename }))
    else
      let (ch, next_pos) = next_utf8_char state.input pos in
      if ch = "」" then
        (acc, next_pos) (* 找到结束引号，返回内容和新位置 *)
      else if ch = "" then
        raise (LexError ("引用标识符中的无效字符", { line = state.current_line; column = state.current_column; filename = state.filename }))
      else
        loop next_pos (acc ^ ch) (* 继续累积字符 *)
  in
  let (identifier, new_pos) = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  (QuotedIdentifierToken identifier, { state with position = new_pos; current_column = new_col })


(** 读取全宽数字（支持整数和浮点数） *)
let read_fullwidth_number state =
  let rec loop pos acc has_dot =
    if pos >= state.length then (acc, pos, has_dot)
    else
      let (ch, next_pos) = next_utf8_char state.input pos in
      if is_fullwidth_digit_utf8 ch then
        let ascii_digit = fullwidth_digit_to_ascii ch in
        loop next_pos (acc ^ ascii_digit) has_dot
      else if String.length ch = 3 && 
              Char.code ch.[0] = 0xEF && 
              Char.code ch.[1] = 0xBC && 
              Char.code ch.[2] = 0x8E && 
              not has_dot then
        (* 全宽句号 ． 且之前没有遇到过 *)
        loop next_pos (acc ^ ".") true
      else
        (acc, pos, has_dot)
  in
  let (number_str, new_pos, has_dot) = loop state.position "" false in
  let new_col = state.current_column + (new_pos - state.position) / 3 in (* 每个全宽字符占3字节 *)
  let new_state = { state with position = new_pos; current_column = new_col } in
  if number_str = "" then
    raise (LexError ("Invalid fullwidth number", { line = state.current_line; column = state.current_column; filename = state.filename }))
  else if has_dot then
    (FloatToken (float_of_string number_str), new_state)
  else
    (IntToken (int_of_string number_str), new_state)

(** 读取字符串字面量 *)
let read_string_literal state =
  let rec read state acc =
    match current_char state with
    | Some c when Char.code c = 0xE3 && 
      check_utf8_char state 0xE3 0x80 0x8F ->
      (* 』 (U+300F) - 结束字符串字面量 *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      (acc, new_state)
    | Some '\\' ->
      let state1 = advance state in
      (match current_char state1 with
       | Some 'n' -> read (advance state1) (acc ^ "\n")
       | Some 't' -> read (advance state1) (acc ^ "\t")
       | Some 'r' -> read (advance state1) (acc ^ "\r")
       | Some '"' -> read (advance state1) (acc ^ "\"")
       | Some '\\' -> read (advance state1) (acc ^ "\\")
       | Some c -> read (advance state1) (acc ^ String.make 1 c)
       | None -> raise (LexError ("Unterminated string", { line = state.current_line; column = state.current_column; filename = state.filename })))
    | Some c -> read (advance state) (acc ^ String.make 1 c)
    | None -> raise (LexError ("Unterminated string", { line = state.current_line; column = state.current_column; filename = state.filename }))
  in
  let (content, new_state) = read state "" in
  (StringToken content, new_state)



(** 识别中文标点符号 *)
let recognize_chinese_punctuation state pos =
  match current_char state with
  | Some c when Char.code c = 0xEF ->
    (* 全角符号范围 *)
    if check_utf8_char state 0xEF 0xBC 0x88 then
      (* （ (U+FF08) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChineseLeftParen, pos, new_state)
    else if check_utf8_char state 0xEF 0xBC 0x89 then
      (* ） (U+FF09) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChineseRightParen, pos, new_state)
    else if check_utf8_char state 0xEF 0xBC 0x8C then
      (* ， (U+FF0C) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChineseComma, pos, new_state)
    else if check_utf8_char state 0xEF 0xBC 0x9B then
      (* ； (U+FF1B) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChineseSemicolon, pos, new_state)
    else if check_utf8_char state 0xEF 0xBC 0x9A then
      (* ： (U+FF1A) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChineseColon, pos, new_state)
    else if check_utf8_char state 0xEF 0xBD 0x9C then
      (* ｜ (U+FF5C) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChinesePipe, pos, new_state)
    else
      None
  | Some c when Char.code c = 0xE3 ->
    (* 中文标点符号范围 *)
    if check_utf8_char state 0xE3 0x80 0x90 then
      (* 【 (U+3010) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChineseLeftBracket, pos, new_state)
    else if check_utf8_char state 0xE3 0x80 0x91 then
      (* 】 (U+3011) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChineseRightBracket, pos, new_state)
    else if check_utf8_char state 0xE3 0x80 0x8E then
      (* 『 (U+300E) - 现在用作字符串字面量开始，在主函数中处理 *)
      None
    else if check_utf8_char state 0xE3 0x80 0x8F then
      (* 』 (U+300F) - 现在用作字符串字面量结束，在主函数中处理 *)
      None
    else if check_utf8_char state 0xE3 0x80 0x82 then
      (* 。 (U+3002) - 中文句号，用作访问运算符 *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (Dot, pos, new_state)
    (* Note: 「」 (U+300C/U+300D) are reserved for quoted identifiers *)
    else
      None
  | Some c when Char.code c = 0xE2 ->
    (* 箭头符号范围 *)
    if check_utf8_char state 0xE2 0x86 0x92 then
      (* → (U+2192) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChineseArrow, pos, new_state)
    else if check_utf8_char state 0xE2 0x87 0x92 then
      (* ⇒ (U+21D2) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChineseDoubleArrow, pos, new_state)
    else if check_utf8_char state 0xE2 0x86 0x90 then
      (* ← (U+2190) *)
      let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
      Some (ChineseAssignArrow, pos, new_state)
    else
      None
  | _ -> None

(** 识别｜」组合 (数组结束符) *)
let recognize_pipe_right_bracket state pos =
  match current_char state with
  | Some c when Char.code c = 0xEF &&
    check_utf8_char state 0xEF 0xBD 0x9C ->
    (* ｜ *)
    let state1 = { state with position = state.position + 3; current_column = state.current_column + 1 } in
    if state1.position + 2 < state1.length &&
       Char.code state1.input.[state1.position] = 0xE3 &&
       check_utf8_char state1 0xE3 0x80 0x8D then
      (* ｜」 *)
      let final_state = { state1 with position = state1.position + 3; current_column = state1.current_column + 1 } in
      Some (ChineseRightArray, pos, final_state)
    else
      None
  | _ -> None

(** 获取下一个词元 *)
let next_token state =
  let state = skip_whitespace_and_comments state in
  let pos = { line = state.current_line; column = state.current_column; filename = state.filename } in
  
  match current_char state with
  | None -> (EOF, pos, state)
  | Some '\n' -> (Newline, pos, advance state)
  | _ ->
    (* 首先尝试识别中文标点符号 *)
    (match recognize_chinese_punctuation state pos with
     | Some result -> result
     | None ->
       (* 尝试识别｜」组合 *)
       (match recognize_pipe_right_bracket state pos with
        | Some result -> result
        | None ->
          (* ASCII符号现在被禁止使用 - 抛出错误 *)
          match current_char state with
          | None -> (EOF, pos, state)  (* 这种情况应该已经在最外层处理了，但为了完整性保留 *)
          | Some (('+' | '-' | '*' | '/' | '%' | '^' | '=' | '<' | '>' | '.' | '(' | ')' | '[' | ']' | '{' | '}' | ',' | ';' | ':' | '!' | '|' | '_' | '"') as c) ->
            (* 所有ASCII符号都被禁止，请使用中文标点符号 *)
            raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: " ^ String.make 1 c, pos))
          | Some c when Char.code c = 0xE3 && 
            check_utf8_char state 0xE3 0x80 0x8C ->
            (* 「 (U+300C) - 检查是否为数组开始 「| *)
            let skip_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            (match current_char skip_state with
             | Some '|' -> 
               (* 「| - 中文数组开始 *)
               let final_state = { skip_state with position = skip_state.position + 1; current_column = skip_state.current_column + 1 } in
               (ChineseLeftArray, pos, final_state)
             | _ ->
               (* 「 - 开始引用标识符 *)
               let (token, new_state) = read_quoted_identifier skip_state in
               (token, pos, new_state))
          | Some c when Char.code c = 0xE3 && 
            check_utf8_char state 0xE3 0x80 0x8E ->
            (* 『 (U+300E) - 开始字符串字面量 *)
            let skip_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            let (token, new_state) = read_string_literal skip_state in
            (token, pos, new_state)
          | Some c when is_digit c ->
            (* ASCII数字已禁用，请使用全宽数字 ０１２３４５６７８９ *)
            raise (LexError ("ASCII数字已禁用，请使用全宽数字。禁用字符: " ^ String.make 1 c, pos))
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            Char.code state.input.[state.position + 2] >= 0x90 && 
            Char.code state.input.[state.position + 2] <= 0x99 ->
            (* 全宽数字 ０-９ *)
            let (token, new_state) = read_fullwidth_number state in
            (token, pos, new_state)
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            Char.code state.input.[state.position + 2] = 0x8B ->
            (* 全宽加号 ＋ *)
            let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            (Plus, pos, new_state)
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            Char.code state.input.[state.position + 2] = 0x8D ->
            (* 全宽减号 － *)
            let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            (Minus, pos, new_state)
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            Char.code state.input.[state.position + 2] = 0x8A ->
            (* 全宽乘号 ＊ *)
            let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            (Multiply, pos, new_state)
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            Char.code state.input.[state.position + 2] = 0x8F ->
            (* 全宽除号 ／ *)
            let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            (Divide, pos, new_state)
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            Char.code state.input.[state.position + 2] = 0x9D ->
            (* 全宽等号 ＝，检查是否是 ＝＝ *)
            let new_state_temp = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            if new_state_temp.position + 2 < new_state_temp.length &&
               Char.code new_state_temp.input.[new_state_temp.position] = 0xEF &&
               Char.code new_state_temp.input.[new_state_temp.position + 1] = 0xBC &&
               Char.code new_state_temp.input.[new_state_temp.position + 2] = 0x9D then
              (* 找到 ＝＝ *)
              let new_state = { new_state_temp with position = new_state_temp.position + 3; current_column = new_state_temp.current_column + 1 } in
              (Equal, pos, new_state)
            else
              (* 只是 ＝ *)
              (Assign, pos, new_state_temp)
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            Char.code state.input.[state.position + 2] = 0x85 ->
            (* 全宽百分号 ％ *)
            let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            (Modulo, pos, new_state)
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            Char.code state.input.[state.position + 2] = 0x9C ->
            (* 全宽小于号 ＜，检查是否是 ＜＝ 或 ＜＞ *)
            let new_state_temp = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            if new_state_temp.position + 2 < new_state_temp.length &&
               Char.code new_state_temp.input.[new_state_temp.position] = 0xEF &&
               Char.code new_state_temp.input.[new_state_temp.position + 1] = 0xBC &&
               Char.code new_state_temp.input.[new_state_temp.position + 2] = 0x9D then
              (* 找到 ＜＝ *)
              let new_state = { new_state_temp with position = new_state_temp.position + 3; current_column = new_state_temp.current_column + 1 } in
              (LessEqual, pos, new_state)
            else if new_state_temp.position + 2 < new_state_temp.length &&
               Char.code new_state_temp.input.[new_state_temp.position] = 0xEF &&
               Char.code new_state_temp.input.[new_state_temp.position + 1] = 0xBC &&
               Char.code new_state_temp.input.[new_state_temp.position + 2] = 0x9E then
              (* 找到 ＜＞ *)
              let new_state = { new_state_temp with position = new_state_temp.position + 3; current_column = new_state_temp.current_column + 1 } in
              (NotEqual, pos, new_state)
            else
              (* 只是 ＜ *)
              (Less, pos, new_state_temp)
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            Char.code state.input.[state.position + 2] = 0x9E ->
            (* 全宽大于号 ＞，检查是否是 ＞＝ *)
            let new_state_temp = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            if new_state_temp.position + 2 < new_state_temp.length &&
               Char.code new_state_temp.input.[new_state_temp.position] = 0xEF &&
               Char.code new_state_temp.input.[new_state_temp.position + 1] = 0xBC &&
               Char.code new_state_temp.input.[new_state_temp.position + 2] = 0x9D then
              (* 找到 ＞＝ *)
              let new_state = { new_state_temp with position = new_state_temp.position + 3; current_column = new_state_temp.current_column + 1 } in
              (GreaterEqual, pos, new_state)
            else
              (* 只是 ＞ *)
              (Greater, pos, new_state_temp)
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            Char.code state.input.[state.position + 2] = 0x8E ->
            (* 全宽句号 ． *)
            let new_state = { state with position = state.position + 3; current_column = state.current_column + 1 } in
            (Dot, pos, new_state)
          | Some c when Char.code c = 0xEF && 
            state.position + 2 < state.length &&
            state.input.[state.position + 1] = '\xBC' &&
            not (Char.code state.input.[state.position + 2] >= 0x90 && 
                 Char.code state.input.[state.position + 2] <= 0x99) &&
            not (Char.code state.input.[state.position + 2] = 0x8E) ->
            (* 未处理的全宽字符 (不包括数字和句号) - 抛出错误以避免无限循环 *)
            raise (LexError ("Unsupported fullwidth character", pos))
          | Some c when is_letter_or_chinese c ->
            (* 检查是否为ASCII字母 *)
            let is_ascii_letter = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') in
            if is_ascii_letter then
              (* ASCII字母只允许作为关键字使用 *)
              (match try_match_keyword state with
               | Some (_keyword, token, keyword_len) ->
                 (* 找到关键字匹配，使用关键字 *)
                 let new_state = { state with position = state.position + keyword_len; 
                                              current_column = state.current_column + keyword_len } in
                 let final_token = match token with
                   | TrueKeyword -> BoolToken true
                   | FalseKeyword -> BoolToken false
                   | IdentifierTokenSpecial name -> 
                     (* 特殊标识符如"数值"在wenyan语法中允许直接使用 *)
                     IdentifierToken name
                   | _ -> token
                 in
                 (final_token, pos, new_state)
               | None ->
                 (* ASCII字母不是关键字，禁止使用 *)
                 raise (LexError ("ASCII字母已禁用，只允许作为关键字使用。禁用字符: " ^ String.make 1 c, pos)))
            else
              (* 中文字符，允许作为关键字或标识符 *)
              (match try_match_keyword state with
               | Some (_keyword, token, keyword_len) ->
                 (* 找到关键字匹配，使用关键字 *)
                 let new_state = { state with position = state.position + keyword_len; 
                                              current_column = state.current_column + keyword_len } in
                 let final_token = match token with
                   | TrueKeyword -> BoolToken true
                   | FalseKeyword -> BoolToken false
                   | IdentifierTokenSpecial name -> 
                     (* 特殊标识符如"数值"在wenyan语法中允许直接使用 *)
                     IdentifierToken name
                   | _ -> token
                 in
                 (final_token, pos, new_state)
               | None ->
                 (* 没有关键字匹配，解析为普通标识符 *)
                 let (identifier, new_state) = read_identifier_utf8 state in
                 (* 检查是否为中文数字 *)
                 let token = match is_chinese_number identifier with
                   | Some number -> IntToken number
                   | None -> IdentifierToken identifier
                 in
                 (token, pos, new_state))
          | Some c -> 
            raise (LexError ("Unknown character: " ^ String.make 1 c, pos))))

(** 词法分析主函数 *)
let tokenize input filename =
  let rec analyze state acc =
    let (token, pos, new_state) = next_token state in
    let positioned_token = (token, pos) in
    match token with
    | EOF -> List.rev (positioned_token :: acc)
    | Newline -> analyze new_state (positioned_token :: acc)  (* 包含换行符作为语句分隔符 *)
    | _ -> analyze new_state (positioned_token :: acc)
  in
  let initial_state = create_lexer_state input filename in
  analyze initial_state []