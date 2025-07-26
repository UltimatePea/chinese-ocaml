(** Token兼容性报告生成模块 - Issue #646 技术债务清理

    此模块负责生成各种兼容性报告和统计信息，便于监控和维护Token兼容性。 这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。

    @author 骆言技术债务清理团队 Issue #646
    @version 1.0
    @since 2025-07-20 *)

open Yyocamlc_lib.Unified_formatter

(** JSON数据加载器模块 *)
module TokenDataLoader = struct
  let find_data_file () =
    let candidates =
      [
        "data/token_mappings/supported_legacy_tokens.json";
        (* 项目根目录 *)
        "../data/token_mappings/supported_legacy_tokens.json";
        (* 从test目录 *)
        "../../data/token_mappings/supported_legacy_tokens.json";
        (* 从深层test目录 *)
        "../../../data/token_mappings/supported_legacy_tokens.json";
        (* 从build目录访问 *)
      ]
    in
    List.find (fun path -> Sys.file_exists path) candidates

  let load_token_category category_name =
    try
      let data_file = find_data_file () in
      let json = Yojson.Basic.from_file data_file in
      let open Yojson.Basic.Util in
      let category = json |> member "token_categories" |> member category_name in
      let tokens = category |> member "tokens" |> to_list in
      List.map to_string tokens
    with
    | Not_found ->
        []
    | Sys_error _ ->
        []
    | Yojson.Json_error _ ->
        []

  let load_all_tokens () =
    let categories =
      [ "basic_keywords"; "wenyan_keywords"; "ancient_keywords"; "operators"; "delimiters" ]
    in
    (* 性能优化：使用 :: 操作替代 @ 操作，避免 O(n²) 复杂度 *)
    List.fold_left
      (fun acc category ->
        let tokens = load_token_category category in
        tokens :: acc)
      [] categories
    |> List.concat |> List.rev
end

(** 获取所有支持的遗留Token列表 - 从JSON文件加载的结构化数据 *)
let get_supported_legacy_tokens () = TokenDataLoader.load_all_tokens ()

(** 生成基础兼容性报告 *)
let generate_compatibility_report () =
  let supported_tokens = get_supported_legacy_tokens () in
  let total_count = List.length supported_tokens in

  ReportFormatting.token_compatibility_report total_count (string_of_float (Unix.time ()))

(** 生成详细的兼容性报告 *)
let generate_detailed_compatibility_report () =
  let supported_tokens = get_supported_legacy_tokens () in

  ReportFormatting.detailed_token_compatibility_report (List.length supported_tokens)
    (string_of_float (Unix.time ()))
