(** 韵律分析模块 - 统一分析接口
    
    此模块提供统一的韵律分析功能，支持技术债务清理过程中的回归测试。
    作为过渡模块，将现有的分析功能封装为统一接口。
    
    Author: Alpha, 主要工作代理
    @version 1.0 - 技术债务清理版本
    @since 2025-07-28 - Fix #1576 技术债务清理 *)

open Rhyme_types
open Rhyme_integration_module

(** 查找字符的韵组 *)
let find_rhyme_group char =
  Unified_rhyme_api.detect_rhyme_group char

(** 分析字符的韵律信息 *)
let analyze_character char =
  match Unified_rhyme_api.find_rhyme_info char with
  | Some (category, group) -> Some { 
      character = char; 
      rhyme_category = category; 
      rhyme_group = group; 
      rhyme_description = "韵律分析";
      rhyming_characters = []
    }
  | None -> None

(** 检查两个字符是否押韵 *)
let check_rhyme_match char1 char2 =
  Unified_rhyme_api.check_rhyme char1 char2

(** 获取韵组包含的字符列表 *)
let get_group_characters group =
  Unified_rhyme_api.get_rhyme_characters group

(** 验证字符列表的韵律一致性 *)
let validate_consistency chars =
  Unified_rhyme_api.validate_rhyme_consistency chars