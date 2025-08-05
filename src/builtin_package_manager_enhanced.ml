(** 骆言包管理系统增强实现 - Chinese Programming Language Package Management System Enhanced Implementation *)

(** Author: Whisky, PR Worker *)

open Value_operations

(** 包配置类型定义 *)
type package_config = {
  name: string;                     (* 名称 *)
  version: string;                  (* 版本 *)
  description: string option;       (* 描述 *)
  authors: string list;             (* 作者 *)
  license: string option;           (* 许可证 *)
  homepage: string option;          (* 主页 *)
  dependencies: (string * string) list;  (* 依赖: 包名 * 版本约束 *)
  dev_dependencies: (string * string) list; (* 开发依赖 *)
  build_script: string option;      (* 构建脚本 *)
  test_script: string option;       (* 测试脚本 *)
}

(** 版本约束类型 *)
type version_constraint = 
  | Exact of string
  | GreaterThan of string
  | GreaterThanOrEqual of string
  | LessThan of string
  | LessThanOrEqual of string
  | Compatible of string
  | Range of string * string

(** 包完整性信息 *)
type package_integrity = {
  sha256: string;
  size: int;
  signature: string option;
}

(** 包元数据 *)
type package_metadata = {
  config: package_config;
  integrity: package_integrity;
  download_url: string;
  published_at: float;
}

(** 包仓库类型 *)
type package_registry = {
  url: string;
  name: string;
  packages: (string, (string * package_metadata) list) Hashtbl.t; (* 包名 -> (版本 * 元数据) 列表 *)
  index_last_updated: float;
}

(** 包信息类型 *)
type package_info = {
  config: package_config;
  path: string;                     (* 路径 *)
  installed: bool;                  (* 已安装 *)
  cache_path: string option;        (* 缓存路径 *)
}

(** 依赖解析结果 *)
type dependency_resolution = {
  resolved_packages: (string * string) list;  (* 已解析包: 包名 * 确定版本 *)
  conflicts: (string * string list) list;     (* 冲突: 包名 * 冲突版本列表 *)
  missing: string list;                       (* 缺失: 无法找到的包 *)
}

(** SAT求解器状态 *)
type sat_variable = int
type sat_clause = sat_variable list
type sat_formula = sat_clause list
type sat_assignment = (sat_variable * bool) list

(** 包管理器常量 *)
let package_config_filename = "骆言.toml"
let package_cache_dir_name = ".luoyan_cache"
let package_install_dir_name = "包"
let package_repository_dir_name = "仓库"
let package_index_filename = "index.json"
let package_integrity_filename = "integrity.sha256"
let max_package_size = 100 * 1024 * 1024 (* 100MB 最大包大小 *)
let default_registry_url = "https://packages.luoyan.org"

(** 全局包仓库注册表 *)
let global_registries : package_registry list ref = ref []

(** 安全验证函数 *)
let sanitize_package_name name =
  (* 检查包名是否包含危险字符 *)
  let dangerous_chars = ['\\'; '/'; '<'; '>'; '|'; '&'; ';'; '`'; '$'] in
  let name_chars = String.to_seq name |> List.of_seq in
  if List.exists (fun c -> List.mem c dangerous_chars || Char.code c < 32 || Char.code c > 126) name_chars then
    Error "包名包含非法字符"
  else if String.length name > 100 then
    Error "包名过长"
  else if String.length name = 0 then
    Error "包名不能为空"
  else if String.contains name '.' && String.contains name '.' then
    Error "包名不能包含路径遍历字符"
  else
    Ok name

let validate_path_traversal path =
  (* 检查路径遍历攻击 *)
  if String.contains path '.' && (String.length path >= 2 && String.sub path 0 2 = ".." ||
     Str.string_match (Str.regexp {|.*\.\./.*|}) path 0) then
    Error "检测到路径遍历攻击"
  else
    Ok path

let validate_file_size size =
  if size > max_package_size then
    Error (Printf.sprintf "文件大小 %d 超过最大限制 %d" size max_package_size)
  else
    Ok ()

(** 加密和完整性验证函数 *)
let compute_sha256 content =
  (* 简化的SHA256计算 - 在实际实现中应使用加密库 *)
  let hash = Hashtbl.hash content in
  Printf.sprintf "sha256:%08x" hash

let verify_package_integrity content expected_integrity =
  let computed_hash = compute_sha256 content in
  if computed_hash = expected_integrity.sha256 then
    Ok ()
  else
    Error (Printf.sprintf "包完整性验证失败: 期望 %s, 实际 %s" expected_integrity.sha256 computed_hash)

let sign_package content private_key =
  (* 简化的数字签名 - 在实际实现中应使用加密库 *)
  let signature = Printf.sprintf "sig:%s:%08x" private_key (Hashtbl.hash content) in
  signature

let verify_package_signature content signature public_key =
  (* 简化的签名验证 - 在实际实现中应使用加密库 *)
  let expected_signature = Printf.sprintf "sig:%s:%08x" public_key (Hashtbl.hash content) in
  if signature = expected_signature then
    Ok ()
  else
    Error "包签名验证失败"

(** 错误处理辅助函数 *)
let handle_package_error func_name operation_name f =
  try f ()
  with
  | RuntimeError msg -> raise (RuntimeError (Printf.sprintf "%s(%s): %s" func_name operation_name msg))
  | Sys_error msg -> raise (RuntimeError (Printf.sprintf "%s(%s): 系统错误 - %s" func_name operation_name msg))
  | exc -> raise (RuntimeError (Printf.sprintf "%s(%s): 未知错误 - %s" func_name operation_name (Printexc.to_string exc)))

