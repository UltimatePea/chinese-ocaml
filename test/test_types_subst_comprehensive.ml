(** 骆言类型系统 - 类型替换模块comprehensive测试 *)

open Alcotest
open Yyocamlc_lib.Core_types
open Yyocamlc_lib.Types_subst

(** ========== 测试辅助函数 ========== *)

(** 创建测试用的类型变量 *)
let create_type_var name = TypeVar_T name

(** 创建测试用的函数类型 *)
let create_fun_type param ret = FunType_T (param, ret)

(** 创建测试用的元组类型 *)
let create_tuple_type types = TupleType_T types

(** 创建测试用的列表类型 *)
let create_list_type elem = ListType_T elem

(** 创建测试用的替换 *)
let create_subst bindings =
  List.fold_left (fun acc (var, typ) -> SubstMap.add var typ acc) empty_subst bindings

(** 创建测试用的类型方案 *)
let create_scheme vars typ = TypeScheme (vars, typ)

(** 创建测试用的类型环境 *)
let create_env bindings =
  List.fold_left (fun acc (name, scheme) -> TypeEnv.add name scheme acc) TypeEnv.empty bindings

(** 类型相等性测试 *)
let type_testable = testable (fun fmt t -> Fmt.string fmt (string_of_typ t)) ( = )

(** ========== 基础类型替换测试 ========== *)

(** 测试基础类型替换不受影响 *)
let test_apply_subst_base_types () =
  let subst = create_subst [ ("'a", IntType_T) ] in
  check type_testable "基础类型不变-IntType" IntType_T (apply_subst subst IntType_T);
  check type_testable "基础类型不变-FloatType" FloatType_T (apply_subst subst FloatType_T);
  check type_testable "基础类型不变-StringType" StringType_T (apply_subst subst StringType_T);
  check type_testable "基础类型不变-BoolType" BoolType_T (apply_subst subst BoolType_T);
  check type_testable "基础类型不变-UnitType" UnitType_T (apply_subst subst UnitType_T)

(** 测试类型变量替换 *)
let test_apply_subst_type_vars () =
  let subst = create_subst [ ("'a", IntType_T); ("'b", StringType_T) ] in
  (* 替换存在的类型变量 *)
  check type_testable "替换存在变量'a" IntType_T (apply_subst subst (create_type_var "'a"));
  check type_testable "替换存在变量'b" StringType_T (apply_subst subst (create_type_var "'b"));
  (* 不替换不存在的类型变量 *)
  check type_testable "保持不存在变量'c" (create_type_var "'c") (apply_subst subst (create_type_var "'c"))

(** 测试函数类型替换 *)
let test_apply_subst_function_types () =
  let subst = create_subst [ ("'a", IntType_T); ("'b", StringType_T) ] in
  let fun_type = create_fun_type (create_type_var "'a") (create_type_var "'b") in
  let expected = create_fun_type IntType_T StringType_T in
  check type_testable "函数类型替换" expected (apply_subst subst fun_type)

(** 测试元组类型替换 *)
let test_apply_subst_tuple_types () =
  let subst = create_subst [ ("'a", IntType_T); ("'b", StringType_T) ] in
  let tuple_type = create_tuple_type [ create_type_var "'a"; create_type_var "'b"; BoolType_T ] in
  let expected = create_tuple_type [ IntType_T; StringType_T; BoolType_T ] in
  check type_testable "元组类型替换" expected (apply_subst subst tuple_type)

(** 测试列表类型替换 *)
let test_apply_subst_list_types () =
  let subst = create_subst [ ("'a", IntType_T) ] in
  let list_type = create_list_type (create_type_var "'a") in
  let expected = create_list_type IntType_T in
  check type_testable "列表类型替换" expected (apply_subst subst list_type)

(** 测试构造类型替换 *)
let test_apply_subst_construct_types () =
  let subst = create_subst [ ("'a", IntType_T) ] in
  let construct_type = ConstructType_T ("Option", [ create_type_var "'a" ]) in
  let expected = ConstructType_T ("Option", [ IntType_T ]) in
  check type_testable "构造类型替换" expected (apply_subst subst construct_type)

(** 测试引用类型替换 *)
let test_apply_subst_ref_types () =
  let subst = create_subst [ ("'a", IntType_T) ] in
  let ref_type = RefType_T (create_type_var "'a") in
  let expected = RefType_T IntType_T in
  check type_testable "引用类型替换" expected (apply_subst subst ref_type)

(** 测试记录类型替换 *)
let test_apply_subst_record_types () =
  let subst = create_subst [ ("'a", IntType_T); ("'b", StringType_T) ] in
  let record_type = RecordType_T [ ("x", create_type_var "'a"); ("y", create_type_var "'b") ] in
  let expected = RecordType_T [ ("x", IntType_T); ("y", StringType_T) ] in
  check type_testable "记录类型替换" expected (apply_subst subst record_type)

