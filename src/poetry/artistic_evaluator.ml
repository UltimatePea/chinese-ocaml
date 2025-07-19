(* 诗词艺术性评价器模块 - 承古典诗学传统，建现代评价体系
   
   承千载诗学传统，鉴古人品评之法，融合现代计算精神，
   量化评价诗词艺术之妙。古有钟嵘《诗品》品诗三等，
   司空图《诗品》论诗二十四境，严羽《沧浪诗话》倡神韵说，
   今以程序之道，承其精神，评诗词之艺术价值。
   
   评价之法，师古而不泥古：
   - 韵律和谐：依《广韵》《平水韵》等韵书传统，察音韵之谐美
   - 声调平衡：按平仄四声分类，观抑扬顿挫之律动 
   - 对仗工整：遵律诗格律传统，验词性相对、句式平行之美
   - 意象深度：品诗词意境层次，评象征手法之精妙
   - 节奏韵律：观句式长短参差，察音律节拍之和谐
   - 雅致程度：辨词语雅俗高下，品文辞典雅之度
   
   古云："诗言志，歌永言，声依永，律和声。"此模块正是体现
   这一传统诗学理念的现代实现，既保持古典美学精神，
   又适应程序化评价的精确性要求。
*)

open Yyocamlc_lib
open Tone_data

(* 诗词评价维度类型 - 承古典诗学传统之六大评价准则 
   
   古代诗评中，品诗优劣需察其多重维度：
   《诗品》、《沧浪诗话》等历代诗论，皆有评价标准。
   今归纳为六大维度，涵盖声律、对仗、意境等传统要求。 *)
type evaluation_dimension =
  | Rhyme        (* 韵律 - 音韵和谐，依韵书分类，察押韵之美 *)
  | Tone         (* 声调 - 平仄相谐，四声搭配，观抑扬顿挫 *)
  | Parallelism  (* 对仗 - 律诗格律，词性相对，句式工整 *)
  | Imagery      (* 意象 - 诗词意境，象征手法，境界层次 *)
  | Rhythm       (* 节奏 - 音律节拍，句式长短，韵律流动 *)
  | Elegance     (* 雅致 - 词语典雅，格调高下，文辞品味 *)

(* 诗词评价结果类型 - 量化传统美学判断 
   
   古人品诗，多以主观感受论优劣；今以数值评分，
   使传统美学标准得以客观化、精确化表达。 *)
type evaluation_result = {
  dimension : evaluation_dimension;  (* 评价维度 *)
  score : float;                    (* 评分值(0.0-1.0) *)
  details : string option;          (* 详细说明，可包含古典诗论引证 *)
}

(* 诗词评价上下文 - 预处理诗词数据，优化计算性能 
   
   为避免重复计算字符解析、声调查询等开销较大的操作，
   预先创建评价上下文，缓存常用数据结构。
   此设计既提高效率，又保持代码清晰。 *)
type evaluation_context = {
  verse : string;                                 (* 待评价诗句原文 *)
  char_count : int;                              (* UTF-8字符计数 *)
  char_list : string list;                       (* 字符列表，便于遍历 *)
  tone_lookup : (string, tone_type) Hashtbl.t;   (* 声调查找哈希表 *)
}

(* 创建诗词评价上下文 - 预处理诗句，建立高效数据结构
   
   此函数将诗句文本转化为便于分析的数据结构：
   1. 计算UTF-8字符总数，为后续算法提供基础数据
   2. 将诗句拆分为字符列表，便于逐字分析
   3. 构建声调查找哈希表，避免重复查询tone_database
   
   设计思想源于"工欲善其事，必先利其器"，通过预处理
   提高后续各种评价算法的执行效率。 *)
