(** 统一Token注册系统 - 管理token映射和转换 *)

open Unified_token_core

type mapping_entry = {
  source : string;  (** 源字符串 *)
  target : unified_token;  (** 目标token *)
  priority : token_priority;  (** 优先级 *)
  context : string option;  (** 上下文信息 *)
  enabled : bool;  (** 是否启用 *)
}
(** 映射条目类型 *)

(** Token注册表 - 使用Hashtbl实现快速查找 *)
module TokenRegistry = struct
  (** 映射表：字符串 -> 映射条目列表 *)
  let mapping_table : (string, mapping_entry list) Hashtbl.t = Hashtbl.create 256

  (** 反向映射表：token -> 字符串列表 *)
  let reverse_table : (unified_token, string list) Hashtbl.t = Hashtbl.create 256

  (** 注册单个映射 *)
  let register_mapping entry =
    let { source; target; _ } = entry in
    (* 添加到正向映射表 *)
    let existing_entries = try Hashtbl.find mapping_table source with Not_found -> [] in
    let updated_entries = entry :: existing_entries in
    Hashtbl.replace mapping_table source updated_entries;

    (* 添加到反向映射表 *)
    let existing_sources = try Hashtbl.find reverse_table target with Not_found -> [] in
    let updated_sources = source :: existing_sources in
    Hashtbl.replace reverse_table target updated_sources

  (** 批量注册映射 *)
  let register_batch entries = List.iter register_mapping entries

  (** 查找映射 - 支持优先级排序 *)
  let find_mapping source =
    try
      let entries = Hashtbl.find mapping_table source in
      let enabled_entries = List.filter (fun e -> e.enabled) entries in
      let sorted_entries =
        List.sort
          (fun e1 e2 ->
            match (e1.priority, e2.priority) with
            | HighPriority, MediumPriority | HighPriority, LowPriority -> -1
            | MediumPriority, HighPriority | LowPriority, HighPriority -> 1
            | MediumPriority, LowPriority -> -1
            | LowPriority, MediumPriority -> 1
            | _ -> 0)
          enabled_entries
      in
      match sorted_entries with [] -> None | entry :: _ -> Some entry
    with Not_found -> None

  (** 查找所有映射 *)
  let find_all_mappings source = try Hashtbl.find mapping_table source with Not_found -> []

  (** 反向查找 *)
  let reverse_lookup token = try Hashtbl.find reverse_table token with Not_found -> []

  (** 检查映射冲突 *)
  let check_conflicts () =
    let conflicts = ref [] in
    Hashtbl.iter
      (fun source entries ->
        let enabled_entries = List.filter (fun e -> e.enabled) entries in
        if List.length enabled_entries > 1 then
          let high_priority = List.filter (fun e -> e.priority = HighPriority) enabled_entries in
          if List.length high_priority > 1 then conflicts := (source, enabled_entries) :: !conflicts)
      mapping_table;
    !conflicts

  (** 获取统计信息 *)
  let get_stats () =
    let total_mappings = Hashtbl.length mapping_table in
    let total_tokens = Hashtbl.length reverse_table in
    let enabled_count = ref 0 in
    let disabled_count = ref 0 in
    Hashtbl.iter
      (fun _ entries ->
        List.iter
          (fun entry -> if entry.enabled then incr enabled_count else incr disabled_count)
          entries)
      mapping_table;
    (total_mappings, total_tokens, !enabled_count, !disabled_count)

  (** 清空注册表 *)
  let clear () =
    Hashtbl.clear mapping_table;
    Hashtbl.clear reverse_table
end

(** 映射DSL - 提供便捷的映射定义语法 *)
module MappingDSL = struct
  (** 创建映射条目 *)
  let make_mapping source target ?(priority = MediumPriority) ?(context = None) ?(enabled = true) ()
      =
    { source; target; priority; context; enabled }

  (** 高优先级映射 *)
  let high_priority source target = make_mapping source target ~priority:HighPriority ()

  (** 中优先级映射 *)
  let medium_priority source target = make_mapping source target ~priority:MediumPriority ()

  (** 低优先级映射 *)
  let low_priority source target = make_mapping source target ~priority:LowPriority ()

  (** 带上下文的映射 *)
  let with_context source target context = make_mapping source target ~context:(Some context) ()

  (** 禁用的映射 *)
  let disabled source target = make_mapping source target ~enabled:false ()
end

