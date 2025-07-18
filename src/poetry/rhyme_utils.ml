(* 音韵工具模块 - 骆言诗词编程特性
   盖古之诗者，音韵为要。声韵调谐，方称佳构。
   此模块专司音韵分析辅助工具，提供字符处理等基础功能。
   凡诗词编程，必先备工具，后成大器。
*)

(* 简单的UTF-8字符列表转换函数 *)
let utf8_to_char_list s =
  let rec aux acc i =
    if i >= String.length s then List.rev acc else aux (String.make 1 s.[i] :: acc) (i + 1)
  in
  aux [] 0

(* 字符串转字符列表 *)
let string_to_char_list s =
  let rec aux acc i = if i >= String.length s then List.rev acc else aux (s.[i] :: acc) (i + 1) in
  aux [] 0

(* 字符列表转字符串 *)
let char_list_to_string chars =
  let buf = Buffer.create (List.length chars) in
  List.iter (Buffer.add_char buf) chars;
  Buffer.contents buf

(* 获取字符串的最后一个字符 *)
let get_last_char s = if String.length s = 0 then None else Some s.[String.length s - 1]

(* 获取字符串的第一个字符 *)
let get_first_char s = if String.length s = 0 then None else Some s.[0]

(* 移除字符串中的空白字符 *)
let trim_whitespace s =
  let rec trim_left i =
    if i >= String.length s then ""
    else if s.[i] = ' ' || s.[i] = '\t' || s.[i] = '\n' || s.[i] = '\r' then trim_left (i + 1)
    else
      let rec trim_right j =
        if j < i then ""
        else if s.[j] = ' ' || s.[j] = '\t' || s.[j] = '\n' || s.[j] = '\r' then trim_right (j - 1)
        else String.sub s i (j - i + 1)
      in
      trim_right (String.length s - 1)
  in
  trim_left 0

(* 判断字符是否为中文字符 *)
let is_chinese_char c =
  let code = Char.code c in
  (* 简单的中文字符范围判断 *)
  code >= 0x4e00 && code <= 0x9fff

(* 过滤出中文字符 *)
let filter_chinese_chars s =
  let chars = string_to_char_list s in
  let chinese_chars = List.filter is_chinese_char chars in
  char_list_to_string chinese_chars

(* 计算字符串长度（中文字符） *)
let chinese_length s =
  let chars = string_to_char_list s in
  List.length (List.filter is_chinese_char chars)

(* 分割字符串为诗句 *)
let split_verse_lines text =
  let lines = String.split_on_char '\n' text in
  List.map trim_whitespace lines |> List.filter (fun line -> String.length line > 0)

(* 规范化诗句格式 *)
let normalize_verse verse = trim_whitespace verse |> filter_chinese_chars

(* 判断两个字符串是否相等（忽略空白） *)
let equal_ignoring_whitespace s1 s2 = String.equal (trim_whitespace s1) (trim_whitespace s2)

(* 安全获取列表元素 *)
let safe_nth list n = try Some (List.nth list n) with _ -> None

(* 安全获取列表头部 *)
let safe_head list = match list with [] -> None | h :: _ -> Some h

(* 安全获取列表尾部 *)
let safe_tail list = match list with [] -> None | _ :: t -> Some t

(* 列表去重 *)
let rec unique_list = function
  | [] -> []
  | h :: t -> if List.mem h t then unique_list t else h :: unique_list t

(* 计算两个列表的交集 *)
let intersect list1 list2 = List.filter (fun x -> List.mem x list2) list1

(* 计算两个列表的并集 *)
let union list1 list2 = unique_list (list1 @ list2)

(* 映射并过滤None值 *)
let filter_map f list =
  List.fold_right (fun x acc -> match f x with Some y -> y :: acc | None -> acc) list []

(* 字符串格式化辅助函数 *)
let format_list to_string separator list = String.concat separator (List.map to_string list)

(* 创建带编号的列表 *)
let enumerate list =
  let rec aux acc n = function [] -> List.rev acc | h :: t -> aux ((n, h) :: acc) (n + 1) t in
  aux [] 0 list

(* 检查字符串是否为空或仅包含空白字符 *)
let is_empty_or_whitespace s = String.length (trim_whitespace s) = 0