let create_evaluation_context verse =
  let char_count = Utf8_utils.StringUtils.utf8_length verse in
  let char_list = Utf8_utils.StringUtils.utf8_to_char_list verse in
  
  (* 构建声调查找哈希表 - 将tone_database转换为O(1)查找结构
     古代韵书如《广韵》按韵部分类字音，今以哈希表实现快速查找 *)
  let tone_lookup = Hashtbl.create 64 in
  List.iter (fun (char, tone) ->
    Hashtbl.replace tone_lookup char tone
  ) tone_database;
  
  { verse; char_count; char_list; tone_lookup }

(* 获取字符声调 - 快速查询字符的声调属性
   
   使用预建的哈希表查询字符声调，避免每次遍历tone_database。
   声调分类依古代四声传统：平、上、去、入，为诗词格律分析
   提供基础数据。古云"平仄相间，抑扬有致"，此为其技术实现。 *)
let get_char_tone context char =
  try Some (Hashtbl.find context.tone_lookup char)
  with Not_found -> None

(* 诗词评价器通用接口 - 统一各维度评价器的标准
   
   定义所有评价器必须实现的基本接口，确保评价体系的一致性。
   每个评价器专注于一个维度，遵循"术业有专攻"的设计理念。 *)
module type EVALUATOR = sig
  val evaluate : evaluation_context -> evaluation_result  (* 核心评价函数 *)
  val get_dimension : unit -> evaluation_dimension        (* 获取评价维度 *)
  val get_description : unit -> string                   (* 获取评价器描述 *)
end

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
    let base_score = min (float_of_int context.char_count) 10.0 /. 10.0 in
    
    (* 韵脚字声调分析 - 检查诗句末字的声调属性
       古人云："韵脚定诗格"，韵脚字选择直接影响整首诗的音韵效果 *)
    let rhyme_score =
      if String.length context.verse >= 2 then
        let last_char = String.sub context.verse (String.length context.verse - 1) 1 in
        match get_char_tone context last_char with
        | Some LevelTone -> 0.8    (* 平声韵：音调悠长，最为和谐 *)
        | Some _ -> 0.6            (* 仄声韵：有变化，次之 *)
        | None -> 0.4              (* 无法识别：效果难测 *)
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
          | Some LevelTone -> (level + 1, rising, departing, entering)     (* 平声：如歌声悠扬 *)
          | Some RisingTone -> (level, rising + 1, departing, entering)    (* 上声：如登高望远 *)
          | Some DepartingTone -> (level, rising, departing + 1, entering) (* 去声：如流水急湍 *)
          | Some EnteringTone -> (level, rising, departing, entering + 1)  (* 入声：如鼓声急促 *)
          | Some FallingTone -> (level, rising, departing, entering + 1)   (* 归入入声类 *)
          | None -> (level, rising, departing, entering + 1))              (* 未知声调 *)
        (0, 0, 0, 0) context.char_list
    in
    
    let total_chars = List.length context.char_list in
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
        max 0.0 balance  (* 确保评分不为负值 *)
    in
    
    { dimension = Tone; score = final_score; details = None }
end

(* 对仗评价器 *)
module ParallelismEvaluator : EVALUATOR = struct
  let get_dimension () = Parallelism
  let get_description () = "对仗工整性评价"
  
  let evaluate context =
    let base_score = if context.char_count >= 4 then 0.7 else 0.5 in
    
    (* 检查是否包含对仗结构 *)
    let parallelism_keywords = [ "对仗"; "上联"; "下联"; "工整"; "相对" ] in
    let contains_parallelism =
      List.exists (fun keyword -> 
        String.contains context.verse (String.get keyword 0)
      ) parallelism_keywords
    in
    
    let final_score = if contains_parallelism then base_score +. 0.3 else base_score in
    { dimension = Parallelism; score = final_score; details = None }
end

