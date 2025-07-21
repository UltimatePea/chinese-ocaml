(* 诗词艺术性评价器类型定义模块接口 *)

(* 诗词评价维度类型 *)
type evaluation_dimension = Rhyme | Tone | Parallelism | Imagery | Rhythm | Elegance

(* 诗词评价结果类型 *)
type evaluation_result = {
  dimension : evaluation_dimension;
  score : float;
  details : string option;
}

(* 诗词评价上下文类型 *)
type evaluation_context = {
  verse : string;
  char_count : int;
  char_list : string list;
  tone_lookup : (string, Tone_data.tone_type) Hashtbl.t;
}

(* 评价器接口 *)
module type EVALUATOR = sig
  val evaluate : evaluation_context -> evaluation_result
  val get_dimension : unit -> evaluation_dimension
  val get_description : unit -> string
end