(** 预定义映射注册器 *)
module PredefinedMappings = struct
  open MappingDSL

  (** 注册基础关键字映射 *)
  let register_basic_keywords () =
    let mappings =
      [
        (* 中文关键字映射 *)
        high_priority "让" LetKeyword;
        high_priority "设" LetKeyword;
        high_priority "函数" FunKeyword;
        high_priority "如果" IfKeyword;
        high_priority "那么" ThenKeyword;
        high_priority "否则" ElseKeyword;
        high_priority "匹配" MatchKeyword;
        high_priority "与" WithKeyword;
        high_priority "当" WhenKeyword;
        high_priority "且" AndKeyword;
        high_priority "或" OrKeyword;
        high_priority "非" NotKeyword;
        high_priority "真" TrueKeyword;
        high_priority "假" FalseKeyword;
        high_priority "在" InKeyword;
        high_priority "递归" RecKeyword;
        high_priority "可变" MutableKeyword;
        high_priority "引用" RefKeyword;
        high_priority "开始" BeginKeyword;
        high_priority "结束" EndKeyword;
        high_priority "循环" ForKeyword;
        high_priority "当循环" WhileKeyword;
        high_priority "做" DoKeyword;
        high_priority "完成" DoneKeyword;
        high_priority "到" ToKeyword;
        high_priority "向下到" DowntoKeyword;
        high_priority "跳出" BreakKeyword;
        high_priority "继续" ContinueKeyword;
        high_priority "返回" ReturnKeyword;
        high_priority "尝试" TryKeyword;
        high_priority "抛出" RaiseKeyword;
        high_priority "失败" FailwithKeyword;
        high_priority "断言" AssertKeyword;
        high_priority "延迟" LazyKeyword;
        high_priority "异常" ExceptionKeyword;
        high_priority "模块" ModuleKeyword;
        high_priority "结构" StructKeyword;
        high_priority "签名" SigKeyword;
        high_priority "函子" FunctorKeyword;
        high_priority "包含" IncludeKeyword;
        high_priority "打开" OpenKeyword;
        high_priority "类型" TypeKeyword;
        high_priority "值" ValKeyword;
        high_priority "外部" ExternalKeyword;
        high_priority "私有" PrivateKeyword;
        high_priority "虚拟" VirtualKeyword;
        high_priority "方法" MethodKeyword;
        high_priority "继承" InheritKeyword;
        high_priority "初始化器" InitializerKeyword;
        high_priority "新建" NewKeyword;
        high_priority "对象" ObjectKeyword;
        high_priority "类" ClassKeyword;
        high_priority "约束" ConstraintKeyword;
        high_priority "作为" AsKeyword;
        high_priority "属于" OfKeyword;
        (* 英文关键字映射 *)
        high_priority "let" LetKeyword;
        high_priority "fun" FunKeyword;
        high_priority "function" FunKeyword;
        high_priority "if" IfKeyword;
        high_priority "then" ThenKeyword;
        high_priority "else" ElseKeyword;
        high_priority "match" MatchKeyword;
        high_priority "with" WithKeyword;
        high_priority "when" WhenKeyword;
        high_priority "and" AndKeyword;
        high_priority "or" OrKeyword;
        high_priority "not" NotKeyword;
        high_priority "true" TrueKeyword;
        high_priority "false" FalseKeyword;
        high_priority "in" InKeyword;
        high_priority "rec" RecKeyword;
      ]
    in
    TokenRegistry.register_batch mappings

  (** 注册数字关键字映射 *)
  let register_number_keywords () =
    let mappings =
      [
        high_priority "零" ZeroKeyword;
        high_priority "一" OneKeyword;
        high_priority "二" TwoKeyword;
        high_priority "三" ThreeKeyword;
        high_priority "四" FourKeyword;
        high_priority "五" FiveKeyword;
        high_priority "六" SixKeyword;
        high_priority "七" SevenKeyword;
        high_priority "八" EightKeyword;
        high_priority "九" NineKeyword;
        high_priority "十" TenKeyword;
        high_priority "百" HundredKeyword;
        high_priority "千" ThousandKeyword;
        high_priority "万" TenThousandKeyword;
        (* 阿拉伯数字映射 *)
        medium_priority "0" ZeroKeyword;
        medium_priority "1" OneKeyword;
        medium_priority "2" TwoKeyword;
        medium_priority "3" ThreeKeyword;
        medium_priority "4" FourKeyword;
        medium_priority "5" FiveKeyword;
        medium_priority "6" SixKeyword;
        medium_priority "7" SevenKeyword;
        medium_priority "8" EightKeyword;
        medium_priority "9" NineKeyword;
      ]
    in
    TokenRegistry.register_batch mappings

  (** 注册类型关键字映射 *)
  let register_type_keywords () =
    let mappings =
      [
        high_priority "整数" IntTypeKeyword;
        high_priority "浮点数" FloatTypeKeyword;
        high_priority "字符串" StringTypeKeyword;
        high_priority "布尔" BoolTypeKeyword;
        high_priority "单元" UnitTypeKeyword;
        high_priority "列表" ListTypeKeyword;
        high_priority "数组" ArrayTypeKeyword;
        high_priority "引用类型" RefTypeKeyword;
        high_priority "函数类型" FunctionTypeKeyword;
        high_priority "元组" TupleTypeKeyword;
        high_priority "记录" RecordTypeKeyword;
        high_priority "变体" VariantTypeKeyword;
        high_priority "选项" OptionTypeKeyword;
        high_priority "结果" ResultTypeKeyword;
        (* 英文类型映射 *)
        high_priority "int" IntTypeKeyword;
        high_priority "float" FloatTypeKeyword;
        high_priority "string" StringTypeKeyword;
        high_priority "bool" BoolTypeKeyword;
        high_priority "unit" UnitTypeKeyword;
        high_priority "list" ListTypeKeyword;
        high_priority "array" ArrayTypeKeyword;
        high_priority "ref" RefTypeKeyword;
      ]
    in
    TokenRegistry.register_batch mappings

  (** 注册运算符映射 *)
  let register_operators () =
    let mappings =
      [
        high_priority "+" PlusOp;
        high_priority "-" MinusOp;
        high_priority "*" MultiplyOp;
        high_priority "/" DivideOp;
        high_priority "mod" ModOp;
        high_priority "**" PowerOp;
        high_priority "=" EqualOp;
        high_priority "<>" NotEqualOp;
        high_priority "<" LessOp;
        high_priority ">" GreaterOp;
        high_priority "<=" LessEqualOp;
        high_priority ">=" GreaterEqualOp;
        high_priority "&&" LogicalAndOp;
        high_priority "||" LogicalOrOp;
        high_priority ":=" AssignOp;
        high_priority "::" ConsOp;
        high_priority "@" AppendOp;
        high_priority "|>" PipeOp;
        high_priority "<|" PipeBackOp;
        high_priority "->" ArrowOp;
        high_priority "=>" DoubleArrowOp;
        (* 中文运算符 *)
        medium_priority "加" PlusOp;
        medium_priority "减" MinusOp;
        medium_priority "乘" MultiplyOp;
        medium_priority "除" DivideOp;
        medium_priority "取余" ModOp;
        medium_priority "等于" EqualOp;
        medium_priority "不等于" NotEqualOp;
        medium_priority "小于" LessOp;
        medium_priority "大于" GreaterOp;
        medium_priority "小于等于" LessEqualOp;
        medium_priority "大于等于" GreaterEqualOp;
      ]
    in
    TokenRegistry.register_batch mappings

  (** 注册分隔符映射 *)
  let register_delimiters () =
    let mappings =
      [
        high_priority "(" LeftParen;
        high_priority ")" RightParen;
        high_priority "[" LeftBracket;
        high_priority "]" RightBracket;
        high_priority "{" LeftBrace;
        high_priority "}" RightBrace;
        high_priority "," Comma;
        high_priority ";" Semicolon;
        high_priority ":" Colon;
        high_priority "::" DoubleColon;
        high_priority "." Dot;
        high_priority ".." DoubleDot;
        high_priority "..." TripleDot;
        high_priority "?" Question;
        high_priority "!" Exclamation;
        high_priority "@" AtSymbol;
        high_priority "#" SharpSymbol;
        high_priority "$" DollarSymbol;
        high_priority "_" Underscore;
        high_priority "`" Backquote;
        high_priority "'" SingleQuote;
        high_priority "\"" DoubleQuote;
        high_priority "\\" Backslash;
        high_priority "|" VerticalBar;
        high_priority "&" Ampersand;
        high_priority "~" Tilde;
        high_priority "^" Caret;
        high_priority "%" Percent;
      ]
    in
    TokenRegistry.register_batch mappings

  (** 注册文言文关键字映射 *)
  let register_wenyan_keywords () =
    let mappings =
      [
        high_priority "若" WenyanIfKeyword;
        high_priority "则" WenyanThenKeyword;
        high_priority "否则" WenyanElseKeyword;
        high_priority "当" WenyanWhileKeyword;
        high_priority "遍历" WenyanForKeyword;
        high_priority "函数" WenyanFunctionKeyword;
        high_priority "返回" WenyanReturnKeyword;
        high_priority "真" WenyanTrueKeyword;
        high_priority "假" WenyanFalseKeyword;
        high_priority "设" WenyanLetKeyword;
      ]
    in
    TokenRegistry.register_batch mappings

  (** 注册古雅体关键字映射 *)
  let register_classical_keywords () =
    let mappings =
      [
        high_priority "倘" ClassicalIfKeyword;
        high_priority "即" ClassicalThenKeyword;
        high_priority "反" ClassicalElseKeyword;
        high_priority "惟" ClassicalWhileKeyword;
        high_priority "遍" ClassicalForKeyword;
        high_priority "谓" ClassicalFunctionKeyword;
        high_priority "归" ClassicalReturnKeyword;
        high_priority "然" ClassicalTrueKeyword;
        high_priority "否" ClassicalFalseKeyword;
        high_priority "设谓" ClassicalLetKeyword;
      ]
    in
    TokenRegistry.register_batch mappings

  (** 注册所有预定义映射 *)
  let register_all () =
    register_basic_keywords ();
    register_number_keywords ();
    register_type_keywords ();
    register_operators ();
    register_delimiters ();
    register_wenyan_keywords ();
    register_classical_keywords ()
end

(** 初始化注册表 *)
let initialize () =
  TokenRegistry.clear ();
  PredefinedMappings.register_all ()
