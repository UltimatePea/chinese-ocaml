(* 艺术数据解析逻辑模块 *)

open Artistic_core_types

(** {1 JSON数据解析函数} *)

let parse_word_info_from_json (json : Yojson.Basic.t) : (string * word_info) list =
  let open Yojson.Basic.Util in
  try
    let words = json |> to_list in
    List.map (fun word_json ->
      let word = word_json |> member "word" |> to_string in
      let category_str = word_json |> member "category" |> to_string in
      let frequency = word_json |> member "frequency" |> to_int in
      let artistic_value = word_json |> member "artistic_value" |> to_float in
      let synonyms = try word_json |> member "synonyms" |> to_list |> List.map to_string with _ -> [] in
      let contexts = try word_json |> member "contexts" |> to_list |> List.map to_string with _ -> [] in
      let examples = try word_json |> member "examples" |> to_list |> List.map to_string with _ -> [] in
      
      let word_info = {
        word;
        category = word_category_from_string category_str;
        frequency;
        artistic_value;
        synonyms;
        contexts;
        examples;
      } in
      (word, word_info)
    ) words
  with _ -> []

let parse_evaluation_standards_from_json (json : Yojson.Basic.t) : (evaluation_dimension * evaluation_standard list) list =
  let open Yojson.Basic.Util in
  try
    let dimensions = json |> member "standards" |> to_assoc in
    List.map (fun (dim_str, standards_json) ->
      let dimension = evaluation_dimension_from_string dim_str in
      let standards = standards_json |> to_list |> List.map (fun std_json ->
        let name = std_json |> member "name" |> to_string in
        let description = std_json |> member "description" |> to_string in
        let weight = std_json |> member "weight" |> to_float in
        let min_score = std_json |> member "min_score" |> to_float in
        let max_score = std_json |> member "max_score" |> to_float in
        let criteria = try 
          std_json |> member "criteria" |> to_list |> List.map (fun c ->
            let desc = c |> member "description" |> to_string in
            let score = c |> member "score" |> to_float in
            (desc, score)
          )
        with _ -> [] in
        {dimension; name; description; weight; min_score; max_score; criteria}
      ) in
      (dimension, standards)
    ) dimensions
  with _ -> []

let parse_artistic_templates_from_json (json : Yojson.Basic.t) : (word_category * artistic_template list) list =
  let open Yojson.Basic.Util in
  try
    let categories = json |> member "templates" |> to_assoc in
    List.map (fun (cat_str, templates_json) ->
      let category = word_category_from_string cat_str in
      let templates = templates_json |> to_list |> List.map (fun tmpl_json ->
        let name = tmpl_json |> member "name" |> to_string in
        let pattern = tmpl_json |> member "pattern" |> to_string in
        let examples = try tmpl_json |> member "examples" |> to_list |> List.map to_string with _ -> [] in
        let effectiveness = tmpl_json |> member "effectiveness" |> to_float in
        {name; category; pattern; examples; effectiveness}
      ) in
      (category, templates)
    ) categories
  with _ -> []