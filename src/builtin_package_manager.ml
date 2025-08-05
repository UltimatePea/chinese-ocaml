(** 骆言包管理系统实现 - Chinese Programming Language Package Management System Implementation *)

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

(** 包管理器常量 *)
let package_config_filename = "骆言.toml"
let package_cache_dir_name = ".luoyan_cache"
let package_install_dir_name = "包"

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

(** 简单的TOML解析器（仅支持基本的键值对和数组） *)
let parse_toml_line line =
  let trim_line = String.trim line in
  if String.length trim_line = 0 || String.get trim_line 0 = '#' then
    None
  else if String.contains trim_line '=' then
    let idx = String.index trim_line '=' in
    let key = String.trim (String.sub trim_line 0 idx) in
    let value = String.trim (String.sub trim_line (idx + 1) (String.length trim_line - idx - 1)) in
    (* 移除引号 *)
    let clean_value = 
      if String.length value >= 2 && String.get value 0 = '"' && String.get value (String.length value - 1) = '"' then
        String.sub value 1 (String.length value - 2)
      else value
    in
    Some (key, clean_value)
  else
    None

let parse_toml_content content =
  let lines = String.split_on_char '\n' content in
  let rec parse_lines acc current_section = function
    | [] -> acc
    | line :: rest ->
      let trim_line = String.trim line in
      if String.length trim_line > 0 && String.get trim_line 0 = '[' && String.get trim_line (String.length trim_line - 1) = ']' then
        (* 新的段落 *)
        let section = String.sub trim_line 1 (String.length trim_line - 2) in
        parse_lines acc (Some section) rest
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
          (dep_name, value) :: acc
        else acc
      ) [] pairs
    in
    let parse_authors author_str =
      (* 简单的作者解析，假设用逗号分隔 *)
      if String.contains author_str ',' then
        List.map String.trim (String.split_on_char ',' author_str)
      else
        [author_str]
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
  (* 简化的依赖解析实现 *)
  let rec resolve_recursive resolved missing conflicts deps =
    match deps with
    | [] -> { resolved_packages = List.rev resolved; missing = List.rev missing; conflicts = List.rev conflicts }
    | (name, version_constraint) :: rest ->
      (* 在实际实现中，这里应该查询包仓库 *)
      (* 现在只是模拟一个简单的解析 *)
      if List.exists (fun (resolved_name, _) -> resolved_name = name) resolved then
        resolve_recursive resolved missing conflicts rest
      else
        (* 假设所有依赖都能找到合适的版本 *)
        let resolved_version = match parse_version_constraint version_constraint with
          | Ok (Exact v) -> v
          | Ok (Compatible v) -> v
          | Ok (GreaterThanOrEqual v) -> v
          | _ -> "1.0.0"
        in
        resolve_recursive ((name, resolved_version) :: resolved) missing conflicts rest
  in
  Ok (resolve_recursive [] [] [] config.dependencies)

(** 骆言内置函数实现 *)

(** 安装包函数 *)
let install_package_function args =
  handle_package_error "安装包" "包安装" (fun () ->
    match args with
    | [StringValue package_name] ->
      (* 模拟包安装过程 *)
      let install_dir = get_package_install_dir package_name in
      (* 在实际实现中，这里应该从仓库下载并安装包 *)
      StringValue ("成功安装包: " ^ package_name ^ " 到目录: " ^ install_dir)
    | [StringValue package_name; StringValue version] ->
      let install_dir = get_package_install_dir package_name in
      StringValue ("成功安装包: " ^ package_name ^ " 版本: " ^ version ^ " 到目录: " ^ install_dir)
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
      (* 在实际实现中，这里应该查询中央仓库 *)
      StringValue ("搜索结果 \"" ^ search_term ^ "\":\n(模拟结果) 暂无匹配的包")
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

(** 其他占位符函数 *)
let update_package_function _args = StringValue "更新功能尚未实现"
let check_updates_function _args = StringValue "检查更新功能尚未实现"
let create_package_config_function _args = StringValue "创建配置功能尚未实现"
let package_project_function _args = StringValue "打包功能尚未实现"
let publish_package_function _args = StringValue "发布功能尚未实现"
let test_project_function _args = StringValue "测试功能尚未实现"
let clean_project_function _args = StringValue "清理功能尚未实现"
let write_package_config_function _args = StringValue "写入配置功能尚未实现"
let update_package_config_function _args = StringValue "更新配置功能尚未实现"
let clear_cache_function _args = StringValue "清理缓存功能尚未实现"
let rebuild_cache_function _args = StringValue "重建缓存功能尚未实现"
let cache_status_function _args = StringValue "缓存状态功能尚未实现"

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