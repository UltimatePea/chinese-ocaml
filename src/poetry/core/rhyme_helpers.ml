(** 韵律数据辅助函数模块
    
    提供创建韵律数据条目的通用辅助函数，避免在各个韵组模块中重复定义。
    
    @author Beta, 代码审查代理
    @version 1.0 - 代码去重版本
    @since 2025-07-27 *)

open Rhyme_core_types

(** 创建韵律数据条目的辅助函数 
    
    @param char 字符
    @param category 韵律类别 (平声、仄声等)
    @param group 韵组类型
    @param variants 可选的变体字符列表，默认为空
    @param frequency 使用频率，默认为1.0
    @return 韵律数据条目 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数
    
    将字符列表批量转换为韵律数据条目列表
    
    @param category 韵律类别
    @param group 韵组类型  
    @param chars 字符列表
    @return 韵律数据条目列表 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** 合并平声和仄声数据的辅助函数
    
    @param ping_sheng_data 平声数据列表
    @param ze_sheng_data 仄声数据列表
    @return 合并后的数据列表 *)
let combine_data ping_sheng_data ze_sheng_data =
  ping_sheng_data @ ze_sheng_data

(** 获取韵组数据统计信息 - 简化版本
    
    @param data 韵律数据列表
    @return 总数量 *)
let get_rhyme_stats data =
  List.length data