(** 测试数组类型替换 *)
let test_apply_subst_array_types () =
  let subst = create_subst [ ("'a", IntType_T) ] in
  let array_type = ArrayType_T (create_type_var "'a") in
  let expected = ArrayType_T IntType_T in
  check type_testable "数组类型替换" expected (apply_subst subst array_type)

(** ========== 类型方案替换测试 ========== *)

(** 测试类型方案替换 - 不冲突情况 *)
let test_apply_subst_to_scheme_no_conflict () =
  let subst = create_subst [ ("'a", IntType_T); ("'b", StringType_T) ] in
  let scheme =
    create_scheme [ "'c" ] (create_fun_type (create_type_var "'a") (create_type_var "'c"))
  in
  let expected = create_scheme [ "'c" ] (create_fun_type IntType_T (create_type_var "'c")) in
  let actual = apply_subst_to_scheme subst scheme in
  check
    (testable
       (fun fmt (TypeScheme (vars, typ)) ->
         Fmt.string fmt (String.concat "," vars ^ " -> " ^ string_of_typ typ))
       ( = ))
    "类型方案替换无冲突" expected actual

(** 测试类型方案替换 - 冲突情况 *)
let test_apply_subst_to_scheme_with_conflict () =
  let subst = create_subst [ ("'a", IntType_T); ("'b", StringType_T) ] in
  let scheme =
    create_scheme [ "'a"; "'c" ] (create_fun_type (create_type_var "'a") (create_type_var "'b"))
  in
  (* 'a被绑定，不应该被替换；'b未绑定，应该被替换 *)
  let expected =
    create_scheme [ "'a"; "'c" ] (create_fun_type (create_type_var "'a") StringType_T)
  in
  let actual = apply_subst_to_scheme subst scheme in
  check
    (testable
       (fun fmt (TypeScheme (vars, typ)) ->
         Fmt.string fmt (String.concat "," vars ^ " -> " ^ string_of_typ typ))
       ( = ))
    "类型方案替换有冲突" expected actual

(** ========== 替换合成测试 ========== *)

