(** 全面的List_utils模块测试 *)

open Alcotest
open Yyocamlc_lib.List_utils

(** 测试Safe模块的head函数 *)
let test_safe_head () = 
  check (option int) "empty list" None (Safe.head []);
  check (option int) "single element" (Some 1) (Safe.head [1]);
  check (option int) "multiple elements" (Some 1) (Safe.head [1; 2; 3])

(** 测试Safe模块的tail函数 *)
let test_safe_tail () =
  check (option (list int)) "empty list" None (Safe.tail []);
  check (option (list int)) "single element" (Some []) (Safe.tail [1]);
  check (option (list int)) "multiple elements" (Some [2; 3]) (Safe.tail [1; 2; 3])

(** 测试Safe模块的nth函数 *)
let test_safe_nth () =
  let lst = [10; 20; 30; 40] in
  check (option int) "negative index" None (Safe.nth lst (-1));
  check (option int) "index 0" (Some 10) (Safe.nth lst 0);
  check (option int) "index 2" (Some 30) (Safe.nth lst 2);
  check (option int) "index out of bounds" None (Safe.nth lst 10);
  check (option int) "empty list" None (Safe.nth [] 0)

(** 测试Safe模块的last函数 *)
let test_safe_last () =
  check (option int) "empty list" None (Safe.last []);
  check (option int) "single element" (Some 1) (Safe.last [1]);
  check (option int) "multiple elements" (Some 3) (Safe.last [1; 2; 3])

(** 测试Safe模块的init函数 *)
let test_safe_init () =
  check (option (list int)) "empty list" None (Safe.init []);
  check (option (list int)) "single element" (Some []) (Safe.init [1]);
  check (option (list int)) "multiple elements" (Some [1; 2]) (Safe.init [1; 2; 3])

(** 测试Transform模块的mapi_safe函数 *)
let test_transform_mapi_safe () =
  let f i x = if x mod 2 = 0 then Some (i + x) else None in
  check (list int) "filter and map with index" [3; 7] (Transform.mapi_safe f [1; 2; 3; 4]);
  check (list int) "empty list" [] (Transform.mapi_safe f []);
  check (list int) "all filtered out" [] (Transform.mapi_safe f [1; 3; 5])

(** 测试Transform模块的filter_map函数 *)
let test_transform_filter_map () =
  let f x = if x > 0 then Some (x * 2) else None in
  check (list int) "filter and map positive" [2; 4; 6] (Transform.filter_map f [1; -1; 2; -2; 3]);
  check (list int) "empty list" [] (Transform.filter_map f []);
  check (list int) "all filtered out" [] (Transform.filter_map f [-1; -2; -3])

(** 测试either类型 *)
let test_either_type () =
  let left_val = Left "error" in
  let right_val = Right 42 in
  check bool "left variant" true (match left_val with Left _ -> true | Right _ -> false);
  check bool "right variant" true (match right_val with Left _ -> false | Right _ -> true)

(** 测试边界条件 *)
let test_edge_cases () =
  (* 测试大列表 *)
  let large_list = List.init 1000 (fun i -> i) in
  check (option int) "large list head" (Some 0) (Safe.head large_list);
  check (option int) "large list last" (Some 999) (Safe.last large_list);
  check (option int) "large list nth middle" (Some 500) (Safe.nth large_list 500);
  
  (* 测试性能敏感操作 *)
  let result = Transform.filter_map (fun x -> if x mod 100 = 0 then Some x else None) large_list in
  check int "filter large list length" 10 (List.length result)

(** 测试复杂数据类型 *)
let test_complex_types () =
  let string_list = ["hello"; "world"; "test"] in
  check (option string) "string list head" (Some "hello") (Safe.head string_list);
  
  let tuple_list = [(1, "a"); (2, "b"); (3, "c")] in
  check (option (pair int string)) "tuple list last" (Some (3, "c")) (Safe.last tuple_list);
  
  let nested = [[1; 2]; [3; 4]; [5; 6]] in
  check (option (list int)) "nested list nth" (Some [3; 4]) (Safe.nth nested 1)

(** 压力测试：测试所有组合 *)
let test_combinations () =
  let lst = [1; 2; 3; 4; 5] in
  (* 测试Safe模块的所有函数组合 *)
  match Safe.head lst with
  | None -> check bool "unexpected None" false true
  | Some _h -> 
    match Safe.tail lst with
    | None -> check bool "unexpected None for tail" false true  
    | Some t ->
      check (option int) "head of tail" (Some 2) (Safe.head t);
      check (option int) "last of original" (Some 5) (Safe.last lst);
      check (option (list int)) "init of original" (Some [1; 2; 3; 4]) (Safe.init lst)

let tests = [
  ("safe_head", `Quick, test_safe_head);
  ("safe_tail", `Quick, test_safe_tail);
  ("safe_nth", `Quick, test_safe_nth);
  ("safe_last", `Quick, test_safe_last);
  ("safe_init", `Quick, test_safe_init);
  ("transform_mapi_safe", `Quick, test_transform_mapi_safe);
  ("transform_filter_map", `Quick, test_transform_filter_map);
  ("either_type", `Quick, test_either_type);
  ("edge_cases", `Quick, test_edge_cases);
  ("complex_types", `Quick, test_complex_types);
  ("combinations", `Quick, test_combinations);
]

let () = run "List_utils Comprehensive" [ ("list_utils", tests) ]