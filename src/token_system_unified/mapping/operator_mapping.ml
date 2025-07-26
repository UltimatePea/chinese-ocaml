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
      ("+", Operators.Plus);
      ("-", Operators.Minus);
      ("*", Operators.Multiply);
      ("/", Operators.Divide);
      ("%", Operators.Modulo);
      ("**", Operators.Power);
      (* 比较操作符 *)
      ("=", Operators.Equal);
      ("!=", Operators.NotEqual);
      ("<>", Operators.NotEqual);
      (* OCaml风格 *)
      ("<", Operators.LessThan);
      ("<=", Operators.LessEqual);
      (">", Operators.GreaterThan);
      (">=", Operators.GreaterEqual);
      (* 逻辑操作符 *)
      ("&&", Operators.LogicalAnd);
      ("||", Operators.LogicalOr);
      ("not", Operators.LogicalNot);
      (* 赋值操作符 *)
      (":=", Operators.Assign);
      ("+=", Operators.Assign);
      (* Simplified *)
      ("-=", Operators.Assign);
      (* Simplified *)
      ("*=", Operators.Assign);
      (* Simplified *)
      ("/=", Operators.Assign);
      (* Simplified *)
      (* 位运算操作符 *)
      ("&", Operators.BitwiseAnd);
      ("|", Operators.BitwiseOr);
      ("^", Operators.BitwiseXor);
      ("~", Operators.BitwiseNot);
      ("<<", Operators.ShiftLeft);
      (">>", Operators.ShiftRight);
    ]

  (** 中文到操作符类型的映射 *)
  let chinese_to_operator =
    [
      (* 算术操作符中文表示 *)
      ("加", Operators.Plus);
      ("减", Operators.Minus);
      ("乘", Operators.Multiply);
      ("除", Operators.Divide);
      ("取余", Operators.Modulo);
      ("幂", Operators.Power);
      (* 比较操作符中文表示 *)
      ("等于", Operators.Equal);
      ("不等于", Operators.NotEqual);
      ("小于", Operators.LessThan);
      ("小于等于", Operators.LessEqual);
      ("大于", Operators.GreaterThan);
      ("大于等于", Operators.GreaterEqual);
      (* 逻辑操作符中文表示 *)
      ("并且", Operators.LogicalAnd);
      ("或者", Operators.LogicalOr);
      ("非", Operators.LogicalNot);
      (* 赋值操作符中文表示 *)
      ("赋值", Operators.Assign);
      ("加等", Operators.Assign);
      (* 简化映射 *)
      ("减等", Operators.Assign);
      (* 简化映射 *)
      ("乘等", Operators.Assign);
      (* 简化映射 *)
      ("除等", Operators.Assign);
      (* 简化映射 *)
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
    | Operators.Power -> 7
    | Operators.Multiply | Operators.Divide | Operators.Modulo -> 6
    | Operators.Plus | Operators.Minus -> 5
    | Operators.Equal | Operators.NotEqual | Operators.LessThan | Operators.LessEqual
    | Operators.GreaterThan | Operators.GreaterEqual ->
        4
    | Operators.LogicalAnd -> 3
    | Operators.LogicalOr -> 2
    | Operators.Assign -> 1
    | Operators.BitwiseAnd | Operators.BitwiseOr | Operators.BitwiseXor -> 3 (* 位运算优先级介于比较和逻辑之间 *)
    | _ -> 0

  (** 获取操作符结合性 *)
  let get_operator_associativity = function
    | Operators.Power -> RightAssoc
    | Operators.Assign -> RightAssoc
    | Operators.Plus | Operators.Minus | Operators.Multiply | Operators.Divide | Operators.Modulo ->
        LeftAssoc
    | Operators.Equal | Operators.NotEqual | Operators.LessThan | Operators.LessEqual
    | Operators.GreaterThan | Operators.GreaterEqual ->
        NonAssoc
    | Operators.LogicalAnd | Operators.LogicalOr -> LeftAssoc
    | Operators.BitwiseAnd | Operators.BitwiseOr | Operators.BitwiseXor -> LeftAssoc
    | _ -> LeftAssoc (* Default to left associative for other operators *)

  (** 检查是否为二元操作符 *)
  let is_binary_operator = function
    | Operators.Plus | Operators.Minus | Operators.Multiply | Operators.Divide | Operators.Modulo
    | Operators.Power | Operators.Equal | Operators.NotEqual | Operators.LessThan
    | Operators.LessEqual | Operators.GreaterThan | Operators.GreaterEqual | Operators.LogicalAnd
    | Operators.LogicalOr | Operators.Assign | Operators.BitwiseAnd | Operators.BitwiseOr
    | Operators.BitwiseXor | Operators.ShiftLeft | Operators.ShiftRight ->
        true
    | _ -> false

  (** 检查是否为一元操作符 *)
  let is_unary_operator = function
    | Operators.LogicalNot | Operators.BitwiseNot -> true
    | _ -> false

  (** 按类别获取操作符 *)
  let get_operators_by_category category =
    let filter_by_category (_, op) =
      match (category, op) with
      | ( "arithmetic",
          ( Operators.Plus | Operators.Minus | Operators.Multiply | Operators.Divide
          | Operators.Modulo | Operators.Power ) ) ->
          true
      | ( "comparison",
          ( Operators.Equal | Operators.NotEqual | Operators.LessThan | Operators.LessEqual
          | Operators.GreaterThan | Operators.GreaterEqual ) ) ->
          true
      | "logical", (Operators.LogicalAnd | Operators.LogicalOr | Operators.LogicalNot) -> true
      | "assignment", Operators.Assign -> true
      | ( "bitwise",
          (Operators.BitwiseAnd | Operators.BitwiseOr | Operators.BitwiseXor | Operators.BitwiseNot)
        ) ->
          true
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
    operator : Operators.operator_token;
    precedence : int;
    associativity : associativity;
    arity : [ `Unary | `Binary ];
  }

  let precedence_table =
    [
      { operator = Power; precedence = 7; associativity = RightAssoc; arity = `Binary };
      { operator = Multiply; precedence = 6; associativity = LeftAssoc; arity = `Binary };
      { operator = Divide; precedence = 6; associativity = LeftAssoc; arity = `Binary };
      { operator = Modulo; precedence = 6; associativity = LeftAssoc; arity = `Binary };
      { operator = Plus; precedence = 5; associativity = LeftAssoc; arity = `Binary };
      { operator = Minus; precedence = 5; associativity = LeftAssoc; arity = `Binary };
      { operator = Equal; precedence = 4; associativity = NonAssoc; arity = `Binary };
      { operator = NotEqual; precedence = 4; associativity = NonAssoc; arity = `Binary };
      { operator = LessThan; precedence = 4; associativity = NonAssoc; arity = `Binary };
      { operator = LessEqual; precedence = 4; associativity = NonAssoc; arity = `Binary };
      { operator = GreaterThan; precedence = 4; associativity = NonAssoc; arity = `Binary };
      { operator = GreaterEqual; precedence = 4; associativity = NonAssoc; arity = `Binary };
      { operator = LogicalAnd; precedence = 3; associativity = LeftAssoc; arity = `Binary };
      { operator = LogicalOr; precedence = 2; associativity = LeftAssoc; arity = `Binary };
      { operator = LogicalNot; precedence = 6; associativity = RightAssoc; arity = `Unary };
    ]

  (** 查找操作符优先级信息 *)
  let find_precedence_info op = List.find_opt (fun entry -> entry.operator = op) precedence_table

  (** 比较两个操作符的优先级 *)
  let compare_precedence op1 op2 =
    let prec1 = OperatorMapping.get_operator_precedence op1 in
    let prec2 = OperatorMapping.get_operator_precedence op2 in
    compare prec1 prec2
end