(* 意象评价器 *)
module ImageryEvaluator : EVALUATOR = struct
  let get_dimension () = Imagery
  let get_description () = "意象深度评价"
  
  let evaluate context =
    let nature_imagery = [ "山"; "水"; "月"; "风"; "花"; "鸟"; "云"; "雨"; "雪"; "霜" ] in
    let seasonal_imagery = [ "春"; "夏"; "秋"; "冬"; "朝"; "暮"; "日"; "星" ] in
    let literary_imagery = [ "诗"; "词"; "书"; "画"; "琴"; "棋"; "茶"; "酒" ] in
    
    let count_imagery imagery_list =
      List.fold_left
        (fun acc imagery -> 
          if String.contains context.verse (String.get imagery 0) then acc + 1 else acc
        )
        0 imagery_list
    in
    
    let nature_count = count_imagery nature_imagery in
    let seasonal_count = count_imagery seasonal_imagery in
    let literary_count = count_imagery literary_imagery in
    
    let total_imagery = nature_count + seasonal_count + literary_count in
    let imagery_score = min (float_of_int total_imagery) 5.0 /. 5.0 in
    
    (* 深度加权：文学意象权重更高 *)
    let depth_score =
      (float_of_int nature_count *. 0.3)
      +. (float_of_int seasonal_count *. 0.4)
      +. (float_of_int literary_count *. 0.6)
    in
    
    let final_score = (imagery_score *. 0.6) +. (min depth_score 1.0 *. 0.4) in
    { dimension = Imagery; score = final_score; details = None }
end

(* 节奏评价器 *)
module RhythmEvaluator : EVALUATOR = struct
  let get_dimension () = Rhythm
  let get_description () = "节奏流畅性评价"
  
  let evaluate context =
    let ideal_rhythm = [ 4; 5; 7 ] in (* 四言、五言、七言 *)
    
    let rhythm_score =
      if List.mem context.char_count ideal_rhythm then 0.9
      else if context.char_count >= 4 && context.char_count <= 10 then 0.7
      else 0.5
    in
    
    (* 检查句式结构 *)
    let structure_score =
      if String.contains context.verse (String.get "，" 0) || 
         String.contains context.verse (String.get "。" 0) then 0.8
      else 0.6
    in
    
    let final_score = (rhythm_score *. 0.7) +. (structure_score *. 0.3) in
    { dimension = Rhythm; score = final_score; details = None }
end

(* 雅致评价器 *)
module EleganceEvaluator : EVALUATOR = struct
  let get_dimension () = Elegance
  let get_description () = "雅致程度评价"
  
  let evaluate context =
    let elegant_chars = [ "雅"; "韵"; "清"; "雅"; "淡"; "素"; "朴"; "简"; "洁"; "净"; "纯"; "真"; "善"; "美" ] in
    let elegant_count =
      List.fold_left
        (fun acc char -> 
          if String.contains context.verse (String.get char 0) then acc + 1 else acc
        )
        0 elegant_chars
    in
    
    let elegance_score = min (float_of_int elegant_count) 3.0 /. 3.0 in
    
    (* 避免俗词的加分 *)
    let vulgar_chars = [ "钱"; "财"; "利"; "俗"; "粗"; "低"; "劣" ] in
    let vulgar_count =
      List.fold_left
        (fun acc char -> 
          if String.contains context.verse (String.get char 0) then acc + 1 else acc
        )
        0 vulgar_chars
    in
    
    let refinement_bonus = if vulgar_count = 0 then 0.2 else 0.0 in
    let final_score = min 1.0 (elegance_score +. refinement_bonus) in
    
    { dimension = Elegance; score = final_score; details = None }
end

(* 综合评价器 - 协调各个子评价器 *)
module ComprehensiveEvaluator = struct
  let evaluators = [
    (module RhymeEvaluator : EVALUATOR);
    (module ToneEvaluator : EVALUATOR);
    (module ParallelismEvaluator : EVALUATOR);
    (module ImageryEvaluator : EVALUATOR);
    (module RhythmEvaluator : EVALUATOR);
    (module EleganceEvaluator : EVALUATOR);
  ]
  
  let evaluate_all context =
    List.map (fun (module E : EVALUATOR) -> E.evaluate context) evaluators
end