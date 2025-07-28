(** 骆言核心类型系统基础测试套件 - Issue #946 第二阶段类型系统基础测试补强 *)

open Alcotest
open Yyocamlc_lib.Core_types

(** 测试辅助函数 *)
module TestUtils = struct
  (** 检查类型是否相等 *)
  let check_type_equal desc expected actual = check bool desc true (equal_typ expected actual)

  (** 检查类型不相等 *)
  let check_type_not_equal desc left right = check bool desc false (equal_typ left right)

  (** 检查字符串包含某个子字符串 *)
  let check_string_contains desc haystack needle =
    check bool desc true
      (String.length needle = 0
      ||
      try
        ignore (Str.search_forward (Str.regexp_string needle) haystack 0);
        true
      with Not_found -> false)
end

(** 基础类型定义测试 *)
module BasicTypeTests = struct
  (** 测试基础数据类型的定义和创建 *)
  let test_basic_type_creation () =
    let test_cases =
      [
        (IntType_T, "整数类型创建");
        (FloatType_T, "浮点数类型创建");
        (StringType_T, "字符串类型创建");
        (BoolType_T, "布尔类型创建");
        (UnitType_T, "空值类型创建");
      ]
    in
    List.iter (fun (typ, desc) -> TestUtils.check_type_equal desc typ typ) test_cases

  (** 测试基础类型的相等性比较 *)
  let test_basic_type_equality () =
    (* 测试相同类型的相等性 *)
    TestUtils.check_type_equal "整数类型自身相等" IntType_T IntType_T;
    TestUtils.check_type_equal "浮点数类型自身相等" FloatType_T FloatType_T;
    TestUtils.check_type_equal "字符串类型自身相等" StringType_T StringType_T;
    TestUtils.check_type_equal "布尔类型自身相等" BoolType_T BoolType_T;
    TestUtils.check_type_equal "空值类型自身相等" UnitType_T UnitType_T;

    (* 测试不同基础类型的不等性 *)
    TestUtils.check_type_not_equal "整数与浮点数类型不等" IntType_T FloatType_T;
    TestUtils.check_type_not_equal "字符串与布尔类型不等" StringType_T BoolType_T;
    TestUtils.check_type_not_equal "布尔与空值类型不等" BoolType_T UnitType_T

  (** 测试基础类型检查函数 *)
  let test_basic_type_predicates () =
    (* 测试is_base_type函数 *)
    check bool "整数是基础类型" true (is_base_type IntType_T);
    check bool "浮点数是基础类型" true (is_base_type FloatType_T);
    check bool "字符串是基础类型" true (is_base_type StringType_T);
    check bool "布尔值是基础类型" true (is_base_type BoolType_T);
    check bool "空值是基础类型" true (is_base_type UnitType_T);

    (* 测试复合类型不是基础类型 *)
    let list_type = ListType_T IntType_T in
    let fun_type = FunType_T (IntType_T, StringType_T) in
    check bool "列表不是基础类型" false (is_base_type list_type);
    check bool "函数不是基础类型" false (is_base_type fun_type);

    (* 测试is_compound_type函数 *)
    check bool "整数不是复合类型" false (is_compound_type IntType_T);
    check bool "列表是复合类型" true (is_compound_type list_type);
    check bool "函数是复合类型" true (is_compound_type fun_type)
end

(** 复合类型定义测试 *)
module CompoundTypeTests = struct
  (** 测试函数类型定义和操作 *)
  let test_function_types () =
    let simple_fun = FunType_T (IntType_T, StringType_T) in
    let complex_fun = FunType_T (FunType_T (IntType_T, BoolType_T), StringType_T) in

    TestUtils.check_type_equal "简单函数类型自身相等" simple_fun simple_fun;
    TestUtils.check_type_equal "复杂函数类型自身相等" complex_fun complex_fun;
    TestUtils.check_type_not_equal "不同函数类型不等" simple_fun complex_fun;

    (* 测试高阶函数类型 *)
    let higher_order = FunType_T (simple_fun, complex_fun) in
    check bool "高阶函数是复合类型" true (is_compound_type higher_order)

  (** 测试元组类型定义和操作 *)
  let test_tuple_types () =
    let simple_tuple = TupleType_T [ IntType_T; StringType_T ] in
    let complex_tuple = TupleType_T [ IntType_T; FloatType_T; BoolType_T ] in
    let nested_tuple = TupleType_T [ simple_tuple; StringType_T ] in

    TestUtils.check_type_equal "简单元组类型自身相等" simple_tuple simple_tuple;
    TestUtils.check_type_equal "复杂元组类型自身相等" complex_tuple complex_tuple;
    TestUtils.check_type_not_equal "不同元组类型不等" simple_tuple complex_tuple;

    check bool "元组是复合类型" true (is_compound_type simple_tuple);
    check bool "嵌套元组是复合类型" true (is_compound_type nested_tuple)

  (** 测试列表类型定义和操作 *)
  let test_list_types () =
    let int_list = ListType_T IntType_T in
    let string_list = ListType_T StringType_T in
    let nested_list = ListType_T (ListType_T IntType_T) in

    TestUtils.check_type_equal "整数列表类型自身相等" int_list int_list;
    TestUtils.check_type_equal "字符串列表类型自身相等" string_list string_list;
    TestUtils.check_type_not_equal "不同列表类型不等" int_list string_list;

    check bool "列表是复合类型" true (is_compound_type int_list);
    check bool "嵌套列表是复合类型" true (is_compound_type nested_list)

  (** 测试记录类型定义和操作 *)
  let test_record_types () =
    let simple_record = RecordType_T [ ("名字", StringType_T); ("年龄", IntType_T) ] in
    let complex_record =
      RecordType_T [ ("用户", simple_record); ("活跃", BoolType_T); ("分数", FloatType_T) ]
    in

    TestUtils.check_type_equal "简单记录类型自身相等" simple_record simple_record;
    TestUtils.check_type_equal "复杂记录类型自身相等" complex_record complex_record;
    TestUtils.check_type_not_equal "不同记录类型不等" simple_record complex_record;

    check bool "记录是复合类型" true (is_compound_type simple_record);
    check bool "嵌套记录是复合类型" true (is_compound_type complex_record)

  (** 测试数组类型定义和操作 *)
  let test_array_types () =
    let int_array = ArrayType_T IntType_T in
    let string_array = ArrayType_T StringType_T in
    let nested_array = ArrayType_T (ArrayType_T BoolType_T) in

    TestUtils.check_type_equal "整数数组类型自身相等" int_array int_array;
    TestUtils.check_type_equal "字符串数组类型自身相等" string_array string_array;
    TestUtils.check_type_not_equal "不同数组类型不等" int_array string_array;

    check bool "数组是复合类型" true (is_compound_type int_array);
    check bool "嵌套数组是复合类型" true (is_compound_type nested_array)
end

(** 类型变量和泛型测试 *)
module TypeVariableTests = struct
  (** 测试类型变量的创建和管理 *)
  let test_type_variable_creation () =
    let var1 = new_type_var () in
    let var2 = new_type_var () in

    (* 每次调用应产生不同的类型变量 *)
    TestUtils.check_type_not_equal "不同类型变量不等" var1 var2;

    (* 类型变量应该自身相等 *)
    TestUtils.check_type_equal "类型变量自身相等" var1 var1;
    TestUtils.check_type_equal "类型变量自身相等2" var2 var2

  (** 测试类型变量包含检查 *)
  let test_type_variable_containment () =
    let var_type = new_type_var () in
    let var_name = match var_type with TypeVar_T name -> name | _ -> "unknown" in

    (* 测试类型变量包含自身 *)
    check bool "类型变量包含自身" true (contains_type_var var_name var_type);

    (* 测试基础类型不包含类型变量 *)
    check bool "整数类型不包含类型变量" false (contains_type_var var_name IntType_T);
    check bool "字符串类型不包含类型变量" false (contains_type_var var_name StringType_T);

    (* 测试复合类型中的类型变量包含 *)
    let fun_with_var = FunType_T (var_type, IntType_T) in
    let list_with_var = ListType_T var_type in
    check bool "包含类型变量的函数类型" true (contains_type_var var_name fun_with_var);
    check bool "包含类型变量的列表类型" true (contains_type_var var_name list_with_var)

  (** 测试自由变量提取 *)
  let test_free_variables_extraction () =
    let var1 = new_type_var () in
    let var2 = new_type_var () in
    let var1_name = match var1 with TypeVar_T name -> name | _ -> "unknown1" in
    let var2_name = match var2 with TypeVar_T name -> name | _ -> "unknown2" in

    (* 测试基础类型没有自由变量 *)
    let int_free_vars = free_vars IntType_T in
    check (list string) "整数类型没有自由变量" [] int_free_vars;

    (* 测试类型变量的自由变量 *)
    let var_free_vars = free_vars var1 in
    check bool "类型变量包含自身为自由变量" true (List.mem var1_name var_free_vars);

    (* 测试复合类型的自由变量 *)
    let fun_type = FunType_T (var1, var2) in
    let fun_free_vars = free_vars fun_type in
    check bool "函数类型包含参数类型变量" true (List.mem var1_name fun_free_vars);
    check bool "函数类型包含返回类型变量" true (List.mem var2_name fun_free_vars)
end

(** 类型转换和兼容性测试 *)
module TypeConversionTests = struct
  (** 测试类型字符串表示 *)
  let test_type_string_representation () =
    (* 测试基础类型的字符串表示 *)
    let int_str = string_of_typ IntType_T in
    let float_str = string_of_typ FloatType_T in
    let string_str = string_of_typ StringType_T in
    let bool_str = string_of_typ BoolType_T in
    let unit_str = string_of_typ UnitType_T in

    TestUtils.check_string_contains "整数类型包含中文名称" int_str "整数";
    TestUtils.check_string_contains "浮点数类型包含中文名称" float_str "浮点";
    TestUtils.check_string_contains "字符串类型包含中文名称" string_str "字符串";
    TestUtils.check_string_contains "布尔类型包含中文名称" bool_str "布尔";
    TestUtils.check_string_contains "空值类型包含中文名称" unit_str "空值";

    (* 测试复合类型的字符串表示 *)
    let fun_type = FunType_T (IntType_T, StringType_T) in
    let list_type = ListType_T BoolType_T in
    let tuple_type = TupleType_T [ IntType_T; StringType_T ] in

    let fun_str = string_of_typ fun_type in
    let list_str = string_of_typ list_type in
    let tuple_str = string_of_typ tuple_type in

    (* 检查字符串非空且有意义 *)
    check bool "函数类型字符串表示非空" true (String.length fun_str > 0);
    check bool "列表类型字符串表示非空" true (String.length list_str > 0);
    check bool "元组类型字符串表示非空" true (String.length tuple_str > 0);

    (* 不同类型应有不同的字符串表示 *)
    check bool "不同类型字符串表示不同1" false (String.equal int_str float_str);
    check bool "不同类型字符串表示不同2" false (String.equal fun_str list_str)

  (** 测试构造类型的字符串表示 *)
  let test_construct_type_representation () =
    let simple_construct = ConstructType_T ("选项", [ IntType_T ]) in
    let complex_construct = ConstructType_T ("结果", [ StringType_T; BoolType_T ]) in
    let no_args_construct = ConstructType_T ("空构造", []) in

    let simple_str = string_of_typ simple_construct in
    let complex_str = string_of_typ complex_construct in
    let no_args_str = string_of_typ no_args_construct in

    TestUtils.check_string_contains "简单构造类型包含名称" simple_str "选项";
    TestUtils.check_string_contains "复杂构造类型包含名称" complex_str "结果";
    check string "无参数构造类型直接显示名称" "空构造" no_args_str;

    check bool "构造类型字符串表示非空" true (String.length simple_str > 0);
    check bool "不同构造类型字符串表示不同" false (String.equal simple_str complex_str)
end

(** 高级类型特性测试 *)
module AdvancedTypeTests = struct
  (** 测试引用类型定义和操作 *)
  let test_reference_types () =
    let int_ref = RefType_T IntType_T in
    let string_ref = RefType_T StringType_T in
    let nested_ref = RefType_T (RefType_T BoolType_T) in

    TestUtils.check_type_equal "整数引用类型自身相等" int_ref int_ref;
    TestUtils.check_type_not_equal "不同引用类型不等" int_ref string_ref;

    check bool "引用是复合类型" true (is_compound_type int_ref);
    check bool "嵌套引用是复合类型" true (is_compound_type nested_ref);

    (* 测试引用类型的字符串表示 *)
    let ref_str = string_of_typ int_ref in
    check bool "引用类型字符串表示非空" true (String.length ref_str > 0)

  (** 测试类类型和对象类型 *)
  let test_class_and_object_types () =
    let class_type = ClassType_T ("用户类", [ ("获取名字", FunType_T (UnitType_T, StringType_T)) ]) in
    let object_type = ObjectType_T [ ("名字", StringType_T); ("年龄", IntType_T) ] in

    TestUtils.check_type_equal "类类型自身相等" class_type class_type;
    TestUtils.check_type_equal "对象类型自身相等" object_type object_type;
    TestUtils.check_type_not_equal "类类型与对象类型不等" class_type object_type;

    check bool "类是复合类型" true (is_compound_type class_type);
    check bool "对象是复合类型" true (is_compound_type object_type);

    (* 测试字符串表示 *)
    let class_str = string_of_typ class_type in
    let object_str = string_of_typ object_type in
    TestUtils.check_string_contains "类类型包含类名" class_str "用户类";
    check bool "对象类型字符串表示非空" true (String.length object_str > 0)

  (** 测试私有类型和多态变体类型 *)
  let test_private_and_variant_types () =
    let private_type = PrivateType_T ("私有整数", IntType_T) in
    let variant_type =
      PolymorphicVariantType_T [ ("成功", Some StringType_T); ("失败", None); ("警告", Some IntType_T) ]
    in

    TestUtils.check_type_equal "私有类型自身相等" private_type private_type;
    TestUtils.check_type_equal "变体类型自身相等" variant_type variant_type;
    TestUtils.check_type_not_equal "私有类型与变体类型不等" private_type variant_type;

    check bool "私有类型是复合类型" true (is_compound_type private_type);
    check bool "变体类型是复合类型" true (is_compound_type variant_type);

    (* 测试字符串表示 *)
    let private_str = string_of_typ private_type in
    let variant_str = string_of_typ variant_type in
    check string "私有类型显示名称" "私有整数" private_str;
    TestUtils.check_string_contains "变体类型包含标签" variant_str "成功"
end

(** 类型环境和替换测试 *)
module TypeEnvironmentTests = struct
  (** 测试类型替换操作 *)
  let test_type_substitution () =
    (* 测试空替换 *)
    let empty = empty_subst in
    check bool "空替换为空映射" true (SubstMap.is_empty empty);

    (* 测试单一替换 *)
    let single = single_subst "a" IntType_T in
    check bool "单一替换非空" false (SubstMap.is_empty single);
    check bool "单一替换包含指定变量" true (SubstMap.mem "a" single);

    (* 测试查找替换 *)
    let found_type = SubstMap.find "a" single in
    TestUtils.check_type_equal "替换中找到正确类型" IntType_T found_type

  (** 测试类型方案 *)
  let test_type_schemes () =
    let simple_scheme = TypeScheme ([], IntType_T) in
    let generic_scheme = TypeScheme ([ "a"; "b" ], FunType_T (TypeVar_T "a", TypeVar_T "b")) in

    (* 类型方案应该能正确创建 *)
    let (TypeScheme (vars1, typ1)) = simple_scheme in
    let (TypeScheme (vars2, typ2)) = generic_scheme in

    check (list string) "简单方案无类型变量" [] vars1;
    TestUtils.check_type_equal "简单方案类型正确" IntType_T typ1;

    check (list string) "泛型方案有类型变量" [ "a"; "b" ] vars2;
    check bool "泛型方案类型包含变量" true (match typ2 with FunType_T _ -> true | _ -> false)

  (** 测试类型环境操作 *)
  let test_type_environment () =
    let empty_env : env = TypeEnv.empty in
    let simple_scheme = TypeScheme ([], StringType_T) in
    let env_with_var = TypeEnv.add "变量名" simple_scheme empty_env in

    check bool "空环境为空" true (TypeEnv.is_empty empty_env);
    check bool "添加变量后环境非空" false (TypeEnv.is_empty env_with_var);
    check bool "环境包含添加的变量" true (TypeEnv.mem "变量名" env_with_var);

    (* 测试查找环境中的变量 *)
    let found_scheme = TypeEnv.find "变量名" env_with_var in
    let (TypeScheme (_, found_type)) = found_scheme in
    TestUtils.check_type_equal "环境中找到正确类型" StringType_T found_type
end

(** 主测试套件 *)
let () =
  run "骆言核心类型系统基础测试"
    [
      ( "基础类型定义测试",
        [
          test_case "基础类型创建" `Quick BasicTypeTests.test_basic_type_creation;
          test_case "基础类型相等性" `Quick BasicTypeTests.test_basic_type_equality;
          test_case "基础类型判断函数" `Quick BasicTypeTests.test_basic_type_predicates;
        ] );
      ( "复合类型定义测试",
        [
          test_case "函数类型" `Quick CompoundTypeTests.test_function_types;
          test_case "元组类型" `Quick CompoundTypeTests.test_tuple_types;
          test_case "列表类型" `Quick CompoundTypeTests.test_list_types;
          test_case "记录类型" `Quick CompoundTypeTests.test_record_types;
          test_case "数组类型" `Quick CompoundTypeTests.test_array_types;
        ] );
      ( "类型变量和泛型测试",
        [
          test_case "类型变量创建" `Quick TypeVariableTests.test_type_variable_creation;
          test_case "类型变量包含检查" `Quick TypeVariableTests.test_type_variable_containment;
          test_case "自由变量提取" `Quick TypeVariableTests.test_free_variables_extraction;
        ] );
      ( "类型转换和兼容性测试",
        [
          test_case "类型字符串表示" `Quick TypeConversionTests.test_type_string_representation;
          test_case "构造类型表示" `Quick TypeConversionTests.test_construct_type_representation;
        ] );
      ( "高级类型特性测试",
        [
          test_case "引用类型" `Quick AdvancedTypeTests.test_reference_types;
          test_case "类和对象类型" `Quick AdvancedTypeTests.test_class_and_object_types;
          test_case "私有类型和变体类型" `Quick AdvancedTypeTests.test_private_and_variant_types;
        ] );
      ( "类型环境和替换测试",
        [
          test_case "类型替换操作" `Quick TypeEnvironmentTests.test_type_substitution;
          test_case "类型方案" `Quick TypeEnvironmentTests.test_type_schemes;
          test_case "类型环境操作" `Quick TypeEnvironmentTests.test_type_environment;
        ] );
    ]
