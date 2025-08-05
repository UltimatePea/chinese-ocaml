(** 骆言包管理器命令行工具 - Chinese Programming Language Package Manager CLI Tool *)

(** Author: Whisky, PR Worker *)

open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_package_manager_refactored

(** 命令行选项类型 *)
type cli_command = 
  | Init of string option                    (* 初始化项目 *)
  | Install of string * string option       (* 安装包 (包名, 版本) *)
  | Uninstall of string                      (* 卸载包 *)
  | Update of string option                  (* 更新包 (可选包名) *)
  | List                                     (* 列出已安装包 *)
  | Search of string                         (* 搜索包 *)
  | Info of string                           (* 包信息 *)
  | Build                                    (* 构建项目 *)
  | Test                                     (* 测试项目 *)
  | Clean                                    (* 清理项目 *)
  | Publish                                  (* 发布包 *)
  | Validate                                 (* 验证包 *)
  | Cache of cache_command                   (* 缓存管理 *)
  | Help                                     (* 帮助 *)
  | Version                                  (* 版本 *)

and cache_command =
  | Clear                                    (* 清理缓存 *)
  | Rebuild                                  (* 重建缓存 *)
  | Status                                   (* 缓存状态 *)

(** 版本信息 *)
let version = "1.0.0"
let program_name = "luoyan-pkg"

(** 帮助信息 *)
let help_text = {|
骆言包管理器 (luoyan-pkg) v|} ^ version ^ {|

用法:
  luoyan-pkg <命令> [选项]

命令:
  init [项目名]          初始化新的骆言项目
  install <包名> [版本]  安装指定的包
  uninstall <包名>       卸载指定的包  
  update [包名]          更新包（不指定包名则更新所有）
  list                   列出已安装的包
  search <关键词>        搜索可用的包
  info <包名>            显示包的详细信息
  build                  构建当前项目
  test                   运行项目测试
  clean                  清理构建产物
  publish                发布包到中央仓库
  validate               验证当前包配置
  cache <子命令>         缓存管理
    clear                清理包缓存
    rebuild              重建包缓存
    status               显示缓存状态
  help                   显示此帮助信息
  version                显示版本信息

示例:
  luoyan-pkg init 我的项目
  luoyan-pkg install 数学工具包 ^1.0.0
  luoyan-pkg search 诗词
  luoyan-pkg build
  luoyan-pkg cache clear

作者: 骆言开发团队
主页: https://github.com/UltimatePea/chinese-ocaml
|}

(** 解析命令行参数 *)
let _parse_args args =
  let rec parse acc = function
    | [] -> List.rev acc
    | arg :: rest -> parse (arg :: acc) rest
  in
  parse [] args

(** 解析命令 *)
let parse_command = function
  | [] -> Help
  | "init" :: [] -> Init None
  | "init" :: project_name :: _ -> Init (Some project_name)
  | "install" :: package_name :: [] -> Install (package_name, None)
  | "install" :: package_name :: version :: _ -> Install (package_name, Some version)
  | "uninstall" :: package_name :: _ -> Uninstall package_name
  | "update" :: [] -> Update None
  | "update" :: package_name :: _ -> Update (Some package_name)
  | "list" :: _ -> List
  | "search" :: search_term :: _ -> Search search_term
  | "info" :: package_name :: _ -> Info package_name
  | "build" :: _ -> Build
  | "test" :: _ -> Test
  | "clean" :: _ -> Clean
  | "publish" :: _ -> Publish
  | "validate" :: _ -> Validate
  | "cache" :: "clear" :: _ -> Cache Clear
  | "cache" :: "rebuild" :: _ -> Cache Rebuild
  | "cache" :: "status" :: _ -> Cache Status
  | "cache" :: _ -> Cache Status
  | "help" :: _ -> Help
  | "version" :: _ -> Version
  | "--help" :: _ -> Help
  | "--version" :: _ -> Version
  | "-h" :: _ -> Help
  | "-v" :: _ -> Version
  | unknown :: _ -> 
    Printf.eprintf "未知命令: %s\n使用 'luoyan-pkg help' 查看帮助\n" unknown;
    exit 1

