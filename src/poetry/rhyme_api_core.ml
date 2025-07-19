(** 韵律API核心模块
    
    提供核心的韵律检测和查询API，包括韵类检测、韵组检测和基础押韵验证功能。
    
    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 - unified_rhyme_api.ml重构 *)

open Rhyme_types

(** {1 核心API函数} *)

(** 查找字符的韵律信息

    这是统一的韵律查找函数，替代项目中13处重复的find_rhyme_info实现。
    使用缓存提高查找效率，支持快速韵律检测。

    @param char 要查找的字符
    @return 韵类和韵组的组合，如果未找到则返回None *)
let find_rhyme_info char =
  Unified_rhyme_data.load_rhyme_data_to_cache ();
  Rhyme_cache.lookup_rhyme char

(** 检测字符的韵类

    统一的韵类检测函数，替代项目中多处重复的detect_rhyme_category实现。

    @param char 要检测的字符
    @return 韵类，如果无法检测则返回PingSheng作为默认值 *)
let detect_rhyme_category char =
  match find_rhyme_info char with 
  | Some (category, _) -> category 
  | None -> PingSheng (* 默认为平声 *)

(** 检测字符的韵组

    统一的韵组检测函数，替代项目中多处重复的detect_rhyme_group实现。

    @param char 要检测的字符
    @return 韵组，如果无法检测则返回UnknownRhyme *)
let detect_rhyme_group char =
  match find_rhyme_info char with 
  | Some (_, group) -> group 
  | None -> UnknownRhyme

(** 获取韵组包含的所有字符

    返回指定韵组包含的所有字符列表，用于韵律匹配和验证。

    @param group 韵组
    @return 字符列表 *)
let get_rhyme_characters group =
  Unified_rhyme_data.load_rhyme_data_to_cache ();
  match Rhyme_cache.lookup_rhyme_group_chars group with
  | Some chars -> chars
  | None -> []

(** 验证字符列表的韵律一致性

    检查字符列表是否属于同一韵组，用于诗词韵律验证。

    @param chars 字符列表
    @return 如果所有字符属于同一韵组则返回true *)
let validate_rhyme_consistency chars =
  match chars with
  | [] -> true
  | first :: rest ->
      let first_group = detect_rhyme_group first in
      if first_group = UnknownRhyme then false
      else List.for_all (fun char -> detect_rhyme_group char = first_group) rest

(** 检查两个字符是否押韵

    判断两个字符是否属于同一韵组，是基础的押韵检测函数。

    @param char1 第一个字符
    @param char2 第二个字符
    @return 如果两字符押韵则返回true *)
let check_rhyme char1 char2 =
  let group1 = detect_rhyme_group char1 in
  let group2 = detect_rhyme_group char2 in
  group1 <> UnknownRhyme && group2 <> UnknownRhyme && group1 = group2

(** 查找与给定字符押韵的所有字符

    返回与指定字符属于同一韵组的所有其他字符。

    @param char 参考字符
    @return 押韵字符列表 *)
let find_rhyming_characters char =
  let group = detect_rhyme_group char in
  if group = UnknownRhyme then []
  else
    let all_chars = get_rhyme_characters group in
    List.filter (fun c -> c <> char) all_chars

(** 检查字符是否为已知韵字

    验证字符是否在韵律数据库中有记录。

    @param char 要检查的字符
    @return 如果是已知韵字则返回true *)
let is_known_rhyme_char char =
  match find_rhyme_info char with
  | Some _ -> true
  | None -> false

(** 将韵组转换为字符串 *)
let string_of_rhyme_group = function
  | AnRhyme -> "安"
  | SiRhyme -> "思"  
  | TianRhyme -> "天"
  | WangRhyme -> "望"
  | QuRhyme -> "去"
  | FengRhyme -> "风"
  | YuRhyme -> "鱼"
  | HuaRhyme -> "花"
  | YueRhyme -> "月"
  | JiangRhyme -> "江"
  | HuiRhyme -> "会"
  | UnknownRhyme -> "未知"

(** 获取字符的韵律描述

    返回字符的韵类和韵组的文字描述。

    @param char 要描述的字符
    @return 韵律描述字符串 *)
let get_rhyme_description char =
  match find_rhyme_info char with
  | Some (PingSheng, group) -> Printf.sprintf "平声 %s韵" (string_of_rhyme_group group)
  | Some (ZeSheng, group) -> Printf.sprintf "仄声 %s韵" (string_of_rhyme_group group)
  | Some (ShangSheng, group) -> Printf.sprintf "上声 %s韵" (string_of_rhyme_group group)
  | Some (QuSheng, group) -> Printf.sprintf "去声 %s韵" (string_of_rhyme_group group)
  | Some (RuSheng, group) -> Printf.sprintf "入声 %s韵" (string_of_rhyme_group group)
  | None -> "未知韵律"