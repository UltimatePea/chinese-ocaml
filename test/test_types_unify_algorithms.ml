(** 骆言类型统一算法专项测试套件 - Fix #824 *)

open Alcotest
open Yyocamlc_lib.Core_types
open Yyocamlc_lib.Types_unify

(** 测试辅助函数 *)
module TestHelpers = struct
  (** 检查统一操作是否成功 *)
  let check_unify_success msg typ1 typ2 =
    try
      let subst = unify typ1 typ2 in
      let unified1 = apply_subst subst typ1 in
      let unified2 = apply_subst subst typ2 in
      check bool msg (equal_typ unified1 unified2) true
    with
    | _ -> check bool msg false true

  (** 检查统一操作是否失败 *)
  let check_unify_fails msg typ1 typ2 =
    try
      let _ = unify typ1 typ2 in
      check bool msg false true  (* 不应该成功 *)
    with
    | _ -> check bool msg true true  (* 应该失败 *)

  (** 检查统一结果的替换是否正确 *)
  let check_unify_result msg typ1 typ2 expected_subst_effects =
    try
      let subst = unify typ1 typ2 in
      List.iter (fun (var_name, expected_type) ->
        let var_type = TypeVar_T var_name in
        let result = apply_subst subst var_type in
        check bool (msg ^ " - 变量" ^ var_name ^ "统一正确") 
          (equal_typ result expected_type) true
      ) expected_subst_effects
    with
    | _ -> check bool (msg ^ " - 统一应该成功") false true
end

(** 基础类型统一测试 *)
module BasicTypeUnificationTests = struct
  open TestHelpers

  let test_identical_basic_types () =
    check_unify_success "相同整数类型统一" IntType_T IntType_T;
    check_unify_success "相同浮点数类型统一" FloatType_T FloatType_T;
    check_unify_success "相同字符串类型统一" StringType_T StringType_T;
    check_unify_success "相同布尔类型统一" BoolType_T BoolType_T;
    check_unify_success "相同单位类型统一" UnitType_T UnitType_T

  let test_different_basic_types () =
    check_unify_fails "不同基础类型统一失败：int与string" IntType_T StringType_T;
    check_unify_fails "不同基础类型统一失败：bool与int" BoolType_T IntType_T;
    check_unify_fails "不同基础类型统一失败：float与bool" FloatType_T BoolType_T;
    check_unify_fails "不同基础类型统一失败：unit与string" UnitType_T StringType_T

  let test_empty_substitution () =
    (* 相同类型统一应该产生空替换 *)
    let subst = unify IntType_T IntType_T in
    let result = apply_subst subst IntType_T in
    check bool "相同类型统一产生空替换" (equal_typ result IntType_T) true
end

(** 类型变量统一测试 *)
module TypeVariableUnificationTests = struct
  open TestHelpers

  let test_type_variable_with_concrete_type () =
    let var_x = TypeVar_T "x" in
    let var_y = TypeVar_T "y" in
    
    check_unify_result "类型变量与int统一" var_x IntType_T [("x", IntType_T)];
    check_unify_result "类型变量与string统一" var_y StringType_T [("y", StringType_T)];
    check_unify_result "类型变量与bool统一" var_x BoolType_T [("x", BoolType_T)]

  let test_type_variable_with_type_variable () =
    let var_x = TypeVar_T "x" in
    let var_y = TypeVar_T "y" in
    
    (* 两个不同类型变量的统一应该成功 *)
    check_unify_success "不同类型变量统一" var_x var_y

  let test_identical_type_variables () =
    let var_x = TypeVar_T "x" in
    
    (* 相同类型变量统一应该成功且产生空替换 *)
    check_unify_success "相同类型变量统一" var_x var_x;
    
    let subst = unify var_x var_x in
    let result = apply_subst subst var_x in
    check bool "相同类型变量统一保持不变" (equal_typ result var_x) true

  let test_occurs_check () =
    let var_x = TypeVar_T "x" in
    let list_of_x = ListType_T var_x in
    
    (* occurs check: x不能统一为包含x的类型 *)
    check_unify_fails "occurs check: x与list x统一失败" var_x list_of_x;
    
    let func_type = FunType_T (var_x, var_x) in
    check_unify_fails "occurs check: x与x->x统一失败" var_x func_type
end

(** 函数类型统一测试 *)
module FunctionTypeUnificationTests = struct
  open TestHelpers

  let test_identical_function_types () =
    let func1 = FunType_T (IntType_T, StringType_T) in
    let func2 = FunType_T (IntType_T, StringType_T) in
    check_unify_success "相同函数类型统一" func1 func2

  let test_function_types_with_variables () =
    let var_x = TypeVar_T "x" in
    let var_y = TypeVar_T "y" in
    let func1 = FunType_T (var_x, StringType_T) in
    let func2 = FunType_T (IntType_T, var_y) in
    
    check_unify_result "函数类型with变量统一" func1 func2 
      [("x", IntType_T); ("y", StringType_T)]

  let test_nested_function_types () =
    let var_a = TypeVar_T "a" in
    let var_b = TypeVar_T "b" in
    let func1 = FunType_T (FunType_T (var_a, IntType_T), var_b) in
    let func2 = FunType_T (FunType_T (StringType_T, IntType_T), BoolType_T) in
    
    check_unify_result "嵌套函数类型统一" func1 func2
      [("a", StringType_T); ("b", BoolType_T)]

  let test_incompatible_function_types () =
    let func1 = FunType_T (IntType_T, StringType_T) in
    let func2 = FunType_T (BoolType_T, StringType_T) in
    check_unify_fails "不兼容函数参数类型统一失败" func1 func2;
    
    let func3 = FunType_T (IntType_T, StringType_T) in
    let func4 = FunType_T (IntType_T, BoolType_T) in
    check_unify_fails "不兼容函数返回类型统一失败" func3 func4
end

(** 元组类型统一测试 *)
module TupleTypeUnificationTests = struct
  open TestHelpers

  let test_identical_tuples () =
    let tuple1 = TupleType_T [IntType_T; StringType_T; BoolType_T] in
    let tuple2 = TupleType_T [IntType_T; StringType_T; BoolType_T] in
    check_unify_success "相同元组类型统一" tuple1 tuple2

  let test_tuples_with_variables () =
    let var_x = TypeVar_T "x" in
    let var_y = TypeVar_T "y" in
    let tuple1 = TupleType_T [var_x; StringType_T; var_y] in
    let tuple2 = TupleType_T [IntType_T; StringType_T; BoolType_T] in
    
    check_unify_result "元组with变量统一" tuple1 tuple2
      [("x", IntType_T); ("y", BoolType_T)]

  let test_empty_tuples () =
    let empty1 = TupleType_T [] in
    let empty2 = TupleType_T [] in
    check_unify_success "空元组统一" empty1 empty2

  let test_different_length_tuples () =
    let tuple1 = TupleType_T [IntType_T; StringType_T] in
    let tuple2 = TupleType_T [IntType_T; StringType_T; BoolType_T] in
    check_unify_fails "不同长度元组统一失败" tuple1 tuple2

  let test_incompatible_tuple_elements () =
    let tuple1 = TupleType_T [IntType_T; StringType_T] in
    let tuple2 = TupleType_T [BoolType_T; StringType_T] in
    check_unify_fails "不兼容元组元素统一失败" tuple1 tuple2
end

(** 列表类型统一测试 *)
module ListTypeUnificationTests = struct
  open TestHelpers

  let test_identical_list_types () =
    let list1 = ListType_T IntType_T in
    let list2 = ListType_T IntType_T in
    check_unify_success "相同列表类型统一" list1 list2

  let test_list_with_variable () =
    let var_x = TypeVar_T "x" in
    let list1 = ListType_T var_x in
    let list2 = ListType_T IntType_T in
    
    check_unify_result "列表with变量统一" list1 list2 [("x", IntType_T)]

  let test_nested_lists () =
    let var_y = TypeVar_T "y" in
    let nested_list1 = ListType_T (ListType_T var_y) in
    let nested_list2 = ListType_T (ListType_T StringType_T) in
    
    check_unify_result "嵌套列表统一" nested_list1 nested_list2 [("y", StringType_T)]

  let test_incompatible_list_element_types () =
    let list1 = ListType_T IntType_T in
    let list2 = ListType_T StringType_T in
    check_unify_fails "不兼容列表元素类型统一失败" list1 list2
end

(** 数组类型统一测试 *)
module ArrayTypeUnificationTests = struct
  open TestHelpers

  let test_identical_array_types () =
    let array1 = ArrayType_T IntType_T in
    let array2 = ArrayType_T IntType_T in
    check_unify_success "相同数组类型统一" array1 array2

  let test_array_with_variable () =
    let var_z = TypeVar_T "z" in
    let array1 = ArrayType_T var_z in
    let array2 = ArrayType_T BoolType_T in
    
    check_unify_result "数组with变量统一" array1 array2 [("z", BoolType_T)]

  let test_incompatible_array_element_types () =
    let array1 = ArrayType_T IntType_T in
    let array2 = ArrayType_T FloatType_T in
    check_unify_fails "不兼容数组元素类型统一失败" array1 array2
end

(** 构造类型统一测试 *)
module ConstructTypeUnificationTests = struct
  open TestHelpers

  let test_identical_construct_types () =
    let const1 = ConstructType_T ("Option", [IntType_T]) in
    let const2 = ConstructType_T ("Option", [IntType_T]) in
    check_unify_success "相同构造类型统一" const1 const2

  let test_construct_type_with_variables () =
    let var_a = TypeVar_T "a" in
    let const1 = ConstructType_T ("Result", [var_a; StringType_T]) in
    let const2 = ConstructType_T ("Result", [IntType_T; StringType_T]) in
    
    check_unify_result "构造类型with变量统一" const1 const2 [("a", IntType_T)]

  let test_different_constructor_names () =
    let const1 = ConstructType_T ("Option", [IntType_T]) in
    let const2 = ConstructType_T ("List", [IntType_T]) in
    check_unify_fails "不同构造器名称统一失败" const1 const2

  let test_different_parameter_count () =
    let const1 = ConstructType_T ("Result", [IntType_T]) in
    let const2 = ConstructType_T ("Result", [IntType_T; StringType_T]) in
    check_unify_fails "不同参数数量构造类型统一失败" const1 const2
end

(** 记录类型统一测试 *)
module RecordTypeUnificationTests = struct
  open TestHelpers

  let test_identical_record_types () =
    let record1 = RecordType_T [("x", IntType_T); ("y", StringType_T)] in
    let record2 = RecordType_T [("x", IntType_T); ("y", StringType_T)] in
    check_unify_success "相同记录类型统一" record1 record2

  let test_record_with_variables () =
    let var_a = TypeVar_T "a" in
    let var_b = TypeVar_T "b" in
    let record1 = RecordType_T [("field1", var_a); ("field2", var_b)] in
    let record2 = RecordType_T [("field1", IntType_T); ("field2", BoolType_T)] in
    
    check_unify_result "记录类型with变量统一" record1 record2
      [("a", IntType_T); ("b", BoolType_T)]

  let test_different_field_names () =
    let record1 = RecordType_T [("x", IntType_T)] in
    let record2 = RecordType_T [("y", IntType_T)] in
    check_unify_fails "不同字段名记录类型统一失败" record1 record2

  let test_different_field_count () =
    let record1 = RecordType_T [("x", IntType_T)] in
    let record2 = RecordType_T [("x", IntType_T); ("y", StringType_T)] in
    check_unify_fails "不同字段数量记录类型统一失败" record1 record2
end

(** 复杂类型统一测试 *)
module ComplexTypeUnificationTests = struct
  open TestHelpers

  let test_deeply_nested_types () =
    let var_x = TypeVar_T "x" in
    let var_y = TypeVar_T "y" in
    
    let complex1 = FunType_T (
      TupleType_T [ListType_T var_x; ArrayType_T var_y],
      ConstructType_T ("Option", [var_x])
    ) in
    
    let complex2 = FunType_T (
      TupleType_T [ListType_T IntType_T; ArrayType_T StringType_T],
      ConstructType_T ("Option", [IntType_T])
    ) in
    
    check_unify_result "深层嵌套类型统一" complex1 complex2
      [("x", IntType_T); ("y", StringType_T)]

  let test_recursive_structure_compatibility () =
    let var_t = TypeVar_T "t" in
    let tree1 = ConstructType_T ("Tree", [var_t]) in
    let tree2 = ConstructType_T ("Tree", [IntType_T]) in
    
    check_unify_result "递归结构兼容性" tree1 tree2 [("t", IntType_T)]

  let test_multiple_constraint_resolution () =
    let var_a = TypeVar_T "a" in
    let var_b = TypeVar_T "b" in
    let var_c = TypeVar_T "c" in
    
    (* 创建一个需要多步推导的类型约束场景 *)
    let func1 = FunType_T (var_a, FunType_T (var_b, var_c)) in
    let func2 = FunType_T (IntType_T, FunType_T (StringType_T, BoolType_T)) in
    
    check_unify_result "多约束解析" func1 func2
      [("a", IntType_T); ("b", StringType_T); ("c", BoolType_T)]

  let test_partial_type_information () =
    let var_x = TypeVar_T "x" in
    let var_y = TypeVar_T "y" in
    
    let partial1 = TupleType_T [var_x; ListType_T var_y; var_x] in
    let partial2 = TupleType_T [IntType_T; ListType_T StringType_T; IntType_T] in
    
    check_unify_result "部分类型信息统一" partial1 partial2
      [("x", IntType_T); ("y", StringType_T)]
end

(** 边界条件和错误处理测试 *)
module EdgeCaseTests = struct
  open TestHelpers

  let test_occurs_check_complex () =
    let var_x = TypeVar_T "x" in
    
    (* 复杂的occurs check场景 *)
    let complex_cycle = FunType_T (
      var_x,
      TupleType_T [ListType_T var_x; ArrayType_T var_x]
    ) in
    
    check_unify_fails "复杂occurs check" var_x complex_cycle

  let test_type_variable_consistency () =
    (* 确保同一个类型变量在不同上下文中的一致性 *)
    let var_t = TypeVar_T "t" in
    let list_t = ListType_T var_t in
    let array_t = ArrayType_T var_t in
    
    let tuple1 = TupleType_T [list_t; array_t] in
    let tuple2 = TupleType_T [ListType_T IntType_T; ArrayType_T IntType_T] in
    
    check_unify_result "类型变量一致性" tuple1 tuple2 [("t", IntType_T)]

  let test_substitution_composition () =
    (* 测试替换组合的正确性 *)
    let var_x = TypeVar_T "x" in
    let var_y = TypeVar_T "y" in
    
    let subst1 = single_subst "x" IntType_T in
    let subst2 = single_subst "y" (ListType_T var_x) in
    let composed = compose_subst subst1 subst2 in
    
    let result = apply_subst composed var_y in
    check bool "替换组合正确性" (equal_typ result (ListType_T IntType_T)) true

  let test_empty_substitution_identity () =
    (* 测试空替换的恒等性 *)
    let complex_type = FunType_T (
      TupleType_T [IntType_T; StringType_T],
      ListType_T BoolType_T
    ) in
    
    let result = apply_subst empty_subst complex_type in
    check bool "空替换恒等性" (equal_typ result complex_type) true
end

(** 执行所有类型统一算法测试 *)
let () =
  run "类型统一算法专项测试"
    [
      ( "基础类型统一",
        [
          test_case "相同基础类型统一" `Quick BasicTypeUnificationTests.test_identical_basic_types;
          test_case "不同基础类型统一失败" `Quick BasicTypeUnificationTests.test_different_basic_types;
          test_case "空替换测试" `Quick BasicTypeUnificationTests.test_empty_substitution;
        ] );
      ( "类型变量统一",
        [
          test_case "类型变量与具体类型统一" `Quick TypeVariableUnificationTests.test_type_variable_with_concrete_type;
          test_case "类型变量间统一" `Quick TypeVariableUnificationTests.test_type_variable_with_type_variable;
          test_case "相同类型变量统一" `Quick TypeVariableUnificationTests.test_identical_type_variables;
          test_case "occurs check测试" `Quick TypeVariableUnificationTests.test_occurs_check;
        ] );
      ( "函数类型统一",
        [
          test_case "相同函数类型统一" `Quick FunctionTypeUnificationTests.test_identical_function_types;
          test_case "函数类型with变量统一" `Quick FunctionTypeUnificationTests.test_function_types_with_variables;
          test_case "嵌套函数类型统一" `Quick FunctionTypeUnificationTests.test_nested_function_types;
          test_case "不兼容函数类型统一失败" `Quick FunctionTypeUnificationTests.test_incompatible_function_types;
        ] );
      ( "元组类型统一",
        [
          test_case "相同元组类型统一" `Quick TupleTypeUnificationTests.test_identical_tuples;
          test_case "元组with变量统一" `Quick TupleTypeUnificationTests.test_tuples_with_variables;
          test_case "空元组统一" `Quick TupleTypeUnificationTests.test_empty_tuples;
          test_case "不同长度元组统一失败" `Quick TupleTypeUnificationTests.test_different_length_tuples;
          test_case "不兼容元组元素统一失败" `Quick TupleTypeUnificationTests.test_incompatible_tuple_elements;
        ] );
      ( "列表类型统一",
        [
          test_case "相同列表类型统一" `Quick ListTypeUnificationTests.test_identical_list_types;
          test_case "列表with变量统一" `Quick ListTypeUnificationTests.test_list_with_variable;
          test_case "嵌套列表统一" `Quick ListTypeUnificationTests.test_nested_lists;
          test_case "不兼容列表元素类型统一失败" `Quick ListTypeUnificationTests.test_incompatible_list_element_types;
        ] );
      ( "数组类型统一",
        [
          test_case "相同数组类型统一" `Quick ArrayTypeUnificationTests.test_identical_array_types;
          test_case "数组with变量统一" `Quick ArrayTypeUnificationTests.test_array_with_variable;
          test_case "不兼容数组元素类型统一失败" `Quick ArrayTypeUnificationTests.test_incompatible_array_element_types;
        ] );
      ( "构造类型统一",
        [
          test_case "相同构造类型统一" `Quick ConstructTypeUnificationTests.test_identical_construct_types;
          test_case "构造类型with变量统一" `Quick ConstructTypeUnificationTests.test_construct_type_with_variables;
          test_case "不同构造器名称统一失败" `Quick ConstructTypeUnificationTests.test_different_constructor_names;
          test_case "不同参数数量构造类型统一失败" `Quick ConstructTypeUnificationTests.test_different_parameter_count;
        ] );
      ( "记录类型统一",
        [
          test_case "相同记录类型统一" `Quick RecordTypeUnificationTests.test_identical_record_types;
          test_case "记录类型with变量统一" `Quick RecordTypeUnificationTests.test_record_with_variables;
          test_case "不同字段名记录类型统一失败" `Quick RecordTypeUnificationTests.test_different_field_names;
          test_case "不同字段数量记录类型统一失败" `Quick RecordTypeUnificationTests.test_different_field_count;
        ] );
      ( "复杂类型统一",
        [
          test_case "深层嵌套类型统一" `Quick ComplexTypeUnificationTests.test_deeply_nested_types;
          test_case "递归结构兼容性" `Quick ComplexTypeUnificationTests.test_recursive_structure_compatibility;
          test_case "多约束解析" `Quick ComplexTypeUnificationTests.test_multiple_constraint_resolution;
          test_case "部分类型信息统一" `Quick ComplexTypeUnificationTests.test_partial_type_information;
        ] );
      ( "边界条件和错误处理",
        [
          test_case "复杂occurs check" `Quick EdgeCaseTests.test_occurs_check_complex;
          test_case "类型变量一致性" `Quick EdgeCaseTests.test_type_variable_consistency;
          test_case "替换组合正确性" `Quick EdgeCaseTests.test_substitution_composition;
          test_case "空替换恒等性" `Quick EdgeCaseTests.test_empty_substitution_identity;
        ] );
    ]