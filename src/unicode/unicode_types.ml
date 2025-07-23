(** Unicode字符类型定义和字符数据 *)

type utf8_triple = { byte1 : int; byte2 : int; byte3 : int }
(** UTF-8字符三字节组合类型 *)

type utf8_char_def = {
  name : string;  (** 字符名称 *)
  char : string;  (** 实际字符 *)
  triple : utf8_triple;  (** UTF-8字节组合 *)
  category : string;  (** 字符类别 *)
}
(** UTF-8字符定义记录 *)

(** 中文字符范围检测常量 *)
module Range = struct
  let chinese_char_start = 0xE4
  let chinese_char_mid_start = 0xE5
  let chinese_char_mid_end = 0xE9
  let chinese_char_threshold = 128
end

(** UTF-8字符前缀常量 *)
module Prefix = struct
  let chinese_punctuation = 0xE3 (* 中文标点符号 *)
  let chinese_operator = 0xE8 (* 中文操作符 *)
  let arrow_symbol = 0xE2 (* 箭头符号 *)
  let fullwidth = 0xEF (* 全角符号 *)
end

(** JSON数据加载器 *)
module DataLoader = struct
  let find_data_file () =
    let candidates =
      [
        "unicode_chars.json";
        (* 当前目录 *)
        "src/unicode/unicode_chars.json";
        (* 从项目根目录 *)
        "../unicode_chars.json";
        (* 从test目录 *)
        "../../src/unicode/unicode_chars.json";
        (* 从深层test目录 *)
        "data/unicode_chars.json";
        (* 原始数据目录 *)
        "../../../data/unicode_chars.json";
        (* 从build目录访问 *)
      ]
    in
    List.find (fun path -> Sys.file_exists path) candidates

  let parse_triple json =
    let open Yojson.Basic.Util in
    {
      byte1 = json |> member "byte1" |> to_int;
      byte2 = json |> member "byte2" |> to_int;
      byte3 = json |> member "byte3" |> to_int;
    }

  let parse_char_def json =
    let open Yojson.Basic.Util in
    {
      name = json |> member "name" |> to_string;
      char = json |> member "char" |> to_string;
      triple = json |> member "triple" |> parse_triple;
      category = json |> member "category" |> to_string;
    }

  let load_char_definitions () =
    try
      let data_file = find_data_file () in
      let json = Yojson.Basic.from_file data_file in
      let open Yojson.Basic.Util in
      let definitions = json |> member "unicode_char_definitions" in
      let categories = [ "quote"; "string"; "punctuation"; "number" ] in
      (* 性能优化：使用 :: 操作替代 @ 操作，避免 O(n²) 复杂度 *)
      List.fold_left
        (fun acc category ->
          let chars = definitions |> member category |> to_list in
          let parsed_chars = List.map parse_char_def chars in
          parsed_chars :: acc)
        [] categories
      |> List.concat |> List.rev
    with
    | Not_found ->
        Printf.eprintf "警告: 无法找到Unicode字符定义文件\n";
        []
    | Sys_error msg ->
        Printf.eprintf "警告: 无法加载Unicode字符定义文件: %s\n" msg;
        []
    | Yojson.Json_error msg ->
        Printf.eprintf "警告: JSON解析错误: %s\n" msg;
        []
end

(** 字符定义数据表 - 从JSON文件加载的结构化Unicode字符数据 *)
let char_definitions = DataLoader.load_char_definitions ()
