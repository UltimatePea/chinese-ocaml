(** 骆言包管理系统工具模块 - Package Management Utilities *)

(** Author: Whisky, PR Worker *)

open Package_registry

(** 包信息类型 *)
type package_info = {
  config: Package_registry.package_config;
  path: string;
  installed: bool;
  cache_path: string option;
}

(** 格式化包信息字符串 *)
let format_package_info info =
  let config = info.config in
  Printf.sprintf 
    "包名: %s\n版本: %s\n描述: %s\n作者: %s\n许可证: %s\n主页: %s"
    config.name
    config.version
    (match config.description with Some d -> d | None -> "无")
    (String.concat ", " config.authors)
    (match config.license with Some l -> l | None -> "未指定")
    (match config.homepage with Some h -> h | None -> "未指定")

(** 格式化包列表 *)
let format_package_list packages =
  let package_strings = List.map (fun info ->
    Printf.sprintf "%s (%s)" info.config.name info.config.version
  ) packages in
  "已安装的包:\n" ^ String.concat "\n" package_strings

(** 格式化搜索结果 *)
let format_search_results search_term results =
  if List.length results = 0 then
    Printf.sprintf "搜索结果 \"%s\":\n暂无匹配的包" search_term
  else
    let result_strings = List.map (fun result ->
      Printf.sprintf "%s v%s - %s (相关性: %.1f)" 
        result.package_name result.version 
        (match result.description with Some d -> d | None -> "无描述")
        result.relevance_score
    ) results in
    Printf.sprintf "搜索结果 \"%s\":\n%s" search_term (String.concat "\n" result_strings)

(** 包文件路径工具 *)
let package_config_filename = "骆言.toml"
let package_cache_dir_name = ".luoyan_cache"
let package_install_dir_name = "包"

(** 获取包安装路径 *)
let get_package_install_path package_name =
  Filename.concat (Sys.getcwd ()) (Filename.concat package_install_dir_name package_name)

(** 获取包缓存路径 *)
let get_package_cache_path package_name =
  let home_dir = try Sys.getenv "HOME" with Not_found -> "/" in
  Filename.concat home_dir (Filename.concat package_cache_dir_name package_name)

(** 检查包是否已安装 *)
let is_package_installed package_name =
  let install_path = get_package_install_path package_name in
  let config_path = Filename.concat install_path package_config_filename in
  Sys.file_exists config_path

(** 创建包信息 *)
let create_package_info config path =
  let installed = is_package_installed config.name in
  let cache_path = if installed then Some (get_package_cache_path config.name) else None in
  {
    config = config;
    path = path;
    installed = installed;
    cache_path = cache_path;
  }