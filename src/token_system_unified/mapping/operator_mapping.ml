(** 骆言Token系统整合重构 - 操作符映射管理 提供操作符的双向映射和优先级管理功能 *)

open Yyocamlc_lib.Token_types

(** 操作符结合性 *)
type associativity = LeftAssoc | RightAssoc | NonAssoc

(** 操作符映射模块 *)
module OperatorMapping = struct
  (** 符号到操作符类型的映射 *)
  let symbol_to_operator =
    [
      (* 算术操作符 *)
      ("+", Arithmetic Plus);
      ("-", Arithmetic Minus);
      ("*", Arithmetic Multiply);
      ("/", Arithmetic Divide);
      ("%", Arithmetic Modulo);
      ("**", Arithmetic Power);
      (* 比较操作符 *)
      ("=", Comparison Equal);
      ("!=", Comparison NotEqual);
      ("<>", Comparison NotEqual);
      (* OCaml风格 *)
      ("<", Comparison LessThan);
      ("<=", Comparison LessEqual);
      (">", Comparison GreaterThan);
      (">=", Comparison GreaterEqual);
      (* 逻辑操作符 *)
      ("&&", Logical And);
      ("||", Logical Or);
      ("not", Logical Not);
      (* 赋值操作符 *)
      (":=", Assignment Assign);
      ("+=", Assignment PlusAssign);
      ("-=", Assignment MinusAssign);
      ("*=", Assignment MultiplyAssign);
      ("/=", Assignment DivideAssign);
      (* 位运算操作符 *)
      ("&", Bitwise BitwiseAnd);
      ("|", Bitwise BitwiseOr);
      ("^", Bitwise BitwiseXor);
      ("~", Bitwise BitwiseNot);
      ("<<", Bitwise LeftShift);
      (">>", Bitwise RightShift);
    ]

  (** 中文到操作符类型的映射 *)
  let chinese_to_operator =
    [
      (* 算术操作符中文表示 *)
      ("加", Arithmetic Plus);
      ("减", Arithmetic Minus);
      ("乘", Arithmetic Multiply);
      ("除", Arithmetic Divide);
      ("取余", Arithmetic Modulo);
      ("幂", Arithmetic Power);
      (* 比较操作符中文表示 *)
      ("等于", Comparison Equal);
      ("不等于", Comparison NotEqual);
      ("小于", Comparison LessThan);
      ("小于等于", Comparison LessEqual);
      ("大于", Comparison GreaterThan);
      ("大于等于", Comparison GreaterEqual);
      (* 逻辑操作符中文表示 *)
      ("并且", Logical And);
      ("或者", Logical Or);
      ("非", Logical Not);
      (* 赋值操作符中文表示 *)
      ("赋值", Assignment Assign);
      ("加等", Assignment PlusAssign);
      ("减等", Assignment MinusAssign);
      ("乘等", Assignment MultiplyAssign);
      ("除等", Assignment DivideAssign);
    ]

  (** 创建查找表 *)
  let symbol_operator_table =
    let tbl = Hashtbl.create 32 in
    List.iter (fun (k, v) -> Hashtbl.add tbl k v) symbol_to_operator;
    tbl

  let chinese_operator_table =
    let tbl = Hashtbl.create 32 in
    List.iter (fun (k, v) -> Hashtbl.add tbl k v) chinese_to_operator;
    tbl

  (** 反向映射：操作符类型到符号 *)
  let operator_to_symbol_table =
    let tbl = Hashtbl.create 32 in
    List.iter (fun (k, v) -> Hashtbl.add tbl v k) symbol_to_operator;
    tbl

  (** 反向映射：操作符类型到中文 *)
  let operator_to_chinese_table =
    let tbl = Hashtbl.create 32 in
    List.iter (fun (k, v) -> Hashtbl.add tbl v k) chinese_to_operator;
    tbl

  (** 查找符号操作符 *)
  let lookup_symbol_operator text = Hashtbl.find_opt symbol_operator_table text

  (** 查找中文操作符 *)
  let lookup_chinese_operator text = Hashtbl.find_opt chinese_operator_table text

  (** 通用操作符查找 *)
  let lookup_operator text =
    match lookup_symbol_operator text with
    | Some op -> Some op
    | None -> lookup_chinese_operator text

  (** 操作符转换为符号 *)
  let operator_to_symbol op = Hashtbl.find_opt operator_to_symbol_table op

  (** 操作符转换为中文 *)
  let operator_to_chinese op = Hashtbl.find_opt operator_to_chinese_table op

  (** 检查是否为操作符 *)
  let is_operator text = match lookup_operator text with Some _ -> true | None -> false

  (** 获取操作符优先级 *)
  let get_operator_precedence = function
    | Arithmetic Power -> 7
    | Arithmetic (Multiply | Divide | Modulo) -> 6
    | Arithmetic (Plus | Minus) -> 5
    | Comparison _ -> 4
    | Logical And -> 3
    | Logical Or -> 2
    | Assignment _ -> 1
    | Bitwise _ -> 3 (* 位运算优先级介于比较和逻辑之间 *)
    | _ -> 0

  (** 获取操作符结合性 *)
  let get_operator_associativity = function
    | Arithmetic Power -> RightAssoc
    | Assignment _ -> RightAssoc
    | Arithmetic _ -> LeftAssoc
    | Comparison _ -> NonAssoc
    | Logical _ -> LeftAssoc
    | Bitwise _ -> LeftAssoc

  (** 检查是否为二元操作符 *)
  let is_binary_operator = function
    | Arithmetic _ | Comparison _
    | Logical (And | Or)
    | Assignment _
    | Bitwise (BitwiseAnd | BitwiseOr | BitwiseXor | LeftShift | RightShift) ->
        true
    | _ -> false

  (** 检查是否为一元操作符 *)
  let is_unary_operator = function Logical Not | Bitwise BitwiseNot -> true | _ -> false

  (** 按类别获取操作符 *)
  let get_operators_by_category category =
    let filter_by_category (_, op) =
      match (category, op) with
      | "arithmetic", Arithmetic _ -> true
      | "comparison", Comparison _ -> true
      | "logical", Logical _ -> true
      | "assignment", Assignment _ -> true
      | "bitwise", Bitwise _ -> true
      | _ -> false
    in
    symbol_to_operator |> List.filter filter_by_category |> List.map fst

  (** 获取所有符号操作符 *)
  let get_all_symbol_operators () = List.map fst symbol_to_operator

  (** 获取所有中文操作符 *)
  let get_all_chinese_operators () = List.map fst chinese_to_operator

  (** 操作符统计信息 *)
  let get_operator_stats () =
    {|
符号操作符数量: |}
    ^ string_of_int (List.length symbol_to_operator)
    ^ {|
中文操作符数量: |}
    ^ string_of_int (List.length chinese_to_operator)
    ^ {|
算术操作符: |}
    ^ string_of_int (List.length (get_operators_by_category "arithmetic"))
    ^ {|
比较操作符: |}
    ^ string_of_int (List.length (get_operators_by_category "comparison"))
    ^ {|
逻辑操作符: |}
    ^ string_of_int (List.length (get_operators_by_category "logical"))
    ^ {|
赋值操作符: |}
    ^ string_of_int (List.length (get_operators_by_category "assignment"))
    ^ {|
位运算操作符: |}
    ^ string_of_int (List.length (get_operators_by_category "bitwise"))
