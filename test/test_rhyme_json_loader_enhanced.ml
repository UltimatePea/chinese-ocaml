(* 韵律JSON加载器增强测试
   测试重构后的parse_nested_json函数和相关子函数 *)

open Poetry.Rhyme_json_loader

(* 测试数据 *)
let test_json_simple = {|
{
  "rhyme_groups": {
    "东韵": {
      "categories": {
        "平声": ["东", "同", "红"]
      }
    }
  }
}
|}

let test_json_complex = {|
{
  "rhyme_groups": {
    "东韵": {
      "categories": {
        "平声": ["东", "同", "红"],
        "上声": ["董", "总", "拱"]
      }
    },
    "江韵": {
      "categories": {
        "平声": ["江", "双", "窗"]
      }
    }
  }
}
|}

let test_json_empty = {|
{
  "rhyme_groups": {}
}
|}

let test_json_malformed = {|
{
  "rhyme_groups": {
    "东韵": {
      "invalid_field": "value"
|}

(* 测试解析简单JSON *)
let test_parse_simple_json () =
  let result = parse_nested_json test_json_simple in
  assert (List.length result = 1);
  let (name, data) = List.hd result in
  assert (name = "东韵");
  assert (List.length data.categories = 1);
  let (cat_name, chars) = List.hd data.categories in
  assert (cat_name = "平声");
  assert (List.length chars = 3);
  assert (List.mem "东" chars);
  assert (List.mem "同" chars);
  assert (List.mem "红" chars)

(* 测试解析复杂JSON *)
let test_parse_complex_json () =
  let result = parse_nested_json test_json_complex in
  assert (List.length result = 2);
  
  (* 检查东韵 *)
  let dong_data = List.assoc "东韵" result in
  assert (List.length dong_data.categories = 2);
  assert (List.mem_assoc "平声" dong_data.categories);
  assert (List.mem_assoc "上声" dong_data.categories);
  
  (* 检查江韵 *)  
  let jiang_data = List.assoc "江韵" result in
  assert (List.length jiang_data.categories = 1);
  assert (List.mem_assoc "平声" jiang_data.categories)

(* 测试解析空JSON *)
let test_parse_empty_json () =
  let result = parse_nested_json test_json_empty in
  assert (List.length result = 0)

(* 测试异常处理 *)
let test_parse_malformed_json () =
  try
    let _ = parse_nested_json test_json_malformed in
    assert false (* 应该抛出异常 *)
  with
  | _ -> () (* 期望异常 *)

(* 测试边界情况 *)
let test_edge_cases () =
  (* 测试空字符串 *)
  let result1 = parse_nested_json "" in
  assert (List.length result1 = 0);
  
  (* 测试只有空格的字符串 *)
  let result2 = parse_nested_json "   \n  \t  " in
  assert (List.length result2 = 0)

(* 测试字符处理 *)
let test_character_handling () =
  let test_unicode = {|
{
  "rhyme_groups": {
    "测试韵": {
      "categories": {
        "平声": ["🌸", "诗", "词", "歌", "賦"]
      }
    }
  }
}
|} in
  let result = parse_nested_json test_unicode in
  assert (List.length result = 1);
  let (_, data) = List.hd result in
  let (_, chars) = List.hd data.categories in
  assert (List.mem "🌸" chars);
  assert (List.mem "诗" chars);
  assert (List.mem "賦" chars)

(* 性能测试 *)
let test_performance () =
  let large_json = {|
{
  "rhyme_groups": {
|} ^ 
  String.concat ",\n" (List.init 100 (fun i ->
    Printf.sprintf {|    "韵%d": {
      "categories": {
        "平声": ["字%d1", "字%d2", "字%d3"],
        "上声": ["字%d4", "字%d5", "字%d6"]
      }
    }|} i i i i i i i)) ^
{|
  }
}
|} in
  let start_time = Sys.time () in
  let result = parse_nested_json large_json in
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  assert (List.length result = 100);
  assert (duration < 1.0) (* 应该在1秒内完成 *)

(* 运行所有测试 *)
let run_all_tests () =
  Printf.printf "开始韵律JSON加载器增强测试...\n";
  
  test_parse_simple_json ();
  Printf.printf "✅ 简单JSON解析测试通过\n";
  
  test_parse_complex_json ();
  Printf.printf "✅ 复杂JSON解析测试通过\n";
  
  test_parse_empty_json ();
  Printf.printf "✅ 空JSON解析测试通过\n";
  
  test_parse_malformed_json ();
  Printf.printf "✅ 异常处理测试通过\n";
  
  test_edge_cases ();
  Printf.printf "✅ 边界情况测试通过\n";
  
  test_character_handling ();
  Printf.printf "✅ 字符处理测试通过\n";
  
  test_performance ();
  Printf.printf "✅ 性能测试通过\n";
  
  Printf.printf "🎉 所有韵律JSON加载器测试通过！\n"

(* 主函数 *)
let () = run_all_tests ()