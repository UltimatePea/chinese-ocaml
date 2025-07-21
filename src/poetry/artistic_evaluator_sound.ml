(* 诗词声律评价器模块 - 韵律与声调评价
   
   专门负责诗词的声律层面评价，包含韵律和声调两个维度。
   承古代韵书传统，依四声理论，察音韵和谐之美。 *)

open Tone_data
open Artistic_evaluator_types
open Artistic_evaluator_context

(* 韵律评价器 - 音韵和谐性评估模块
   
   依据传统韵书理论，评估诗句的音韵和谐程度。
   古代诗词创作极重押韵，《诗经》、《楚辞》以降，
   无不以韵律为诗之骨干。此模块承继这一传统，
   通过分析韵脚字的声调属性，量化韵律和谐度。
   
   评价原理：
   - 平声韵脚：音调平缓悠长，韵律和谐度较高
   - 仄声韵脚：音调有变化，和谐度次之
   - 无韵脚或识别失败：韵律效果较差 *)
module RhymeEvaluator : EVALUATOR = struct
  let get_dimension () = Rhyme
  let get_description () = "韵律和谐性评价 - 依古韵书传统，察音韵之美"

  let evaluate context =
    (* 基础评分：字数适中的诗句更容易形成良好韵律 *)
    let base_score = min (float_of_int (get_char_count context)) 10.0 /. 10.0 in

    (* 韵脚字声调分析 - 检查诗句末字的声调属性
       古人云："韵脚定诗格"，韵脚字选择直接影响整首诗的音韵效果 *)
    let rhyme_score =
      let verse = get_verse context in
      if String.length verse >= 2 then
        let last_char = String.sub verse (String.length verse - 1) 1 in
        match get_char_tone context last_char with
        | Some LevelTone -> 0.8 (* 平声韵：音调悠长，最为和谐 *)
        | Some _ -> 0.6 (* 仄声韵：有变化，次之 *)
        | None -> 0.4 (* 无法识别：效果难测 *)
      else 0.4
    in

    (* 综合评分：基础分占40%，韵脚分占60%
       体现韵脚在韵律评价中的核心地位 *)
    let final_score = (base_score *. 0.4) +. (rhyme_score *. 0.6) in
    { dimension = Rhyme; score = final_score; details = None }
end

(* 声调评价器 - 平仄相谐，观抑扬顿挫之美
   
   声调平衡乃古典诗词格律之根本，《诗谱》云："平仄相间，
   抑扬有致。"古人以四声论诗：平声悠扬，上声高亢，
   去声疾促，入声短促。此模块分析诗句中各声调的分布，
   评估其平衡程度和音韵效果。
   
   理论依据：
   - 四声分类源于齐梁沈约《四声论》、周颙等人的声韵理论
   - 唐诗律诗格律严格要求平仄相对，形成独特的音韵美感
   - 平声字音调平缓如流水，仄声字音调变化如山峦起伏
   
   评价原理：声调分布越均匀，抑扬顿挫效果越佳。 *)
module ToneEvaluator : EVALUATOR = struct
  let get_dimension () = Tone
  let get_description () = "声调平衡评价 - 依四声理论，察平仄相谐之美"

  let evaluate context =
    (* 统计各声调字符数量 - 分析四声分布模式
       按古代四声分类：平、上、去、入，现代多数方言已无入声，
       故将FallingTone归入入声类进行统计 *)
    let tone_counts =
      List.fold_left
        (fun (level, rising, departing, entering) char ->
          match get_char_tone context char with
          | Some LevelTone -> (level + 1, rising, departing, entering) (* 平声：如歌声悠扬 *)
          | Some RisingTone -> (level, rising + 1, departing, entering) (* 上声：如登高望远 *)
          | Some DepartingTone -> (level, rising, departing + 1, entering) (* 去声：如流水急湍 *)
          | Some EnteringTone -> (level, rising, departing, entering + 1) (* 入声：如鼓声急促 *)
          | Some FallingTone -> (level, rising, departing, entering + 1) (* 归入入声类 *)
          | None -> (level, rising, departing, entering + 1)) (* 未知声调 *)
        (0, 0, 0, 0) (get_char_list context)
    in

    let total_chars = List.length (get_char_list context) in
    (* 计算声调平衡度 - 基于四声分布的均匀性评估
       
       古代格律诗要求"平仄相间"，即平声与仄声（上去入）
       应该相对平衡。完全平衡时评分最高，偏向某一方时评分下降。
       这种评估方法体现了传统诗学中"音韵和谐"的美学追求。 *)
    let final_score =
      if total_chars = 0 then 0.0
      else
        let level, rising, departing, entering = tone_counts in
        (* 平仄平衡算法：平声与仄声（上+去+入）数量差距越小越好 *)
        let balance =
          1.0
          -. abs_float (float_of_int level -. float_of_int (rising + departing + entering))
             /. float_of_int total_chars
        in
        max 0.0 balance (* 确保评分不为负值 *)
    in

    { dimension = Tone; score = final_score; details = None }
end
