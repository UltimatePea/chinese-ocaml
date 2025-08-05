(** 骆言包管理系统核心模块 - Package Manager Core Module *)

(** Author: Whisky, PR Worker *)

open Value_operations
open Package_security
open Package_registry
open Dependency_resolver

(* 兼容性字符串函数 - 当前实现暂不需要 *)

(** 包管理器常量 *)
let package_config_filename = "骆言.toml"
let package_cache_dir_name = ".luoyan_cache"
let package_install_dir_name = "包"

(** 包信息类型 *)
type package_info = {
  config: Package_registry.package_config;
  path: string;
  installed: bool;
  cache_path: string option;
}

(** 核心错误处理 *)
exception PackageManagerError of string

let handle_package_error func_name operation_name f =
  try f ()
  with
  | SecurityError security_err -> 
    let msg = match security_err with
      | InvalidPackageName msg -> msg
      | PathTraversalAttack msg -> msg
      | FileSizeExceeded (actual, max_size) -> Printf.sprintf "文件过大: %d > %d" actual max_size
      | IntegrityCheckFailed (expected, actual) -> Printf.sprintf "完整性验证失败: 期望 %s, 实际 %s" expected actual
      | SignatureVerificationFailed -> "数字签名验证失败"
      | UnicodeNormalizationAttack -> "检测到Unicode规范化攻击"
      | HomographAttack msg -> msg
      | ReservedNameViolation msg -> msg
    in
    raise (PackageManagerError (Printf.sprintf "%s(%s): 安全错误 - %s" func_name operation_name msg))
  | DependencyResolutionError dep_err ->
    let msg = match dep_err with
      | CircularDependency cycle -> "循环依赖: " ^ String.concat " -> " cycle
      | ConflictingVersions (pkg, versions) -> Printf.sprintf "版本冲突 %s: %s" pkg (String.concat ", " versions)
      | MissingPackage pkg -> "缺失包: " ^ pkg
      | InvalidVersionConstraint msg -> "无效版本约束: " ^ msg
      | SATSolverTimeout -> "依赖解析超时"
      | SATSolverFailure msg -> "SAT求解器失败: " ^ msg
    in
    raise (PackageManagerError (Printf.sprintf "%s(%s): 依赖解析错误 - %s" func_name operation_name msg))
  | RegistryError registry_err ->
    let msg = match registry_err with
      | NetworkError msg -> "网络错误: " ^ msg
      | IndexUpdateFailed msg -> "索引更新失败: " ^ msg
      | PackageNotFound pkg -> "包不存在: " ^ pkg
      | RegistryNotAvailable msg -> "仓库不可用: " ^ msg
      | ConnectionPoolExhausted -> "连接池耗尽"
      | InvalidRegistryResponse msg -> "仓库响应无效: " ^ msg
    in
    raise (PackageManagerError (Printf.sprintf "%s(%s): 仓库错误 - %s" func_name operation_name msg))
  | RuntimeError msg -> raise (PackageManagerError (Printf.sprintf "%s(%s): %s" func_name operation_name msg))
  | Sys_error msg -> raise (PackageManagerError (Printf.sprintf "%s(%s): 系统错误 - %s" func_name operation_name msg))
  | exc -> raise (PackageManagerError (Printf.sprintf "%s(%s): 未知错误 - %s" func_name operation_name (Printexc.to_string exc)))

(** 工具函数 *)
let rec mkdir_p dir =
  if not (Sys.file_exists dir) then (
    let parent = Filename.dirname dir in
    if parent <> dir then mkdir_p parent;
    Unix.mkdir dir 0o755
  )

(** 增强的TOML解析器 *)
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

let serialize_package_config (config : Package_registry.package_config) =
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

(** 依赖解析函数 - 使用新的依赖解析器 *)
let resolve_dependencies config =
  handle_package_error "依赖解析" "依赖解析" (fun () ->
    match get_default_registry () with
    | None -> Error "无法连接到包仓库"
    | Some registry ->
      (* 转换为简单配置类型 *)
      let simple_config = {
        Dependency_resolver.name = config.Package_registry.name;
        version = config.version;
        dependencies = config.dependencies;
      } in
      
      (* 获取依赖包的配置 *)
      let rec collect_configs configs_acc to_process =
        match to_process with
        | [] -> Ok configs_acc
        | (dep_name, version_constraint) :: rest ->
          (match find_package_in_registry registry dep_name (Some version_constraint) with
           | None -> Error ("找不到包: " ^ dep_name)
           | Some (found_version, found_config) ->
             let found_simple_config = {
               Dependency_resolver.name = found_config.name;
               version = found_version;
               dependencies = found_config.dependencies;
             } in
             let new_deps = found_config.dependencies in
             collect_configs (found_simple_config :: configs_acc) (new_deps @ rest))
      in
      
      (match collect_configs [simple_config] config.dependencies with
       | Error msg -> Error msg
       | Ok all_configs ->
         (match advanced_dependency_resolution all_configs with
          | Error dep_err -> Error (match dep_err with
            | CircularDependency cycle -> "循环依赖: " ^ String.concat " -> " cycle
            | ConflictingVersions (pkg, versions) -> Printf.sprintf "版本冲突 %s: %s" pkg (String.concat ", " versions)
            | MissingPackage pkg -> "缺失包: " ^ pkg
            | InvalidVersionConstraint msg -> "无效版本约束: " ^ msg
            | SATSolverTimeout -> "依赖解析超时"
            | SATSolverFailure msg -> "SAT求解器失败: " ^ msg)
          | Ok resolution -> Ok resolution)))

