(* 诗词内容评价器模块 - 意象评价
   
   专门负责诗词内容层面的评价，主要是意象维度。
   品诗词意境层次，评象征手法之精妙。 *)

open Artistic_evaluator_types
open Artistic_evaluator_context

(* 意象评价器 - 诗词意境，象征手法，境界层次之美
   
   意象乃诗词之魂，古云"诗缘情而绮靡"，情感需借意象表达。
   此模块分析诗句中的意象密度和深度，评估其艺术感染力。 *)
module ImageryEvaluator : EVALUATOR = struct
  let get_dimension () = Imagery
  let get_description () = "意象深度评价 - 品诗词意境，评象征手法之妙"

  let evaluate context =
    (* 不同类型意象的分类 - 体现诗词意象的层次性
       自然意象：山水花鸟等自然物象，最为常见
       时序意象：春夏秋冬等时间意象，营造时空感
       文化意象：诗书琴棋等文化符号，体现雅致情怀 *)
    let nature_imagery = [ "山"; "水"; "月"; "风"; "花"; "鸟"; "云"; "雨"; "雪"; "霜" ] in
    let seasonal_imagery = [ "春"; "夏"; "秋"; "冬"; "朝"; "暮"; "日"; "星" ] in
    let literary_imagery = [ "诗"; "词"; "书"; "画"; "琴"; "棋"; "茶"; "酒" ] in

    (* 统计各类意象出现次数 *)
    let count_imagery imagery_list =
      List.fold_left
        (fun acc imagery ->
          if String.contains (get_verse context) (String.get imagery 0) then acc + 1 else acc)
        0 imagery_list
    in

    let nature_count = count_imagery nature_imagery in
    let seasonal_count = count_imagery seasonal_imagery in
    let literary_count = count_imagery literary_imagery in

    (* 计算意象总体密度分数 *)
    let total_imagery = nature_count + seasonal_count + literary_count in
    let imagery_score = min (float_of_int total_imagery) 5.0 /. 5.0 in

    (* 深度加权评分 - 文化意象权重更高，体现意境深度
       自然意象基础分：0.3 - 常见但基础
       时序意象中等分：0.4 - 营造时空感
       文化意象高分：0.6 - 体现文化底蕴 *)
    let depth_score =
      (float_of_int nature_count *. 0.3)
      +. (float_of_int seasonal_count *. 0.4)
      +. (float_of_int literary_count *. 0.6)
    in

    (* 综合评分：密度占60%，深度占40% *)
    let final_score = (imagery_score *. 0.6) +. (min depth_score 1.0 *. 0.4) in
    { dimension = Imagery; score = final_score; details = None }
end