end

(** 操作符优先级表 *)
module OperatorPrecedenceTable = struct
  type precedence_entry = {
    operator : operator_type;
    precedence : int;
    associativity : associativity;
    arity : [ `Unary | `Binary ];
  }

  let precedence_table =
    [
      { operator = Arithmetic Power; precedence = 7; associativity = RightAssoc; arity = `Binary };
      { operator = Arithmetic Multiply; precedence = 6; associativity = LeftAssoc; arity = `Binary };
      { operator = Arithmetic Divide; precedence = 6; associativity = LeftAssoc; arity = `Binary };
      { operator = Arithmetic Modulo; precedence = 6; associativity = LeftAssoc; arity = `Binary };
      { operator = Arithmetic Plus; precedence = 5; associativity = LeftAssoc; arity = `Binary };
      { operator = Arithmetic Minus; precedence = 5; associativity = LeftAssoc; arity = `Binary };
      { operator = Comparison Equal; precedence = 4; associativity = NonAssoc; arity = `Binary };
      { operator = Comparison NotEqual; precedence = 4; associativity = NonAssoc; arity = `Binary };
      { operator = Comparison LessThan; precedence = 4; associativity = NonAssoc; arity = `Binary };
      { operator = Comparison LessEqual; precedence = 4; associativity = NonAssoc; arity = `Binary };
      {
        operator = Comparison GreaterThan;
        precedence = 4;
        associativity = NonAssoc;
        arity = `Binary;
      };
      {
        operator = Comparison GreaterEqual;
        precedence = 4;
        associativity = NonAssoc;
        arity = `Binary;
      };
      { operator = Logical And; precedence = 3; associativity = LeftAssoc; arity = `Binary };
      { operator = Logical Or; precedence = 2; associativity = LeftAssoc; arity = `Binary };
      { operator = Logical Not; precedence = 6; associativity = RightAssoc; arity = `Unary };
      { operator = Assignment Assign; precedence = 1; associativity = RightAssoc; arity = `Binary };
    ]

  (** 查找操作符优先级信息 *)
  let find_precedence_info op = List.find_opt (fun entry -> entry.operator = op) precedence_table

  (** 比较两个操作符的优先级 *)
  let compare_precedence op1 op2 =
    let prec1 = OperatorMapping.get_operator_precedence op1 in
    let prec2 = OperatorMapping.get_operator_precedence op2 in
    compare prec1 prec2
end