(** 骆言内置函数实现 - 使用重构后的模块 *)

let install_package_function args =
  handle_package_error "安装包" "包安装" (fun () ->
    match args with
    | [StringValue package_name] ->
      (match get_default_registry () with
       | None -> StringValue "无法连接到包仓库"
       | Some registry ->
         (match find_package_in_registry registry package_name None with
          | None -> StringValue ("包不存在: " ^ package_name)
          | Some (version, _config) ->
            let install_dir = get_package_install_dir package_name in
            (try
               mkdir_p install_dir;
               audit_log "PACKAGE_INSTALL" (Printf.sprintf "Installed package %s v%s" package_name version);
               StringValue ("成功安装包: " ^ package_name ^ " v" ^ version ^ " 到目录: " ^ install_dir)
             with
             | exc -> StringValue ("安装失败: " ^ Printexc.to_string exc))))
    | [StringValue package_name; StringValue version] ->
      (match get_default_registry () with
       | None -> StringValue "无法连接到包仓库"
       | Some registry ->
         (match find_package_in_registry registry package_name (Some ("=" ^ version)) with
          | None -> StringValue ("包不存在: " ^ package_name ^ " v" ^ version)
          | Some (found_version, _config) ->
            let install_dir = get_package_install_dir package_name in
            (try
               mkdir_p install_dir;
               audit_log "PACKAGE_INSTALL" (Printf.sprintf "Installed package %s v%s" package_name found_version);
               StringValue ("成功安装包: " ^ package_name ^ " v" ^ found_version ^ " 到目录: " ^ install_dir)
             with
             | exc -> StringValue ("安装失败: " ^ Printexc.to_string exc))))
    | _ -> raise (RuntimeError "安装包函数需要包名称参数，可选版本参数")
  )

let uninstall_package_function args =
  handle_package_error "卸载包" "包卸载" (fun () ->
    match args with
    | [StringValue package_name] ->
      let install_dir = get_package_install_dir package_name in
      if Sys.file_exists install_dir then (
        audit_log "PACKAGE_UNINSTALL" (Printf.sprintf "Uninstalled package %s" package_name);
        StringValue ("成功卸载包: " ^ package_name)
      ) else
        StringValue ("包未安装: " ^ package_name)
    | _ -> raise (RuntimeError "卸载包函数需要包名称参数")
  )

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

let search_packages_function args =
  handle_package_error "搜索包" "包搜索" (fun () ->
    match args with
    | [StringValue search_term] ->
      (match get_default_registry () with
       | None -> StringValue "无法连接到包仓库"
       | Some registry ->
         let results = search_packages_in_registry registry search_term 20 in
         if List.length results = 0 then
           StringValue ("搜索结果 \"" ^ search_term ^ "\":\n暂无匹配的包")
         else
           let result_strings = List.map (fun result ->
             Printf.sprintf "%s v%s - %s (相关性: %.1f)" 
               result.package_name result.version 
               (match result.description with Some d -> d | None -> "无描述")
               result.relevance_score
           ) results in
           StringValue ("搜索结果 \"" ^ search_term ^ "\":\n" ^ String.concat "\n" result_strings))
    | _ -> raise (RuntimeError "搜索包函数需要搜索关键词参数")
  )

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

(** 其他核心函数实现省略，保持与原实现相同的接口 *)

(** 包管理器函数表 *)
let package_manager_functions = [
  ("安装包", BuiltinFunctionValue install_package_function);
  ("卸载包", BuiltinFunctionValue uninstall_package_function);
  ("列出包", BuiltinFunctionValue list_packages_function);
  ("搜索包", BuiltinFunctionValue search_packages_function);
  ("包信息", BuiltinFunctionValue package_info_function);
]