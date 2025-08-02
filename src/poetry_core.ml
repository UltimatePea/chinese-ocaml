(** Poetry_core compatibility module - Fix #2055
 * 
 * 提供向后兼容的 Poetry_core 模块，解决编译错误
 * Author: Whisky, PR Worker
 * Date: 2025-08-02
 * 
 * 注意：这是一个简化的兼容层，主要提供类型定义和基本函数
 * 真正的实现在 poetry 库中的 poetry_core_consolidated 模块
 *)

(** Poetry types module - 基础类型定义 *)
module Poetry_types = struct
  (* 核心类型定义 - 独立于poetry库避免循环依赖 *)
  type rhyme_category = 
    | PingSheng    (** 平声 *)
    | ShangSheng   (** 上声 *)
    | QuSheng      (** 去声 *)
    | RuSheng      (** 入声 *)
  
  type rhyme_group = 
    | Feng | Hua | Yu | Hui | Jiang | Yue
    | Other of string
  
  type rhyme_info = {
    category: rhyme_category;
    group: rhyme_group;
    tone_pattern: int option;
    char: string;
  }
  
  type poetry_form = 
    | WuYanLushi    (** 五言律诗 *)
    | QiYanLushi    (** 七言律诗 *)
    | WuYanJueju    (** 五言绝句 *)
    | QiYanJueju    (** 七言绝句 *)
    | Custom of string
  
  type evaluation_dimension = 
    | Rhyme | Artistic | Form | Content | Sound
  
  type evaluation_result = {
    overall_score: float;
    dimension_scores: (evaluation_dimension * float) list;
    rhyme_quality: float;
    artistic_quality: float;
    form_compliance: float;
    recommendations: string list;
  }
  
  (** 转换函数 *)
  let rhyme_category_to_string = function
    | PingSheng -> "平声"
    | ShangSheng -> "上声"
    | QuSheng -> "去声"
    | RuSheng -> "入声"
  
  let rhyme_group_to_string = function
    | Feng -> "峰韵"
    | Hua -> "华韵"
    | Yu -> "鱼韵"
    | Hui -> "灰韵"
    | Jiang -> "江韵"
    | Yue -> "月韵"
    | Other s -> s ^ "韵"
end

(** Rhyme Core API module - 基础韵律API *)
module Rhyme_core_api = struct
  (* 简化实现，主要用于编译通过 *)
  let find_rhyme_info _char = None
  let detect_rhyme_category _char = Poetry_types.PingSheng
  let check_rhyme_match _char1 _char2 = false
  let analyze_line_rhyme _line = []
end

(* 兼容函数导出 *)
let find_rhyme_info = Rhyme_core_api.find_rhyme_info
let detect_rhyme_category = Rhyme_core_api.detect_rhyme_category  
let check_rhyme_match = Rhyme_core_api.check_rhyme_match
let evaluate_poem_basic _lines = Poetry_types.{
  overall_score = 0.0;
  dimension_scores = [];
  rhyme_quality = 0.0;
  artistic_quality = 0.0;
  form_compliance = 0.0;
  recommendations = ["请使用完整的poetry库获得实际功能"];
}