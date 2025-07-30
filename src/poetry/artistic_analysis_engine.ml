(* 艺术数据分析功能模块 *)

open Artistic_core_types

(** {1 文本艺术元素分析} *)

let analyze_text_artistic_elements (text : string) : (word_category * string list) list query_result
    =
  try
    let text_chars = List.init (String.length text) (String.get text) in
    let text_words = List.map (String.make 1) text_chars in

    let imagery_words =
      List.filter
        (fun word -> List.mem word Artistic_legacy_compat.default_imagery_words)
        text_words
    in
    let elegant_words =
      List.filter
        (fun word -> List.mem word Artistic_legacy_compat.default_elegant_words)
        text_words
    in

    let result = [] in
    let result = if imagery_words <> [] then (Imagery, imagery_words) :: result else result in
    let result = if elegant_words <> [] then (Elegant, elegant_words) :: result else result in

    if result = [] then NotFound else Found result
  with exn -> QueryError ("分析艺术元素失败: " ^ Printexc.to_string exn)

(** {1 意象词汇专用分析} *)

let get_nature_imagery () : string list query_result =
  match Artistic_query_engine.get_words_by_category Nature with
  | Found words -> Found words
  | NotFound ->
      let nature_words =
        List.filter
          (fun word ->
            String.contains word (String.get "山" 0)
            || String.contains word (String.get "水" 0)
            || String.contains word (String.get "花" 0)
            || String.contains word (String.get "树" 0))
          Artistic_legacy_compat.default_imagery_words
      in
      Found nature_words
  | QueryError err -> QueryError err

let get_seasonal_imagery (season : string) : string list query_result =
  let seasonal_keywords =
    match season with
    | "春" -> [ "春"; "花"; "绿"; "暖"; "莺"; "燕" ]
    | "夏" -> [ "夏"; "热"; "荷"; "蝉"; "绿"; "浓" ]
    | "秋" -> [ "秋"; "叶"; "黄"; "凉"; "雁"; "霜" ]
    | "冬" -> [ "冬"; "雪"; "白"; "寒"; "梅"; "冰" ]
    | _ -> []
  in
  if seasonal_keywords = [] then NotFound else Found seasonal_keywords

let suggest_imagery_for_theme (theme : string) : string list query_result =
  let theme_imagery_map =
    [
      ("离别", [ "柳"; "月"; "风"; "泪"; "路" ]);
      ("思乡", [ "月"; "雁"; "梦"; "山"; "水" ]);
      ("爱情", [ "花"; "月"; "红"; "泪"; "心" ]);
      ("田园", [ "山"; "水"; "田"; "鸟"; "花" ]);
    ]
  in
  try Found (List.assoc theme theme_imagery_map) with Not_found -> NotFound

(** {1 数据趋势分析} *)

let get_popular_words (category : word_category) (limit : int) : (string * int) list query_result =
  match Artistic_query_engine.get_words_by_category category with
  | Found words ->
      let take n lst =
        let rec aux acc n = function
          | [] -> List.rev acc
          | x :: xs when n > 0 -> aux (x :: acc) (n - 1) xs
          | _ -> List.rev acc
        in
        aux [] n lst
      in
      let limited_words = take (min limit (List.length words)) words in
      let word_freq_pairs = List.map (fun word -> (word, 1)) limited_words in
      Found word_freq_pairs
  | NotFound -> NotFound
  | QueryError err -> QueryError err

let get_artistic_trends () : (word_category * float) list query_result =
  let trends =
    [
      (Imagery, 0.85);
      (Elegant, 0.70);
      (Nature, 0.80);
      (Classical, 0.60);
      (Emotion, 0.75);
      (Metaphor, 0.65);
    ]
  in
  Found trends