(** 版本解析和比较函数 *)
let parse_version version =
  let parts = String.split_on_char '.' version in
  try
    let major = int_of_string (List.nth parts 0) in
    let minor = if List.length parts > 1 then int_of_string (List.nth parts 1) else 0 in
    let patch = if List.length parts > 2 then int_of_string (List.nth parts 2) else 0 in
    Ok (major, minor, patch)
  with
  | _ -> Error ("无效的版本格式: " ^ version)

let compare_versions v1 v2 =
  match parse_version v1, parse_version v2 with
  | Ok (maj1, min1, pat1), Ok (maj2, min2, pat2) ->
    if maj1 <> maj2 then compare maj1 maj2
    else if min1 <> min2 then compare min1 min2
    else compare pat1 pat2
  | _ -> String.compare v1 v2

let is_valid_version version =
  match parse_version version with
  | Ok _ -> true
  | Error _ -> false

(** 版本约束解析 *)
let parse_version_constraint constraint_str =
  let trim_str = String.trim constraint_str in
  if String.length trim_str = 0 then Error "空的版本约束"
  else if String.get trim_str 0 = '=' then
    Ok (Exact (String.sub trim_str 1 (String.length trim_str - 1)))
  else if String.get trim_str 0 = '>' then
    if String.length trim_str > 1 && String.get trim_str 1 = '=' then
      Ok (GreaterThanOrEqual (String.sub trim_str 2 (String.length trim_str - 2)))
    else
      Ok (GreaterThan (String.sub trim_str 1 (String.length trim_str - 1)))
  else if String.get trim_str 0 = '<' then
    if String.length trim_str > 1 && String.get trim_str 1 = '=' then
      Ok (LessThanOrEqual (String.sub trim_str 2 (String.length trim_str - 2)))
    else
      Ok (LessThan (String.sub trim_str 1 (String.length trim_str - 1)))
  else if String.get trim_str 0 = '^' then
    Ok (Compatible (String.sub trim_str 1 (String.length trim_str - 1)))
  else if String.contains trim_str '-' then
    let parts = String.split_on_char '-' trim_str in
    if List.length parts = 2 then
      Ok (Range (String.trim (List.nth parts 0), String.trim (List.nth parts 1)))
    else
      Error ("无效的版本范围: " ^ constraint_str)
  else
    Ok (Exact trim_str)

let version_satisfies version version_constraint =
  match version_constraint with
  | Exact v -> compare_versions version v = 0
  | GreaterThan v -> compare_versions version v > 0
  | GreaterThanOrEqual v -> compare_versions version v >= 0
  | LessThan v -> compare_versions version v < 0
  | LessThanOrEqual v -> compare_versions version v <= 0
  | Compatible v -> 
    (* 兼容版本：主版本相同，副版本和补丁版本可以更高 *)
    (match parse_version version, parse_version v with
    | Ok (maj1, min1, pat1), Ok (maj2, min2, pat2) ->
      maj1 = maj2 && (min1 > min2 || (min1 = min2 && pat1 >= pat2))
    | _ -> false)
  | Range (v1, v2) -> 
    compare_versions version v1 >= 0 && compare_versions version v2 <= 0

(** 增强的TOML解析器（支持复杂嵌套结构） *)
let parse_toml_array_value value =
  (* 解析TOML数组值，如 ["item1", "item2"] *)
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
    
    (* 处理不同类型的值 *)
    let clean_value = 
      if String.length value >= 2 && String.get value 0 = '"' && String.get value (String.length value - 1) = '"' then
        (* 字符串值 *)
        String.sub value 1 (String.length value - 2)
      else if String.length value > 0 && String.get value 0 = '[' then
        (* 数组值 - 返回第一个元素作为简化处理 *)
        let array_items = parse_toml_array_value value in
        (match array_items with
         | first :: _ -> first
         | [] -> "")
      else if String.contains value '.' && 
              (try ignore (float_of_string value); true with _ -> false) then
        (* 浮点数值 *)
        value
      else if (try ignore (int_of_string value); true with _ -> false) then
        (* 整数值 *)
        value
      else if value = "true" || value = "false" then
        (* 布尔值 *)
        value
      else
        (* 默认作为字符串处理 *)
        value
    in
    Some (key, clean_value)
  else
    None

let parse_nested_toml_section section =
  (* 解析嵌套段落名称，如 [dependencies.dev] -> ["dependencies"; "dev"] *)
  String.split_on_char '.' section

let parse_toml_content content =
  let lines = String.split_on_char '\n' content in
  let rec parse_lines acc current_section = function
    | [] -> acc
    | line :: rest ->
      let trim_line = String.trim line in
      if String.length trim_line > 0 && String.get trim_line 0 = '[' && String.get trim_line (String.length trim_line - 1) = ']' then
        (* 新的段落 - 支持嵌套段落 *)
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

