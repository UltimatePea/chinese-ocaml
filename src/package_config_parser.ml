(** 骆言包配置解析模块 - Package Configuration Parser *)

(** Author: Whisky, PR Worker *)

open Package_security
open Package_registry
open Dependency_resolver

(** TOML解析工具函数 *)
let parse_toml_array_value value =
  if String.length value >= 2 && String.get value 0 = '[' && String.get value (String.length value - 1) = ']' then
    let array_content = String.sub value 1 (String.length value - 2) in
    let items = String.split_on_char ',' array_content in
    List.map (fun item ->
      let trimmed = String.trim item in
      if String.length trimmed >= 2 && String.get trimmed 0 = '"' && String.get trimmed (String.length trimmed - 1) = '"' then
        String.sub trimmed 1 (String.length trimmed - 2)
      else trimmed
    ) items
  else [value]

let parse_toml_line line =
  let trim_line = String.trim line in
  if String.length trim_line = 0 || String.get trim_line 0 = '#' then
    None
  else if String.contains trim_line '=' then
    let idx = String.index trim_line '=' in
    let key = String.trim (String.sub trim_line 0 idx) in
    let value = String.trim (String.sub trim_line (idx + 1) (String.length trim_line - idx - 1)) in
    
    let clean_value = 
      if String.length value >= 2 && String.get value 0 = '"' && String.get value (String.length value - 1) = '"' then
        String.sub value 1 (String.length value - 2)
      else if String.length value > 0 && String.get value 0 = '[' then
        let array_items = parse_toml_array_value value in
        (match array_items with
         | first :: _ -> first
         | [] -> "")
      else if String.contains value '.' && 
              (try ignore (float_of_string value); true with _ -> false) then
        value
      else if (try ignore (int_of_string value); true with _ -> false) then
        value
      else if value = "true" || value = "false" then
        value
      else
        value
    in
    Some (key, clean_value)
  else
    None

let parse_nested_toml_section section =
  String.split_on_char '.' section

let parse_toml_content content =
  let lines = String.split_on_char '\n' content in
  let rec parse_lines acc current_section = function
    | [] -> acc
    | line :: rest ->
      let trim_line = String.trim line in
      if String.length trim_line > 0 && String.get trim_line 0 = '[' && String.get trim_line (String.length trim_line - 1) = ']' then
        let section = String.sub trim_line 1 (String.length trim_line - 2) in
        let section_parts = parse_nested_toml_section section in
        let normalized_section = String.concat "." section_parts in
        parse_lines acc (Some normalized_section) rest
      else
        match parse_toml_line line with
        | Some (key, value) ->
          let full_key = match current_section with
            | None -> key
            | Some section -> section ^ "." ^ key
          in
          parse_lines ((full_key, value) :: acc) current_section rest
        | None -> parse_lines acc current_section rest
  in
  List.rev (parse_lines [] None lines)

(** 包配置解析和验证 *)
let parse_package_config content =
  try
    let pairs = parse_toml_content content in
    let get_value key default_value =
      try List.assoc key pairs
      with Not_found -> default_value
    in
    let get_optional_value key =
      try Some (List.assoc key pairs)
      with Not_found -> None
    in
    let parse_dependencies section =
      List.fold_left (fun acc (key, value) ->
        if String.length key > String.length section + 1 &&
           String.sub key 0 (String.length section + 1) = section ^ "." then
          let dep_name = String.sub key (String.length section + 1) (String.length key - String.length section - 1) in
          (match sanitize_package_name dep_name with
           | Ok clean_name ->
             (match parse_version_constraint value with
              | Ok _ -> (clean_name, value) :: acc
              | Error _ -> acc)
           | Error _ -> acc)
        else acc
      ) [] pairs
    in
    let parse_authors author_str =
      if String.contains author_str ',' then
        List.map String.trim (String.split_on_char ',' author_str)
      else if String.contains author_str ';' then
        List.map String.trim (String.split_on_char ';' author_str)
      else if String.length author_str > 0 && String.get author_str 0 = '[' then
        parse_toml_array_value author_str
      else
        [String.trim author_str]
    in
    let config = {
      Package_registry.name = get_value "包信息.名称" "";
      version = get_value "包信息.版本" "1.0.0";
      description = get_optional_value "包信息.描述";
      authors = (match get_optional_value "包信息.作者" with
        | Some author_str -> parse_authors author_str
        | None -> []);
      license = get_optional_value "包信息.许可证";
      homepage = get_optional_value "包信息.主页";
      dependencies = parse_dependencies "依赖";
      dev_dependencies = parse_dependencies "开发依赖";
      build_script = get_optional_value "构建.构建脚本";
      test_script = get_optional_value "构建.测试脚本";
    } in
    if config.name = "" then
      Error "包名称不能为空"
    else
      (* 使用安全验证 *)
      (match sanitize_package_name config.name with
       | Error (InvalidPackageName msg) -> Error msg
       | Error _ -> Error "包名验证失败"
       | Ok _ -> Ok config)
  with
  | exc -> Error ("解析配置文件失败: " ^ Printexc.to_string exc)

let validate_package_config (config : Package_registry.package_config) =
  if config.name = "" then Error "包名称不能为空"
  else if not (is_valid_version config.version) then Error ("无效的版本号: " ^ config.version)
  else Ok ()