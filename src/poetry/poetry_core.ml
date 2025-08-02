(** Poetry_core module for poetry library - Fix Issue #2055
 * 
 * 在poetry库内提供Poetry_core模块访问
 * Author: Whisky, PR Worker  
 * Date: 2025-08-02
 * 
 * 目的：解决poetry库内模块对Poetry_core的依赖问题
 *)

(** 基于poetry_core_consolidated的本地Poetry_core模块 *)
module Poetry_types = struct
  include Poetry_core_consolidated
  
  (* 导出类型 *)
  type rhyme_category = Poetry_core_consolidated.rhyme_category = 
    | PingSheng | ShangSheng | QuSheng | RuSheng
  
  type rhyme_group = Poetry_core_consolidated.rhyme_group = 
    | Feng | Hua | Yu | Hui | Jiang | Yue | Other of string
  
  type rhyme_info = Poetry_core_consolidated.rhyme_info = {
    category: rhyme_category;
    group: rhyme_group; 
    tone_pattern: int option;
    char: string;
  }
  
  type poetry_form = Poetry_core_consolidated.poetry_form = 
    | WuYanLushi | QiYanLushi | WuYanJueju | QiYanJueju | Custom of string
  
  type evaluation_dimension = Poetry_core_consolidated.evaluation_dimension = 
    | Rhyme | Artistic | Form | Content | Sound
  
  type evaluation_result = Poetry_core_consolidated.evaluation_result = {
    overall_score: float;
    dimension_scores: (evaluation_dimension * float) list;
    rhyme_quality: float;
    artistic_quality: float;
    form_compliance: float;
    recommendations: string list;
  }
  
  (* 导出转换函数 *)
  let rhyme_category_to_string = Poetry_core_consolidated.rhyme_category_to_string
  let rhyme_group_to_string = Poetry_core_consolidated.rhyme_group_to_string
end

module Rhyme_core_api = struct
  let find_rhyme_info = Poetry_core_consolidated.find_rhyme_info
  let detect_rhyme_category = Poetry_core_consolidated.detect_rhyme_category
  let check_rhyme_match = Poetry_core_consolidated.check_rhyme_match
  let analyze_line_rhyme = Poetry_core_consolidated.analyze_line_rhyme
end

module Rhyme_core_types = struct
  type rhyme_category = Poetry_types.rhyme_category
  type rhyme_group = Poetry_types.rhyme_group
  type rhyme_info = Poetry_types.rhyme_info
end

module Types = Poetry_types

module Json_core = struct
  type rhyme_category = Poetry_types.rhyme_category
  type rhyme_group = Poetry_types.rhyme_group
  type rhyme_info = Poetry_types.rhyme_info
  
  (* 额外的JSON相关类型定义 *)
  type rhyme_group_data = {
    group_name: string;
    chars: string list;
    tone_patterns: int list;
  }
  
  type rhyme_data_item = {
    char: string;
    category: rhyme_category;
    group: rhyme_group;
    tone: int option;
  }
  
  type rhyme_data_file = {
    version: string;
    groups: rhyme_group_data list;
  }
end

(* Rhyme_core_types已在第55行定义，这里移除重复定义 *)