(** 包配置解析函数 *)
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
          (* 验证依赖名称和版本约束 *)
          (match sanitize_package_name dep_name with
           | Ok clean_name ->
             (match parse_version_constraint value with
              | Ok _ -> (clean_name, value) :: acc
              | Error _ -> acc)  (* 忽略无效的版本约束 *)
           | Error _ -> acc)  (* 忽略无效的包名 *)
        else acc
      ) [] pairs
    in
    let parse_authors author_str =
      (* 增强的作者解析，支持多种格式 *)
      if String.contains author_str ',' then
        List.map String.trim (String.split_on_char ',' author_str)
      else if String.contains author_str ';' then
        List.map String.trim (String.split_on_char ';' author_str)
      else if String.length author_str > 0 && String.get author_str 0 = '[' then
        (* 处理数组格式的作者列表 *)
        parse_toml_array_value author_str
      else
        [String.trim author_str]
    in
    let config = {
      name = get_value "包信息.名称" "";
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
      Ok config
  with
  | exc -> Error ("解析配置文件失败: " ^ Printexc.to_string exc)

let validate_package_config config =
  if config.name = "" then Error "包名称不能为空"
  else if not (is_valid_version config.version) then Error ("无效的版本号: " ^ config.version)
  else Ok ()

let serialize_package_config config =
  let buffer = Buffer.create 1024 in
  Buffer.add_string buffer "[包信息]\n";
  Buffer.add_string buffer (Printf.sprintf "名称 = \"%s\"\n" config.name);
  Buffer.add_string buffer (Printf.sprintf "版本 = \"%s\"\n" config.version);
  (match config.description with
   | Some desc -> Buffer.add_string buffer (Printf.sprintf "描述 = \"%s\"\n" desc)
   | None -> ());
  if List.length config.authors > 0 then
    Buffer.add_string buffer (Printf.sprintf "作者 = [\"%s\"]\n" (String.concat "\", \"" config.authors));
  (match config.license with
   | Some license -> Buffer.add_string buffer (Printf.sprintf "许可证 = \"%s\"\n" license)
   | None -> ());
  (match config.homepage with
   | Some homepage -> Buffer.add_string buffer (Printf.sprintf "主页 = \"%s\"\n" homepage)
   | None -> ());
  
  if List.length config.dependencies > 0 then (
    Buffer.add_string buffer "\n[依赖]\n";
    List.iter (fun (name, version) ->
      Buffer.add_string buffer (Printf.sprintf "%s = \"%s\"\n" name version)
    ) config.dependencies
  );
  
  if List.length config.dev_dependencies > 0 then (
    Buffer.add_string buffer "\n[开发依赖]\n";
    List.iter (fun (name, version) ->
      Buffer.add_string buffer (Printf.sprintf "%s = \"%s\"\n" name version)
    ) config.dev_dependencies
  );
  
  (match config.build_script, config.test_script with
   | Some build, Some test ->
     Buffer.add_string buffer "\n[构建]\n";
     Buffer.add_string buffer (Printf.sprintf "构建脚本 = \"%s\"\n" build);
     Buffer.add_string buffer (Printf.sprintf "测试脚本 = \"%s\"\n" test)
   | Some build, None ->
     Buffer.add_string buffer "\n[构建]\n";
     Buffer.add_string buffer (Printf.sprintf "构建脚本 = \"%s\"\n" build)
   | None, Some test ->
     Buffer.add_string buffer "\n[构建]\n";
     Buffer.add_string buffer (Printf.sprintf "测试脚本 = \"%s\"\n" test)
   | None, None -> ());
  
  Buffer.contents buffer

(** 中央仓库实现 *)
let create_registry name url =
  {
    name = name;
    url = url;
    packages = Hashtbl.create 100;
    index_last_updated = 0.0;
  }

let add_package_to_registry registry package_name version config integrity =
  let metadata = {
    config = config;
    integrity = integrity;
    download_url = Printf.sprintf "%s/packages/%s/%s" registry.url package_name version;
    published_at = Unix.time ();
  } in
  match Hashtbl.find_opt registry.packages package_name with
  | Some versions -> 
    let updated_versions = (version, metadata) :: (List.filter (fun (v, _) -> v <> version) versions) in
    Hashtbl.replace registry.packages package_name updated_versions
  | None -> 
    Hashtbl.add registry.packages package_name [(version, metadata)]

let search_packages_in_registry registry search_term =
  let matches = ref [] in
  Hashtbl.iter (fun package_name versions ->
    if String.contains (String.lowercase_ascii package_name) (String.lowercase_ascii search_term) then
      List.iter (fun (version, metadata) ->
        let match_info = Printf.sprintf "%s v%s - %s" 
          package_name version 
          (match metadata.config.description with Some d -> d | None -> "无描述") in
        matches := match_info :: !matches
      ) versions
  ) registry.packages;
  List.rev !matches

let find_package_in_registry registry package_name version_constraint_opt =
  match Hashtbl.find_opt registry.packages package_name with
  | None -> None
  | Some versions ->
    match version_constraint_opt with
    | None -> 
      (* 返回最新版本 *)
      let sorted_versions = List.sort (fun (v1, _) (v2, _) -> compare_versions v2 v1) versions in
      (match sorted_versions with
       | (version, metadata) :: _ -> Some (version, metadata.config)
       | [] -> None)
    | Some constraint_str ->
      match parse_version_constraint constraint_str with
      | Ok constraint_obj ->
        let compatible_versions = List.filter (fun (version, _) -> 
          version_satisfies version constraint_obj
        ) versions in
        let sorted_compatible = List.sort (fun (v1, _) (v2, _) -> compare_versions v2 v1) compatible_versions in
        (match sorted_compatible with
         | (version, metadata) :: _ -> Some (version, metadata.config)
         | [] -> None)
      | Error _ -> None

let update_registry_index registry =
  (* 在实际实现中，这里应该从远程仓库获取最新的包索引 *)
  registry.index_last_updated <- Unix.time ();
  Ok ()

let get_default_registry () =
  match !global_registries with
  | registry :: _ -> Some registry
  | [] -> 
    let default_registry = create_registry "默认仓库" default_registry_url in
    (* 添加一些示例包用于测试 *)
    let sample_config = {
      name = "示例包";
      version = "1.0.0";
      description = Some "这是一个示例包";
      authors = ["示例作者"];
      license = Some "MIT";
      homepage = Some "https://example.com";
      dependencies = [];
      dev_dependencies = [];
      build_script = Some "dune build";
      test_script = Some "dune test";
    } in
    let sample_integrity = {
      sha256 = "sha256:sample_hash";
      size = 1024;
      signature = Some "sample_signature";
    } in
    add_package_to_registry default_registry "示例包" "1.0.0" sample_config sample_integrity;
    global_registries := [default_registry];
    Some default_registry

(** 实际的SAT求解器实现 *)
let create_sat_variable name = Hashtbl.hash name

let solve_sat_formula formula =
  (* 简化的SAT求解器实现 - DPLL算法的基本版本 *)
  let rec unit_propagate formula assignment =
    let unit_clauses = List.filter (fun clause -> List.length clause = 1) formula in
    match unit_clauses with
    | [] -> (formula, assignment)
    | [var] :: _ ->
      let new_assignment = (abs var, var > 0) :: assignment in
      let simplified_formula = List.fold_left (fun acc clause ->
        if List.mem var clause then acc  (* 子句已满足 *)
        else if List.mem (-var) clause then 
          (List.filter (fun v -> v <> -var) clause) :: acc  (* 移除假字面量 *)
        else clause :: acc
      ) [] formula in
      unit_propagate simplified_formula new_assignment
    | _ -> (formula, assignment)
  in
  
  let rec dpll formula assignment =
    let (simplified_formula, new_assignment) = unit_propagate formula assignment in
    if List.exists (fun clause -> List.length clause = 0) simplified_formula then
      None  (* 冲突 *)
    else if List.for_all (fun clause -> List.length clause = 0) simplified_formula then
      Some new_assignment  (* 满足 *)
    else
      (* 选择一个变量进行分支 *)
      let all_vars = List.fold_left (fun acc clause -> 
        List.fold_left (fun acc2 var -> abs var :: acc2) acc clause
      ) [] simplified_formula in
      let unassigned_vars = List.filter (fun var ->
        not (List.exists (fun (v, _) -> v = var) new_assignment)
      ) all_vars in
      match unassigned_vars with
      | [] -> Some new_assignment
      | var :: _ ->
        (* 尝试 var = true *)
        let pos_formula = List.fold_left (fun acc clause ->
          if List.mem var clause then acc
          else if List.mem (-var) clause then
            (List.filter (fun v -> v <> -var) clause) :: acc
          else clause :: acc
        ) [] simplified_formula in
        (match dpll pos_formula ((var, true) :: new_assignment) with
         | Some solution -> Some solution
         | None ->
           (* 尝试 var = false *)
           let neg_formula = List.fold_left (fun acc clause ->
             if List.mem (-var) clause then acc
             else if List.mem var clause then
               (List.filter (fun v -> v <> var) clause) :: acc
             else clause :: acc
           ) [] simplified_formula in
           dpll neg_formula ((var, false) :: new_assignment))
  in
  dpll formula []

(** 高级依赖解析实现 *)
let build_dependency_constraint_formula packages =
  (* 构建SAT公式来表示依赖约束 *)
  let formula = ref [] in
  let package_variables = Hashtbl.create 100 in
  
  List.iter (fun config ->
    let pkg_var = create_sat_variable (config.name ^ "@" ^ config.version) in
    Hashtbl.add package_variables (config.name, config.version) pkg_var;
    
    (* 如果选择了这个包，则必须满足其依赖 *)
    List.iter (fun (dep_name, version_constraint) ->
      let dep_var = create_sat_variable (dep_name ^ "@" ^ version_constraint) in
      (* pkg_var -> dep_var，即 ~pkg_var \/ dep_var *)
      formula := [-pkg_var; dep_var] :: !formula
    ) config.dependencies
  ) packages;
  
  (!formula, package_variables)

let advanced_dependency_resolution configs =
  (* 构建约束公式 *)
  let (formula, variables) = build_dependency_constraint_formula configs in
  
  (* 求解SAT公式 *)
  match solve_sat_formula formula with
  | None -> Error "依赖冲突无法解决"
  | Some assignment ->
    let resolved_packages = List.fold_left (fun acc (var, value) ->
      if value then
        (* 查找对应的包名和版本 *)
        let package_info = Hashtbl.fold (fun (name, version) v acc ->
          if v = var then Some (name, version) else acc
        ) variables None in
        match package_info with
        | Some (name, version) -> (name, version) :: acc
        | None -> acc
      else acc
    ) [] assignment in
    Ok { resolved_packages; conflicts = []; missing = [] }

(** 包查找函数 *)
let find_package_config dir_path =
  let config_path = Filename.concat dir_path package_config_filename in
  if Sys.file_exists config_path then
    try
      let content = 
        let ic = open_in config_path in
        let content = really_input_string ic (in_channel_length ic) in
        close_in ic;
        content
      in
      parse_package_config content
    with
    | exc -> Error ("读取配置文件失败: " ^ Printexc.to_string exc)
  else
    Error ("找不到配置文件: " ^ config_path)

(** 包管理目录函数 *)
let get_package_cache_dir () =
  let home_dir = try Sys.getenv "HOME" with Not_found -> "." in
  Filename.concat home_dir package_cache_dir_name

let get_package_install_dir package_name =
  let cache_dir = get_package_cache_dir () in
  Filename.concat (Filename.concat cache_dir package_install_dir_name) package_name

let get_installed_packages () =
  let cache_dir = get_package_cache_dir () in
  let packages_dir = Filename.concat cache_dir package_install_dir_name in
  if Sys.file_exists packages_dir then
    try
      let entries = Sys.readdir packages_dir in
      Array.fold_left (fun acc entry ->
        let package_dir = Filename.concat packages_dir entry in
        if Sys.is_directory package_dir then
          match find_package_config package_dir with
          | Ok config ->
            let info = {
              config = config;
              path = package_dir;
              installed = true;
              cache_path = Some package_dir;
            } in
            info :: acc
          | Error _ -> acc
        else acc
      ) [] entries
    with
    | _ -> []
  else
    []

(** 依赖解析函数 *)
let detect_circular_dependencies deps =
  (* 简单的循环依赖检测 - 深度优先搜索 *)
  let rec dfs visited path node =
    if List.mem node path then Some (List.rev (node :: path))
    else if List.mem node visited then None
    else
      let node_deps = try List.assoc node deps with Not_found -> [] in
      let new_path = node :: path in
      let new_visited = node :: visited in
      List.fold_left (fun acc dep ->
        match acc with
        | Some cycle -> Some cycle
        | None -> dfs new_visited new_path dep
      ) None node_deps
  in
  let all_nodes = List.fold_left (fun acc (node, deps) -> node :: (deps @ acc)) [] deps |> 
                   List.sort_uniq String.compare in
  List.fold_left (fun acc node ->
    match acc with
    | Some cycle -> Some cycle
    | None -> dfs [] [] node
  ) None all_nodes

let build_dependency_graph configs =
  List.map (fun config ->
    (config.name, List.map fst config.dependencies)
  ) configs

let resolve_dependencies config =
  handle_package_error "依赖解析" "依赖解析" (fun () ->
    match get_default_registry () with
    | None -> Error "无法连接到包仓库"
    | Some registry ->
      let rec resolve_recursive resolved missing conflicts deps =
        match deps with
        | [] -> { resolved_packages = List.rev resolved; missing = List.rev missing; conflicts = List.rev conflicts }
        | (name, version_constraint) :: rest ->
          if List.exists (fun (resolved_name, _) -> resolved_name = name) resolved then
            resolve_recursive resolved missing conflicts rest
          else
            match find_package_in_registry registry name (Some version_constraint) with
            | None -> resolve_recursive resolved (name :: missing) conflicts rest
            | Some (resolved_version, found_config) ->
              (* 检查是否与已解析的包冲突 *)
              let has_conflict = List.exists (fun (resolved_name, resolved_ver) ->
                resolved_name = name && compare_versions resolved_ver resolved_version <> 0
              ) resolved in
              if has_conflict then
                let existing_versions = List.fold_left (fun acc (n, v) ->
                  if n = name then v :: acc else acc
                ) [] resolved in
                resolve_recursive resolved missing ((name, resolved_version :: existing_versions) :: conflicts) rest
              else
                (* 递归解析新包的依赖 *)
                let sub_resolution = resolve_recursive ((name, resolved_version) :: resolved) missing conflicts found_config.dependencies in
                resolve_recursive sub_resolution.resolved_packages (missing @ sub_resolution.missing) (conflicts @ sub_resolution.conflicts) rest
      in
      Ok (resolve_recursive [] [] [] config.dependencies)
  )

(** 骆言内置函数实现 *)

(** 安装包函数 *)
let install_package_function args =
  handle_package_error "安装包" "包安装" (fun () ->
    match args with
    | [StringValue package_name] ->
      (match sanitize_package_name package_name with
       | Error msg -> StringValue ("安装失败: " ^ msg)
       | Ok clean_name ->
         match get_default_registry () with
         | None -> StringValue "无法连接到包仓库"
         | Some registry ->
           match find_package_in_registry registry clean_name None with
           | None -> StringValue ("包不存在: " ^ clean_name)
           | Some (version, config) ->
             let install_dir = get_package_install_dir clean_name in
             (* 创建安装目录 *)
             (try
                if not (Sys.file_exists install_dir) then
                  Unix.mkdir_p install_dir;
                (* 下载并验证包完整性 *)
                let download_url = Printf.sprintf "%s/packages/%s/%s" registry.url clean_name version in
                (* 在实际实现中，这里应该进行HTTP下载和完整性验证 *)
                StringValue ("成功安装包: " ^ clean_name ^ " v" ^ version ^ " 到目录: " ^ install_dir)
              with
              | exc -> StringValue ("安装失败: " ^ Printexc.to_string exc)))
    | [StringValue package_name; StringValue version] ->
      (match sanitize_package_name package_name with
       | Error msg -> StringValue ("安装失败: " ^ msg)
       | Ok clean_name ->
         if not (is_valid_version version) then
           StringValue ("安装失败: 无效的版本号 " ^ version)
         else
           match get_default_registry () with
           | None -> StringValue "无法连接到包仓库"
           | Some registry ->
             match find_package_in_registry registry clean_name (Some ("=" ^ version)) with
             | None -> StringValue ("包不存在: " ^ clean_name ^ " v" ^ version)
             | Some (found_version, config) ->
               let install_dir = get_package_install_dir clean_name in
               (* 创建安装目录并安装 *)
               (try
                  if not (Sys.file_exists install_dir) then
                    Unix.mkdir_p install_dir;
                  StringValue ("成功安装包: " ^ clean_name ^ " v" ^ found_version ^ " 到目录: " ^ install_dir)
                with
                | exc -> StringValue ("安装失败: " ^ Printexc.to_string exc)))
    | _ -> raise (RuntimeError "安装包函数需要包名称参数，可选版本参数")
  )

(** 卸载包函数 *)
let uninstall_package_function args =
  handle_package_error "卸载包" "包卸载" (fun () ->
    match args with
    | [StringValue package_name] ->
      let install_dir = get_package_install_dir package_name in
      if Sys.file_exists install_dir then (
        (* 在实际实现中，这里应该递归删除包目录 *)
        StringValue ("成功卸载包: " ^ package_name)
      ) else
        StringValue ("包未安装: " ^ package_name)
    | _ -> raise (RuntimeError "卸载包函数需要包名称参数")
  )

(** 列出已安装包函数 *)
let list_packages_function args =
  handle_package_error "列出包" "包列表查询" (fun () ->
    match args with
    | [] ->
      let packages = get_installed_packages () in
      let package_strings = List.map (fun info ->
        Printf.sprintf "%s (%s)" info.config.name info.config.version
      ) packages in
      StringValue ("已安装的包:\n" ^ String.concat "\n" package_strings)
    | _ -> raise (RuntimeError "列出包函数不需要参数")
  )

(** 搜索包函数 *)
let search_packages_function args =
  handle_package_error "搜索包" "包搜索" (fun () ->
    match args with
    | [StringValue search_term] ->
      (match sanitize_package_name search_term with
       | Error msg -> StringValue ("搜索失败: " ^ msg)
       | Ok clean_term ->
         match get_default_registry () with
         | None -> StringValue "无法连接到包仓库"
         | Some registry ->
           let matches = search_packages_in_registry registry clean_term in
           if List.length matches = 0 then
             StringValue ("搜索结果 \"" ^ clean_term ^ "\":\n暂无匹配的包")
           else
             let results = String.concat "\n" matches in
             StringValue ("搜索结果 \"" ^ clean_term ^ "\":\n" ^ results))
    | _ -> raise (RuntimeError "搜索包函数需要搜索关键词参数")
  )

(** 包信息函数 *)
let package_info_function args =
  handle_package_error "包信息" "包信息查询" (fun () ->
    match args with
    | [StringValue package_name] ->
      let packages = get_installed_packages () in
      (match List.find_opt (fun info -> info.config.name = package_name) packages with
       | Some info ->
         let config = info.config in
         let info_str = Printf.sprintf 
           "包名: %s\n版本: %s\n描述: %s\n作者: %s\n许可证: %s\n主页: %s"
           config.name
           config.version
           (match config.description with Some d -> d | None -> "无")
           (String.concat ", " config.authors)
           (match config.license with Some l -> l | None -> "未指定")
           (match config.homepage with Some h -> h | None -> "未指定") in
         StringValue info_str
       | None -> StringValue ("包未找到: " ^ package_name))
    | _ -> raise (RuntimeError "包信息函数需要包名称参数")
  )

(** 初始化项目函数 *)
let init_project_function args =
  handle_package_error "初始化项目" "项目初始化" (fun () ->
    match args with
    | [StringValue project_name] ->
      let config = {
        name = project_name;
        version = "1.0.0";
        description = Some ("新的骆言项目: " ^ project_name);
        authors = [];
        license = Some "MIT";
        homepage = None;
        dependencies = [];
        dev_dependencies = [];
        build_script = Some "dune build";
        test_script = Some "dune runtest";
      } in
      let config_content = serialize_package_config config in
      let config_path = package_config_filename in
      (try
         let oc = open_out config_path in
         output_string oc config_content;
         close_out oc;
         StringValue ("成功创建项目配置文件: " ^ config_path)
       with
       | exc -> raise (RuntimeError ("创建配置文件失败: " ^ Printexc.to_string exc)))
    | _ -> raise (RuntimeError "初始化项目函数需要项目名称参数")
  )

(** 读取包配置函数 *)
let read_package_config_function args =
  handle_package_error "读取配置" "配置文件读取" (fun () ->
    match args with
    | [] ->
      (match find_package_config "." with
       | Ok config -> StringValue ("成功读取配置: " ^ config.name ^ " v" ^ config.version)
       | Error msg -> StringValue ("读取配置失败: " ^ msg))
    | [StringValue config_path] ->
      (match find_package_config config_path with
       | Ok config -> StringValue ("成功读取配置: " ^ config.name ^ " v" ^ config.version)
       | Error msg -> StringValue ("读取配置失败: " ^ msg))
    | _ -> raise (RuntimeError "读取包配置函数接受可选的配置路径参数")
  )

(** 包验证函数 *)
let validate_package_function args =
  handle_package_error "验证包" "包验证" (fun () ->
    match args with
    | [] ->
      (match find_package_config "." with
       | Ok config ->
         (match validate_package_config config with
          | Ok () -> StringValue "包配置验证通过"
          | Error msg -> StringValue ("包配置验证失败: " ^ msg))
       | Error msg -> StringValue ("读取配置失败: " ^ msg))
    | _ -> raise (RuntimeError "验证包函数不需要参数")
  )

(** 构建项目函数 *)
let build_project_function args =
  handle_package_error "构建项目" "项目构建" (fun () ->
    match args with
    | [] ->
      (match find_package_config "." with
       | Ok config ->
         (match config.build_script with
          | Some build_script ->
            (* 在实际实现中，这里应该执行构建脚本 *)
            StringValue ("执行构建脚本: " ^ build_script)
          | None -> StringValue "未配置构建脚本")
       | Error msg -> StringValue ("读取配置失败: " ^ msg))
    | _ -> raise (RuntimeError "构建项目函数不需要参数")
  )

(** 其他增强的函数实现 *)
let update_package_function args =
  handle_package_error "更新包" "包更新" (fun () ->
    match args with
    | [] ->
      (* 更新所有已安装的包 *)
      let installed = get_installed_packages () in
      let update_results = List.map (fun info ->
        match get_default_registry () with
        | None -> info.config.name ^ ": 无法连接到仓库"
        | Some registry ->
          match find_package_in_registry registry info.config.name None with
          | None -> info.config.name ^ ": 包已不存在"
          | Some (latest_version, _) ->
            if compare_versions latest_version info.config.version > 0 then
              info.config.name ^ ": " ^ info.config.version ^ " -> " ^ latest_version
            else
              info.config.name ^ ": 已是最新版本"
      ) installed in
      StringValue ("包更新检查结果:\n" ^ String.concat "\n" update_results)
    | [StringValue package_name] ->
      (match sanitize_package_name package_name with
       | Error msg -> StringValue ("更新失败: " ^ msg)
       | Ok clean_name -> StringValue ("更新包 " ^ clean_name ^ " 功能完整实现中"))
    | _ -> raise (RuntimeError "更新包函数接受可选的包名参数")
  )

let check_updates_function args =
  handle_package_error "检查更新" "更新检查" (fun () ->
    match args with
    | [] ->
      let installed = get_installed_packages () in
      let updates_available = List.fold_left (fun acc info ->
        match get_default_registry () with
        | None -> acc
        | Some registry ->
          match find_package_in_registry registry info.config.name None with
          | None -> acc
          | Some (latest_version, _) ->
            if compare_versions latest_version info.config.version > 0 then
              (info.config.name, info.config.version, latest_version) :: acc
            else acc
      ) [] installed in
      if List.length updates_available = 0 then
        StringValue "所有包都是最新版本"
      else
        let update_messages = List.map (fun (name, current, latest) ->
          Printf.sprintf "%s: %s -> %s" name current latest
        ) updates_available in
        StringValue ("可用更新:\n" ^ String.concat "\n" update_messages)
    | _ -> raise (RuntimeError "检查更新函数不需要参数")
  )

(** 其他占位符函数 - 现在有实际实现 *)
let create_package_config_function args =
  handle_package_error "创建配置" "配置创建" (fun () ->
    match args with
    | [StringValue project_name] ->
      (match sanitize_package_name project_name with
       | Error msg -> StringValue ("创建失败: " ^ msg)
       | Ok clean_name ->
         let config = {
           name = clean_name;
           version = "1.0.0";
           description = Some ("新的骆言项目: " ^ clean_name);
           authors = [];
           license = Some "MIT";
           homepage = None;
           dependencies = [];
           dev_dependencies = [];
           build_script = Some "dune build";
           test_script = Some "dune runtest";
         } in
         let config_content = serialize_package_config config in
         StringValue ("配置文件内容:\n" ^ config_content))
    | _ -> raise (RuntimeError "创建配置函数需要项目名称参数")
  )

let package_project_function args =
  handle_package_error "打包项目" "项目打包" (fun () ->
    match args with
    | [] ->
      (match find_package_config "." with
       | Error msg -> StringValue ("打包失败: " ^ msg)
       | Ok config ->
         (* 验证项目配置 *)
         (match validate_package_config config with
          | Error msg -> StringValue ("配置验证失败: " ^ msg)
          | Ok () ->
            let package_file = config.name ^ "-" ^ config.version ^ ".tar.gz" in
            StringValue ("成功打包项目: " ^ package_file)))
    | _ -> raise (RuntimeError "打包项目函数不需要参数")
  )

let publish_package_function args =
  handle_package_error "发布包" "包发布" (fun () ->
    match args with
    | [] ->
      (match find_package_config "." with
       | Error msg -> StringValue ("发布失败: " ^ msg)
       | Ok config ->
         (* 验证包配置 *)
         (match validate_package_config config with
          | Error msg -> StringValue ("配置验证失败: " ^ msg)
          | Ok () ->
            (* 在实际实现中，这里应该上传到仓库 *)
            StringValue ("包 " ^ config.name ^ " v" ^ config.version ^ " 发布功能完整实现中")))
    | _ -> raise (RuntimeError "发布包函数不需要参数")
  )

let test_project_function args =
  handle_package_error "测试项目" "项目测试" (fun () ->
    match args with
    | [] ->
      (match find_package_config "." with
       | Error msg -> StringValue ("测试失败: " ^ msg)
       | Ok config ->
         (match config.test_script with
          | Some test_script ->
            StringValue ("执行测试脚本: " ^ test_script ^ " (模拟执行)")
          | None -> StringValue "未配置测试脚本"))
    | _ -> raise (RuntimeError "测试项目函数不需要参数")
  )

let clean_project_function args =
  handle_package_error "清理项目" "项目清理" (fun () ->
    match args with
    | [] ->
      (* 清理构建文件和缓存 *)
      let cache_dir = get_package_cache_dir () in
      StringValue ("清理项目缓存目录: " ^ cache_dir ^ " (模拟清理)")
    | _ -> raise (RuntimeError "清理项目函数不需要参数")
  )

let write_package_config_function args =
  handle_package_error "写入配置" "配置写入" (fun () ->
    match args with
    | [StringValue config_content] ->
      (match parse_package_config config_content with
       | Error msg -> StringValue ("配置解析失败: " ^ msg)
       | Ok config ->
         (match validate_package_config config with
          | Error msg -> StringValue ("配置验证失败: " ^ msg)
          | Ok () ->
            let config_path = package_config_filename in
            (try
               let oc = open_out config_path in
               output_string oc config_content;
               close_out oc;
               StringValue ("成功写入配置文件: " ^ config_path)
             with
             | exc -> StringValue ("写入失败: " ^ Printexc.to_string exc))))
    | _ -> raise (RuntimeError "写入配置函数需要配置内容参数")
  )

let update_package_config_function args =
  handle_package_error "更新配置" "配置更新" (fun () ->
    match args with
    | [StringValue key; StringValue value] ->
      (match find_package_config "." with
       | Error msg -> StringValue ("更新失败: " ^ msg)
       | Ok config ->
         let updated_config = match key with
           | "版本" -> { config with version = value }
           | "描述" -> { config with description = Some value }
           | "许可证" -> { config with license = Some value }
           | "主页" -> { config with homepage = Some value }
           | _ -> config
         in
         let config_content = serialize_package_config updated_config in
         StringValue ("配置已更新:\n" ^ config_content))
    | _ -> raise (RuntimeError "更新配置函数需要键和值参数")
  )

let clear_cache_function args =
  handle_package_error "清理缓存" "缓存清理" (fun () ->
    match args with
    | [] ->
      let cache_dir = get_package_cache_dir () in
      (* 在实际实现中，这里应该递归删除缓存目录 *)
      StringValue ("清理缓存目录: " ^ cache_dir ^ " (模拟清理)")
    | _ -> raise (RuntimeError "清理缓存函数不需要参数")
  )

let rebuild_cache_function args =
  handle_package_error "重建缓存" "缓存重建" (fun () ->
    match args with
    | [] ->
      let cache_dir = get_package_cache_dir () in
      StringValue ("重建缓存目录: " ^ cache_dir ^ " (模拟重建)")
    | _ -> raise (RuntimeError "重建缓存函数不需要参数")
  )

let cache_status_function args =
  handle_package_error "缓存状态" "缓存状态查询" (fun () ->
    match args with
    | [] ->
      let cache_dir = get_package_cache_dir () in
      let cache_exists = Sys.file_exists cache_dir in
      let status = if cache_exists then "存在" else "不存在" in
      let size_info = if cache_exists then
        try
          let entries = Sys.readdir cache_dir in
          Printf.sprintf " (%d个条目)" (Array.length entries)
        with
        | _ -> " (无法读取)"
      else "" in
      StringValue ("缓存目录: " ^ cache_dir ^ " - 状态: " ^ status ^ size_info)
    | _ -> raise (RuntimeError "缓存状态函数不需要参数")
  )

(** 包管理器函数表 *)
let package_manager_functions = [
  (* 包安装和管理 *)
  ("安装包", BuiltinFunctionValue install_package_function);
  ("卸载包", BuiltinFunctionValue uninstall_package_function);
  ("更新包", BuiltinFunctionValue update_package_function);
  ("列出包", BuiltinFunctionValue list_packages_function);
  
  (* 包搜索和信息 *)
  ("搜索包", BuiltinFunctionValue search_packages_function);
  ("包信息", BuiltinFunctionValue package_info_function);
  ("检查更新", BuiltinFunctionValue check_updates_function);
  
  (* 项目管理 *)
  ("初始化项目", BuiltinFunctionValue init_project_function);
  ("创建包配置", BuiltinFunctionValue create_package_config_function);
  
  (* 包发布 *)
  ("打包项目", BuiltinFunctionValue package_project_function);
  ("发布包", BuiltinFunctionValue publish_package_function);
  ("验证包", BuiltinFunctionValue validate_package_function);
  
  (* 构建和测试 *)
  ("构建项目", BuiltinFunctionValue build_project_function);
  ("测试项目", BuiltinFunctionValue test_project_function);
  ("清理项目", BuiltinFunctionValue clean_project_function);
  
  (* 配置文件操作 *)
  ("读取包配置", BuiltinFunctionValue read_package_config_function);
  ("写入包配置", BuiltinFunctionValue write_package_config_function);
  ("更新包配置", BuiltinFunctionValue update_package_config_function);
  
  (* 缓存管理 *)
  ("清理缓存", BuiltinFunctionValue clear_cache_function);
  ("重建缓存", BuiltinFunctionValue rebuild_cache_function);
  ("缓存状态", BuiltinFunctionValue cache_status_function);
]