(** 颜色输出支持 *)
let colored_output color text =
  if Unix.isatty Unix.stdout then
    let color_code = match color with
      | `Red -> "\027[31m"
      | `Green -> "\027[32m"
      | `Yellow -> "\027[33m"
      | `Blue -> "\027[34m"
      | `Magenta -> "\027[35m"
      | `Cyan -> "\027[36m"
    in
    Printf.sprintf "%s%s\027[0m" color_code text
  else
    text

let print_success msg = print_endline (colored_output `Green ("✓ " ^ msg))
let print_warning msg = print_endline (colored_output `Yellow ("⚠ " ^ msg))
let print_error msg = Printf.eprintf "%s\n" (colored_output `Red ("✗ " ^ msg))
let print_info msg = print_endline (colored_output `Blue ("ℹ " ^ msg))

(** 执行命令 *)
let execute_command = function
  | Init project_name ->
    let name = match project_name with
      | Some n -> n
      | None -> "新项目"
    in
    (match init_project_function [StringValue name] with
     | StringValue result -> print_endline result
     | _ -> print_endline "初始化失败")

  | Install (package_name, version) ->
    let args = match version with
      | Some v -> [StringValue package_name; StringValue v]
      | None -> [StringValue package_name]
    in
    (match install_package_function args with
     | StringValue result -> print_endline result
     | _ -> print_endline "安装失败")

  | Uninstall package_name ->
    (match uninstall_package_function [StringValue package_name] with
     | StringValue result -> print_endline result
     | _ -> print_endline "卸载失败")

  | Update package_name ->
    (* 更新功能需要从美化的模块中获取 *)
    let result = match package_name with
      | Some name -> "更新包: " ^ name ^ " (功能即将推出)"
      | None -> "更新所有包 (功能即将推出)"
    in
    print_endline result

  | List ->
    (match list_packages_function [] with
     | StringValue result -> print_endline result
     | _ -> print_endline "列表查询失败")

  | Search search_term ->
    (match search_packages_function [StringValue search_term] with
     | StringValue result -> print_endline result
     | _ -> print_endline "搜索失败")

  | Info package_name ->
    (match package_info_function [StringValue package_name] with
     | StringValue result -> print_endline result
     | _ -> print_endline "包信息查询失败")

  | Build ->
    print_endline "构建项目 (功能实现中)"

  | Test ->
    print_endline "测试项目 (功能实现中)"

  | Clean ->
    print_endline "清理项目 (功能实现中)"

  | Publish ->
    print_endline "发布包 (功能实现中)"

  | Validate ->
    print_endline "验证包 (功能实现中)"

  | Cache cache_cmd ->
    (match cache_cmd with
      | Clear -> 
        Yyocamlc_lib.Package_registry.clear_metadata_cache ();
        print_success "缓存已清理"
      | Rebuild -> 
        Yyocamlc_lib.Package_registry.clear_metadata_cache ();
        print_success "缓存已重建"
      | Status -> 
        print_info "缓存系统正常运行")

  | Help ->
    print_endline help_text

  | Version ->
    Printf.printf "%s v%s\n" program_name version

(** 初始化包管理器 *)
let init_package_manager () =
  try
    initialize_package_manager ();
    true
  with
  | _ -> false

(** 主函数 *)
let main () =
  let args = Array.to_list Sys.argv |> List.tl in
  let command = parse_command args in
  
  (* 初始化包管理器 *)
  if not (init_package_manager ()) then (
    print_warning "包管理器初始化警告，部分功能可能不可用";
  );
  
  try
    execute_command command
  with
  | RuntimeError msg ->
    print_error msg;
    exit 1
  | Sys_error msg ->
    print_error ("系统错误: " ^ msg);
    exit 1
  | exc ->
    print_error ("未知错误: " ^ Printexc.to_string exc);
    exit 1

(** 程序入口 *)
let () = 
  if !Sys.interactive then
    ()  (* 在交互模式下不执行main *)
  else
    main ()