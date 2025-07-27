(** 韵律数据JSON解析模块 - 从 rhyme_data_utils.ml 提取
    
    专门处理JSON韵律数据解析和错误处理，
    优化解析性能和错误恢复。
    
    Author: Alpha, 主工作代理
    Fix #1460 Phase 2.1 - JSON解析模块优化 *)

open Printf
open Rhyme_file_config

(** JSON韵律数据结构 *)
type json_rhyme_data = {
  name : string;
  category : string;
  characters : string list;
  metadata : (string * string) list;
}

(** 解析JSON韵律数据 - 优化版本，减少异常处理开销 *)
let parse_json_rhyme_data json =
  try
    let open Yojson.Basic.Util in
    let name = json |> member "name" |> to_string in
    let category = json |> member "category" |> to_string in
    let characters = json |> member "characters" |> to_list |> List.map to_string in
    let metadata = 
      match json |> member "metadata" with
      | `Null -> []
      | metadata_json -> 
          (try 
             metadata_json |> to_assoc |> List.map (fun (k, v) -> (k, to_string v))
           with _ -> [])
    in
    Ok { name; category; characters; metadata }
  with 
  | Yojson.Basic.Util.Type_error (msg, _) -> 
      Error (sprintf "JSON类型错误: %s" msg)
  | Yojson.Json_error msg ->
      Error (sprintf "JSON格式错误: %s" msg)
  | exn ->
      Error (sprintf "JSON解析失败: %s" (Printexc.to_string exn))

(** 批量解析JSON数据 - 性能优化版本 *)
let batch_parse_json_data json_list =
  let results = ref [] in
  let errors = ref [] in
  List.iter (fun json ->
    match parse_json_rhyme_data json with
    | Ok data -> results := data :: !results
    | Error msg -> errors := msg :: !errors
  ) json_list;
  (List.rev !results, List.rev !errors)

(** 安全加载单个JSON文件 *)
let safe_load_json_file file_path =
  try
    match Common_patterns.safe_json_parse file_path with
    | Ok json -> Ok json
    | Error msg -> Error (sprintf "文件读取失败 %s: %s" file_path msg)
  with exn ->
    Error (sprintf "文件加载异常 %s: %s" file_path (Printexc.to_string exn))

(** 批量加载JSON韵律文件 - 重构优化版本 *)
let batch_load_rhyme_files config category_group_pairs =
  let load_single_file (category, group) =
    match find_rhyme_data_file config category group with
    | None -> 
        Common_patterns.print_warning (sprintf "未找到韵律文件: %s/%s" 
          (string_of_rhyme_category category) (string_of_rhyme_group group));
        []
    | Some file_path ->
        match safe_load_json_file file_path with
        | Ok json ->
            (match parse_json_rhyme_data json with
             | Ok data -> [data]
             | Error msg -> 
                 Common_patterns.print_warning (sprintf "解析韵律文件失败 %s: %s" file_path msg);
                 [])
        | Error msg -> 
            Common_patterns.print_warning (sprintf "加载韵律文件失败: %s" msg);
            []
  in
  List.concat (List.map load_single_file category_group_pairs)

(** 验证JSON韵律数据 *)
let validate_json_rhyme_data data =
  let name_valid = String.length data.name > 0 in
  let category_valid = String.length data.category > 0 in
  let characters_valid = List.length data.characters > 0 && 
    List.for_all (fun c -> String.length c > 0) data.characters in
  name_valid && category_valid && characters_valid

(** 过滤有效的JSON数据 *)
let filter_valid_json_data data_list =
  List.filter validate_json_rhyme_data data_list

(** JSON数据摘要信息 *)
let json_data_summary data =
  sprintf "JSON数据: %s (%s类), %d个字符" 
    data.name data.category (List.length data.characters)

(** 批量JSON数据摘要 *)
let batch_json_summary data_list =
  let total_count = List.length data_list in
  let total_characters = List.fold_left (fun acc data -> 
    acc + List.length data.characters) 0 data_list in
  sprintf "JSON批量数据: %d个文件, 共%d个字符" total_count total_characters