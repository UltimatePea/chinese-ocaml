(** 音韵数据辅助函数模块 - 消除代码重复
    
    此模块提供统一的辅助函数，减少音韵数据定义中的重复模式。
    主要解决 rhyme_data.ml 中大量 (字符, 声调, 韵部) 元组重复的问题。

    @author 骆言诗词编程团队  
    @version 1.0
    @since 2025-07-19 *)

open Rhyme_types

(** {1 韵律数据构造辅助函数} *)

(** 创建平声韵字符组 
    @param rhyme_type 韵部类型
    @param chars 字符列表
    @return (字符, PingSheng, 韵部) 元组列表 *)
let make_ping_sheng_group rhyme_type chars =
  List.map (fun char -> (char, PingSheng, rhyme_type)) chars

(** 创建上声韵字符组 *)
let make_shang_sheng_group rhyme_type chars =
  List.map (fun char -> (char, ShangSheng, rhyme_type)) chars

(** 创建去声韵字符组 *)
let make_qu_sheng_group rhyme_type chars =
  List.map (fun char -> (char, QuSheng, rhyme_type)) chars

(** 创建入声韵字符组 *)
let make_ru_sheng_group rhyme_type chars =
  List.map (fun char -> (char, RuSheng, rhyme_type)) chars

(** 创建仄声韵字符组 - 通用仄声（包含上声、去声、入声） *)
let make_ze_sheng_group rhyme_type chars =
  List.map (fun char -> (char, ZeSheng, rhyme_type)) chars

(** 创建混合声调韵字符组 - 当同一韵组包含多种声调时使用
    @param rhyme_type 韵部类型
    @param char_tone_pairs (字符, 声调) 元组列表
    @return (字符, 声调, 韵部) 元组列表 *)
let make_mixed_tone_group rhyme_type char_tone_pairs =
  List.map (fun (char, tone) -> (char, tone, rhyme_type)) char_tone_pairs

(** {2 批量韵组构造器} *)

(** 创建多个平声韵组 - 用于批量处理同一韵部的不同字符组 *)
let make_multiple_ping_sheng_groups rhyme_type char_groups =
  List.flatten (List.map (make_ping_sheng_group rhyme_type) char_groups)

(** {3 常用韵组预设} *)

(** 诗词常用韵组构造器 - 专门针对诗词编程中的常见韵脚 *)
module Poetry_group_builder = struct
  
  (** 创建诗词核心韵组 - 诗时知思类常用字 *)
  let make_poetry_core rhyme_type core_chars =
    make_ping_sheng_group rhyme_type core_chars
  
  (** 创建方位韵组 - 东西南北中类 *)  
  let make_direction_group rhyme_type direction_chars =
    make_ping_sheng_group rhyme_type direction_chars
    
  (** 创建自然韵组 - 山水云月类 *)
  let make_nature_group rhyme_type nature_chars =
    make_ping_sheng_group rhyme_type nature_chars
    
  (** 创建情感韵组 - 喜怒哀乐类 *)
  let make_emotion_group rhyme_type emotion_chars = 
    make_ping_sheng_group rhyme_type emotion_chars
end

(** {4 韵组合并工具} *)

(** 合并多个韵组为单一列表 *)
let merge_rhyme_groups groups =
  List.flatten groups

(** 按韵部分组韵字 *)
let group_by_rhyme rhyme_data =
  let rec group_helper acc = function
    | [] -> acc
    | (char, tone, rhyme) :: rest ->
        let existing = try List.assoc rhyme acc with Not_found -> [] in
        let updated = (char, tone) :: existing in
        let new_acc = (rhyme, updated) :: (List.remove_assoc rhyme acc) in
        group_helper new_acc rest
  in
  group_helper [] rhyme_data

(** {5 韵律验证工具} *)

(** 验证韵组一致性 - 检查同一组内韵部是否一致 *)
let validate_rhyme_group group =
  match group with
  | [] -> true
  | (_, _, first_rhyme) :: rest ->
      List.for_all (fun (_, _, rhyme) -> rhyme = first_rhyme) rest

(** 检查重复字符 *)
let check_duplicate_chars rhyme_data =
  let chars = List.map (fun (char, _, _) -> char) rhyme_data in
  let rec has_dup seen = function
    | [] -> []
    | x :: xs when List.mem x seen -> x :: has_dup seen xs  
    | x :: xs -> has_dup (x :: seen) xs
  in
  has_dup [] chars