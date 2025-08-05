(** 骆言包配置解析模块 - Package Configuration Parser *)

(** Author: Whisky, PR Worker *)

open Package_security
open Package_registry

(** TOML解析工具函数 *)
let parse_toml_line line =
  let trim_line = String.trim line in
  if String.length trim_line = 0 || String.get trim_line 0 = '#' then
    None
  else
    match String.index_opt trim_line '=' with
    | None -> None
    | Some eq_pos ->
      let key_raw = String.trim (String.sub trim_line 0 eq_pos) in
      let value_raw = String.trim (String.sub trim_line (eq_pos + 1) (String.length trim_line - eq_pos - 1)) in
      
      let key = sanitize_package_name key_raw |> function
        | Ok name -> name
        | Error _ -> key_raw
      in
      
      let value = 
        if String.length value_raw >= 2 && 
           String.get value_raw 0 = '"' && 
           String.get value_raw (String.length value_raw - 1) = '"' then
          String.sub value_raw 1 (String.length value_raw - 2)
        else
          value_raw
      in
      Some (key, value)

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
          (dep_name, value) :: acc
        else acc
      ) [] pairs |> List.rev
    in
    
    let name = get_value "name" "" in
    let version = get_value "version" "0.1.0" in
    let description = get_optional_value "description" in
    let authors = 
      let authors_str = get_value "authors" "" in
      if String.length authors_str > 0 then
        String.split_on_char ',' authors_str |> List.map String.trim
      else []
    in
    let license = get_optional_value "license" in
    let homepage = get_optional_value "homepage" in
    let dependencies = parse_dependencies "dependencies" in
    let dev_dependencies = parse_dependencies "dev-dependencies" in
    let build_script = get_optional_value "build-script" in
    let test_script = get_optional_value "test-script" in
    
    (* 验证必填字段 *)
    if String.length name = 0 then
      Error "包名称不能为空"
    else
      (* 安全性验证 *)
      match sanitize_package_name name with
      | Error err -> Error (match err with
        | InvalidPackageName msg -> msg
        | PathTraversalAttack msg -> msg
        | UnicodeNormalizationAttack -> "检测到Unicode规范化攻击"
        | HomographAttack msg -> msg
        | ReservedNameViolation msg -> msg
        | FileSizeExceeded (actual, max_size) -> Printf.sprintf "文件过大: %d > %d" actual max_size
        | IntegrityCheckFailed (expected, actual) -> Printf.sprintf "完整性验证失败: 期望 %s, 实际 %s" expected actual
        | SignatureVerificationFailed -> "数字签名验证失败")
      | Ok sanitized_name ->
        Ok {
          name = sanitized_name;
          version = version;
          description = description;
          authors = authors;
          license = license;
          homepage = homepage;
          dependencies = dependencies;
          dev_dependencies = dev_dependencies;
          build_script = build_script;
          test_script = test_script;
        }
  with
  | SecurityError err -> Error ("安全错误: " ^ (match err with
    | InvalidPackageName msg -> msg
    | PathTraversalAttack msg -> msg
    | UnicodeNormalizationAttack -> "检测到Unicode规范化攻击"
    | HomographAttack msg -> msg
    | ReservedNameViolation msg -> msg
    | _ -> "未知安全错误"))
  | exn -> Error ("解析错误: " ^ Printexc.to_string exn)

(** 验证包配置 *)
let validate_package_config config =
  try
    (* 基本验证 *)
    if String.length config.name = 0 then
      Error "包名称不能为空"
    else if String.length config.version = 0 then
      Error "版本号不能为空"
    else
      (* 安全验证 *)
      match sanitize_package_name config.name with
      | Error err -> Error (match err with
        | InvalidPackageName msg -> msg
        | PathTraversalAttack msg -> msg
        | UnicodeNormalizationAttack -> "检测到Unicode规范化攻击"
        | HomographAttack msg -> msg
        | ReservedNameViolation msg -> msg
        | FileSizeExceeded (actual, max_size) -> Printf.sprintf "文件过大: %d > %d" actual max_size
        | IntegrityCheckFailed (expected, actual) -> Printf.sprintf "完整性验证失败: 期望 %s, 实际 %s" expected actual
        | SignatureVerificationFailed -> "数字签名验证失败")
      | Ok _ -> Ok ()
  with
  | SecurityError err -> Error ("安全错误: " ^ (match err with
    | InvalidPackageName msg -> msg
    | PathTraversalAttack msg -> msg
    | UnicodeNormalizationAttack -> "检测到Unicode规范化攻击"
    | HomographAttack msg -> msg
    | ReservedNameViolation msg -> msg
    | _ -> "未知安全错误"))
  | exn -> Error ("验证错误: " ^ Printexc.to_string exn)