(** 测试基础替换合成 *)
let test_compose_subst_basic () =
  let subst1 = create_subst [ ("'a", IntType_T); ("'b", create_type_var "'c") ] in
  let subst2 = create_subst [ ("'c", StringType_T); ("'d", BoolType_T) ] in
  let composed = compose_subst subst1 subst2 in

  (* 检查'a -> IntType_T (来自subst1) *)
  check type_testable "合成替换'a" IntType_T (apply_subst composed (create_type_var "'a"));
  (* 检查'b -> 'c (subst1中'b -> 'c，subst1优先级高) *)
  check type_testable "合成替换'b" (create_type_var "'c") (apply_subst composed (create_type_var "'b"));
  (* 检查'd -> BoolType_T (来自subst2) *)
  check type_testable "合成替换'd" BoolType_T (apply_subst composed (create_type_var "'d"));
  (* 检查'c -> StringType_T (来自subst2，因为subst1中没有'c的绑定) *)
  check type_testable "合成替换'c" StringType_T (apply_subst composed (create_type_var "'c"))

(** 测试替换合成优先级 *)
let test_compose_subst_priority () =
  let subst1 = create_subst [ ("'a", IntType_T) ] in
  let subst2 = create_subst [ ("'a", StringType_T) ] in
  let composed = compose_subst subst1 subst2 in
  (* subst1应该有优先级 *)
  check type_testable "合成优先级" IntType_T (apply_subst composed (create_type_var "'a"))

(** ========== 类型泛化测试 ========== *)

(** 测试基础类型泛化 *)
let test_generalize_basic () =
  let env = TypeEnv.empty in
  let typ = create_fun_type (create_type_var "'a") (create_type_var "'b") in
  let scheme = generalize env typ in
  let expected = create_scheme [ "'a"; "'b" ] typ in
  check
    (testable
       (fun fmt (TypeScheme (vars, typ)) ->
         Fmt.string fmt (String.concat "," vars ^ " -> " ^ string_of_typ typ))
       ( = ))
    "基础泛化" expected scheme

(** 测试有环境约束的泛化 *)
let test_generalize_with_env () =
  let env = create_env [ ("x", create_scheme [] (create_type_var "'a")) ] in
  let typ = create_fun_type (create_type_var "'a") (create_type_var "'b") in
  let scheme = generalize env typ in
  (* 'a在环境中，不应该被泛化 *)
  let expected = create_scheme [ "'b" ] typ in
  check
    (testable
       (fun fmt (TypeScheme (vars, typ)) ->
         Fmt.string fmt (String.concat "," vars ^ " -> " ^ string_of_typ typ))
       ( = ))
    "环境约束泛化" expected scheme

(** ========== 类型方案实例化测试 ========== *)

(** 测试基础类型方案实例化 *)
let test_instantiate_basic () =
  let scheme =
    create_scheme [ "'a"; "'b" ] (create_fun_type (create_type_var "'a") (create_type_var "'b"))
  in
  let instantiated = instantiate scheme in

  (* 检查结构相同但类型变量不同 *)
  match instantiated with
  | FunType_T (TypeVar_T var1, TypeVar_T var2) ->
      (* 应该是新的类型变量 *)
      check bool "实例化产生新变量" true (var1 <> "'a" && var2 <> "'b" && var1 <> var2)
  | _ -> fail "实例化结果应该是函数类型"

(** 测试无量化变量的实例化 *)
let test_instantiate_no_quantified () =
  let scheme = create_scheme [] IntType_T in
  let instantiated = instantiate scheme in
  check type_testable "无量化变量实例化" IntType_T instantiated

(** ========== 边界条件和错误处理测试 ========== *)

(** 测试空替换 *)
let test_empty_subst () =
  let typ = create_type_var "'a" in
  check type_testable "空替换" typ (apply_subst empty_subst typ)

(** 测试深度嵌套类型替换 *)
let test_deep_nested_types () =
  let subst = create_subst [ ("'a", IntType_T) ] in
  let deep_type = create_list_type (create_list_type (create_list_type (create_type_var "'a"))) in
  let expected = create_list_type (create_list_type (create_list_type IntType_T)) in
  check type_testable "深度嵌套替换" expected (apply_subst subst deep_type)

(** ========== 集成测试 ========== *)

(** 测试替换和泛化的集成 *)
let test_subst_generalize_integration () =
  let env = TypeEnv.empty in
  let subst = create_subst [ ("'a", IntType_T) ] in
  let typ = create_fun_type (create_type_var "'a") (create_type_var "'b") in

  (* 先应用替换，再泛化 *)
  let substituted = apply_subst subst typ in
  let generalized = generalize env substituted in

  let expected = create_scheme [ "'b" ] (create_fun_type IntType_T (create_type_var "'b")) in
  check
    (testable
       (fun fmt (TypeScheme (vars, typ)) ->
         Fmt.string fmt (String.concat "," vars ^ " -> " ^ string_of_typ typ))
       ( = ))
    "替换泛化集成" expected generalized

(** ========== 测试套件定义 ========== *)

let basic_substitution_tests =
  [
    ("基础类型替换不受影响", `Quick, test_apply_subst_base_types);
    ("类型变量替换", `Quick, test_apply_subst_type_vars);
    ("函数类型替换", `Quick, test_apply_subst_function_types);
    ("元组类型替换", `Quick, test_apply_subst_tuple_types);
    ("列表类型替换", `Quick, test_apply_subst_list_types);
    ("构造类型替换", `Quick, test_apply_subst_construct_types);
    ("引用类型替换", `Quick, test_apply_subst_ref_types);
    ("记录类型替换", `Quick, test_apply_subst_record_types);
    ("数组类型替换", `Quick, test_apply_subst_array_types);
  ]

let scheme_substitution_tests =
  [
    ("类型方案替换无冲突", `Quick, test_apply_subst_to_scheme_no_conflict);
    ("类型方案替换有冲突", `Quick, test_apply_subst_to_scheme_with_conflict);
  ]

let composition_tests =
  [ ("基础替换合成", `Quick, test_compose_subst_basic); ("替换合成优先级", `Quick, test_compose_subst_priority) ]

let generalization_tests =
  [ ("基础类型泛化", `Quick, test_generalize_basic); ("有环境约束的泛化", `Quick, test_generalize_with_env) ]

let instantiation_tests =
  [
    ("基础类型方案实例化", `Quick, test_instantiate_basic);
    ("无量化变量的实例化", `Quick, test_instantiate_no_quantified);
  ]

let boundary_tests =
  [ ("空替换测试", `Quick, test_empty_subst); ("深度嵌套类型替换", `Quick, test_deep_nested_types) ]

let integration_tests = [ ("替换和泛化集成", `Quick, test_subst_generalize_integration) ]

let suite =
  [
    ("基础类型替换", basic_substitution_tests);
    ("类型方案替换", scheme_substitution_tests);
    ("替换合成", composition_tests);
    ("类型泛化", generalization_tests);
    ("类型方案实例化", instantiation_tests);
    ("边界条件", boundary_tests);
    ("集成测试", integration_tests);
  ]

(** 运行测试的主函数 *)
let () = run "骆言类型替换模块comprehensive测试" suite
