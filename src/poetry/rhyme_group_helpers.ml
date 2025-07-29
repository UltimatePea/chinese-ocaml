(** 韵律数据组辅助函数模块
 
    提供rhyme_groups模块使用的数据结构辅助函数，避免代码重复。

    Author: Alpha, 主要工作代理
    @version 1.0 - 重复代码清理版本
    @since 2025-07-29 - Fix #1637 韵律数据模块重复代码清理 *)

open Rhyme_core_types

(** 创建韵律数据条目的辅助函数 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars