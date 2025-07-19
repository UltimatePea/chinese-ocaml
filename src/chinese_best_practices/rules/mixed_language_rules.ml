(** 中英文混用检测规则 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Severity_types

(** 中英文混用模式规则类型 *)
type mixed_language_rule = {
  pattern : string;           (** 正则表达式模式 *)
  description : string;       (** 问题描述 *)
  suggestion : string;        (** 改进建议 *)
  severity : severity;        (** 严重程度 *)
  category : string;          (** 规则类别 *)
}

(** 中英文混用检测规则集合 *)
let mixed_language_rules = [
  (* 英文关键字混入中文代码 *)
  {
    pattern = "if.*那么";
    description = "if条件判断";
    suggestion = "如果条件判断";
    severity = Error;
    category = "关键字混用";
  };
  {
    pattern = "for.*循环";
    description = "for循环结构";
    suggestion = "循环结构";
    severity = Warning;
    category = "关键字混用";
  };
  {
    pattern = "function.*函数";
    description = "function函数定义";
    suggestion = "函数定义";
    severity = Warning;
    category = "关键字混用";
  };
  {
    pattern = "return.*返回";
    description = "return返回语句";
    suggestion = "返回语句";
    severity = Warning;
    category = "关键字混用";
  };
  
  (* 变量名混用 *)
  {
    pattern = "让.*[a-zA-Z]+.*=";
    description = "变量名使用英文";
    suggestion = "使用中文变量名";
    severity = Style;
    category = "命名规范";
  };
  {
    pattern = "函数.*[a-zA-Z]+.*→";
    description = "函数名使用英文";
    suggestion = "使用中文函数名";
    severity = Style;
    category = "命名规范";
  };
  
  (* 注释混用 *)
  {
    pattern = "//.*[一-龯]";
    description = "英文注释符配中文";
    suggestion = "使用中文注释符「」";
    severity = Info;
    category = "注释风格";
  };
  {
    pattern = "/\\*.*[一-龯]";
    description = "英文注释符配中文";
    suggestion = "使用中文注释符「」";
    severity = Info;
    category = "注释风格";
  };
]

(** 根据类别获取规则 *)
let get_rules_by_category category =
  List.filter (fun rule -> rule.category = category) mixed_language_rules

(** 获取所有规则类别 *)
let get_all_categories () =
  mixed_language_rules
  |> List.map (fun rule -> rule.category)
  |> List.sort_uniq String.compare

(** 根据严重程度获取规则 *)
let get_rules_by_severity min_severity =
  let severity_level = function
    | Error -> 4 | Warning -> 3 | Style -> 2 | Info -> 1
  in
  let min_level = severity_level min_severity in
  List.filter (fun rule -> severity_level rule.severity >= min_level) mixed_language_rules