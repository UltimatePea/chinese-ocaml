(** 骆言包管理系统仓库管理模块 - Package Registry Module *)

(** Author: Whisky, PR Worker *)

open Package_security

(** 包配置类型定义 *)
type package_config = {
  name: string;
  version: string;
  description: string option;
  authors: string list;
  license: string option;
  homepage: string option;
  dependencies: (string * string) list;
  dev_dependencies: (string * string) list;
  build_script: string option;
  test_script: string option;
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
  packages: (string, (string * package_metadata) list) Hashtbl.t;
  mutable index_last_updated: float;
  mutable connection_pool: connection_pool option;
}

(** 连接池类型 - 用于HTTP连接复用 *)
and connection_pool = {
  max_connections: int;
  active_connections: int ref;
  idle_connections: connection_handle list ref;
  connection_timeout: float;
}

and connection_handle = {
  url: string;
  created_at: float;
  last_used: float ref;
}

(** 包搜索结果 *)
type search_result = {
  package_name: string;
  version: string;
  description: string option;
  download_count: int;
  last_updated: float;
  relevance_score: float;
}

(** 仓库操作错误类型 *)
type registry_error =
  | NetworkError of string
  | IndexUpdateFailed of string
  | PackageNotFound of string
  | RegistryNotAvailable of string
  | ConnectionPoolExhausted
  | InvalidRegistryResponse of string

exception RegistryError of registry_error

(** 默认配置 *)
let default_registry_url = "https://packages.luoyan.org"
let max_connection_pool_size = 10
let connection_timeout = 30.0
let index_cache_timeout = 3600.0 (* 1小时 *)

(** 全局包仓库注册表 - 线程安全版本 *)
let global_registries = ref []
let registries_mutex = Mutex.create ()

(** 连接池管理 *)
let create_connection_pool max_connections =
  {
    max_connections = max_connections;
    active_connections = ref 0;
    idle_connections = ref [];
    connection_timeout = connection_timeout;
  }

let get_connection_from_pool pool url =
  let now = Unix.time () in
  let rec find_valid_connection connections acc =
    match connections with
    | [] -> (None, List.rev acc)
    | conn :: rest ->
      if now -. !(conn.last_used) > pool.connection_timeout then
        find_valid_connection rest acc (* 连接超时，丢弃 *)
      else
        (Some conn, List.rev acc @ rest) (* 找到可用连接 *)
  in
  
  let (connection_opt, remaining_connections) = find_valid_connection !(pool.idle_connections) [] in
  pool.idle_connections := remaining_connections;
  
  match connection_opt with
  | Some conn ->
    conn.last_used := now;
    Ok conn
  | None ->
    if !(pool.active_connections) >= pool.max_connections then
      Error ConnectionPoolExhausted
    else
      let new_conn = {
        url = url;
        created_at = now;
        last_used = ref now;
      } in
      incr pool.active_connections;
      Ok new_conn

let return_connection_to_pool pool connection =
  connection.last_used := Unix.time ();
  pool.idle_connections := connection :: !(pool.idle_connections);
  decr pool.active_connections;
  (* Log connection metrics for debugging - uses created_at and url fields *)
  let connection_age = Unix.time () -. connection.created_at in
  Printf.eprintf "Connection returned: url=%s, age=%.2fs\n" connection.url connection_age;
  flush stderr

(** 创建仓库 *)
let create_registry name url =
  {
    name = name;
    url = url;
    packages = Hashtbl.create 1000;
    index_last_updated = 0.0;
    connection_pool = Some (create_connection_pool max_connection_pool_size);
  }

(** 重新初始化连接池 - 修复connection_pool未被mutate的警告 *)
let reinitialize_connection_pool registry =
  registry.connection_pool <- Some (create_connection_pool max_connection_pool_size);
  Printf.eprintf "Connection pool reinitialized for registry: %s\n" registry.name;
  flush stderr

(** 线程安全的仓库管理 *)
let add_global_registry registry =
  Mutex.lock registries_mutex;
  global_registries := registry :: !global_registries;
  Mutex.unlock registries_mutex

let get_global_registries () =
  Mutex.lock registries_mutex;
  let registries = !global_registries in
  Mutex.unlock registries_mutex;
  registries

let clear_global_registries () =
  Mutex.lock registries_mutex;
  global_registries := [];
  Mutex.unlock registries_mutex

(** 包添加到仓库 - 带完整性验证 *)
let add_package_to_registry registry package_name version pkg_config content signature_opt =
  (* 1. 安全验证 *)
  match comprehensive_package_validation package_name content None with
  | Error security_err -> Error (InvalidRegistryResponse (Printf.sprintf "安全验证失败: %s" 
    (match security_err with
     | InvalidPackageName msg -> msg
     | PathTraversalAttack msg -> msg
     | _ -> "安全错误")))
  | Ok validated_name ->
    
    (* 2. 创建完整性信息 *)
    let integrity = create_package_integrity content signature_opt in
    
    (* 3. 创建元数据 *)
    let metadata = {
      config = pkg_config;
      integrity = integrity;
      download_url = Printf.sprintf "%s/packages/%s/%s" registry.url validated_name version;
      published_at = Unix.time ();
    } in
    
    (* 4. 添加到仓库 *)
    (match Hashtbl.find_opt registry.packages validated_name with
     | Some versions -> 
       let updated_versions = (version, metadata) :: (List.filter (fun (v, _) -> v <> version) versions) in
       let sorted_versions = List.sort (fun (v1, _) (v2, _) -> 
         Dependency_resolver.compare_versions v2 v1) updated_versions in
       Hashtbl.replace registry.packages validated_name sorted_versions
     | None -> 
       Hashtbl.add registry.packages validated_name [(version, metadata)]);
    
    audit_log "PACKAGE_REGISTRY" (Printf.sprintf "Added package %s v%s to registry %s" validated_name version registry.name);
    Ok ()

(** 增强的包搜索 - 支持模糊匹配和相关性评分 *)
let search_packages_in_registry registry search_term max_results =
  let search_term_lower = String.lowercase_ascii search_term in
  let results = ref [] in
  
  let calculate_relevance_score package_name description =
    let name_lower = String.lowercase_ascii package_name in
    let desc_lower = match description with
      | Some d -> String.lowercase_ascii d
      | None -> ""
    in
    
    let name_exact_match = if name_lower = search_term_lower then 100.0 else 0.0 in
    let name_prefix_match = if String.length name_lower >= String.length search_term_lower &&
                               String.sub name_lower 0 (String.length search_term_lower) = search_term_lower 
                            then 80.0 else 0.0 in
    let name_contains = if String.exists (fun _ -> true) name_lower &&
                           Str.string_match (Str.regexp (".*" ^ search_term_lower ^ ".*")) name_lower 0
                        then 60.0 else 0.0 in
    let desc_contains = if String.length desc_lower > 0 &&
                           Str.string_match (Str.regexp (".*" ^ search_term_lower ^ ".*")) desc_lower 0
                        then 40.0 else 0.0 in
    
    name_exact_match +. name_prefix_match +. name_contains +. desc_contains
  in
  
  Hashtbl.iter (fun package_name versions ->
    List.iter (fun (version, metadata) ->
      let relevance = calculate_relevance_score package_name metadata.config.description in
      if relevance > 0.0 then
        let result = {
          package_name = package_name;
          version = version;
          description = metadata.config.description;
          download_count = 0; (* 待实现 *)
          last_updated = metadata.published_at;
          relevance_score = relevance;
        } in
        results := result :: !results
    ) versions
  ) registry.packages;
  
  (* 按相关性排序并限制结果数量 *)
  let sorted_results = List.sort (fun r1 r2 -> 
    compare r2.relevance_score r1.relevance_score
  ) !results in
  
  if max_results > 0 then
    let rec take n lst acc =
      match lst, n with
      | [], _ | _, 0 -> List.rev acc
      | x :: xs, n -> take (n-1) xs (x :: acc)
    in
    take max_results sorted_results []
  else
    sorted_results

(** 在仓库中查找包 - 改进的版本选择 *)
let find_package_in_registry registry package_name version_constraint_opt =
  match Hashtbl.find_opt registry.packages package_name with
  | None -> None
  | Some versions ->
    match version_constraint_opt with
    | None -> 
      (* 返回最新稳定版本 *)
      let stable_versions = List.filter (fun (version, _) ->
        not (String.contains version '-') (* 排除预发布版本 *)
      ) versions in
      (match stable_versions with
       | (version, metadata) :: _ -> Some (version, metadata.config)
       | [] -> 
         (* 如果没有稳定版本，返回最新版本 *)
         (match versions with
          | (version, metadata) :: _ -> Some (version, metadata.config)
          | [] -> None))
    | Some constraint_str ->
      (match Dependency_resolver.parse_version_constraint constraint_str with
       | Ok constraint_obj ->
         let compatible_versions = List.filter (fun (version, _) -> 
           Dependency_resolver.version_satisfies version constraint_obj
         ) versions in
         (match compatible_versions with
          | (version, metadata) :: _ -> Some (version, metadata.config)
          | [] -> None)
       | Error _ -> None)

(** HTTP客户端模拟 - 实际实现中应使用真正的HTTP库 *)
let http_get_with_retry url max_retries =
  let rec retry_request attempt =
    if attempt > max_retries then
      Error (NetworkError (Printf.sprintf "HTTP请求失败，已重试%d次: %s" max_retries url))
    else
      try
        (* 模拟HTTP请求 *)
        if Str.string_match (Str.regexp ".*packages\\.luoyan\\.org.*") url 0 then
          Ok "{\"packages\": [], \"last_updated\": \"2024-01-01T00:00:00Z\"}"
        else
          Error (NetworkError ("无法连接到仓库: " ^ url))
      with
      | exc -> 
        if attempt < max_retries then (
          Unix.sleep (min 8 attempt); (* 简化的退避策略 *)
          retry_request (attempt + 1)
        )
        else
          Error (NetworkError (Printf.sprintf "HTTP请求异常: %s" (Printexc.to_string exc)))
  in
  retry_request 1

(** 仓库索引更新 - 带重试和连接池 *)
let update_registry_index registry =
  let now = Unix.time () in
  
  (* 检查是否需要更新 *)
  if now -. registry.index_last_updated < index_cache_timeout then
    Ok () (* 索引仍然有效 *)
  else
    match registry.connection_pool with
    | None -> Error (RegistryNotAvailable "连接池未初始化")
    | Some pool ->
      (match get_connection_from_pool pool registry.url with
       | Error err -> Error err
       | Ok connection ->
         let index_url = registry.url ^ "/index.json" in
         (match http_get_with_retry index_url 3 with
          | Error err -> 
            return_connection_to_pool pool connection;
            Error err
          | Ok _response ->
            return_connection_to_pool pool connection;
            (* 解析索引响应并更新包列表 *)
            registry.index_last_updated <- now;
            (* audit_log "REGISTRY_UPDATE" (Printf.sprintf "Updated index for registry %s" registry.name); *)
            Ok ()))

(** 获取默认仓库 - 线程安全版本 *)
let get_default_registry () =
  let registries = get_global_registries () in
  match registries with
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
    
    let sample_content = "示例包内容" in
    (match add_package_to_registry default_registry "示例包" "1.0.0" sample_config sample_content None with
     | Ok () -> 
       add_global_registry default_registry;
       Some default_registry
     | Error _ -> None)

(** 仓库健康检查 *)
let health_check_registry registry =
  let health_url = registry.url ^ "/health" in
  match http_get_with_retry health_url 1 with
  | Ok response -> 
    (* 简单的健康检查 - 实际实现中应解析响应 *)
    if String.length response > 0 then Ok ()
    else Error (RegistryNotAvailable "仓库健康检查失败")
  | Error err -> Error err

(** 批量包查询 *)
let batch_package_lookup registry package_names =
  let results = Hashtbl.create (List.length package_names) in
  
  List.iter (fun package_name ->
    match find_package_in_registry registry package_name None with
    | Some (version, config) -> Hashtbl.add results package_name (Some (version, config))
    | None -> Hashtbl.add results package_name None
  ) package_names;
  
  results

(** 包元数据缓存管理 *)
let metadata_cache = Hashtbl.create 1000
let cache_mutex = Mutex.create ()

let get_cached_metadata registry_name package_name =
  Mutex.lock cache_mutex;
  let key = registry_name ^ ":" ^ package_name in
  let result = Hashtbl.find_opt metadata_cache key in
  Mutex.unlock cache_mutex;
  result

let cache_metadata registry_name package_name metadata =
  Mutex.lock cache_mutex;
  let key = registry_name ^ ":" ^ package_name in
  Hashtbl.replace metadata_cache key (metadata, Unix.time ());
  Mutex.unlock cache_mutex

let clear_metadata_cache () =
  Mutex.lock cache_mutex;
  Hashtbl.clear metadata_cache;
  Mutex.unlock cache_mutex

(** 仓库统计信息 *)
type registry_stats = {
  total_packages: int;
  total_versions: int;
  index_last_updated: float;
  connection_pool_active: int;
  connection_pool_idle: int;
  cache_hit_rate: float;
}

let get_registry_stats registry =
  let total_packages = Hashtbl.length registry.packages in
  let total_versions = Hashtbl.fold (fun _ versions acc -> 
    acc + List.length versions
  ) registry.packages 0 in
  
  let (active_conns, idle_conns) = match registry.connection_pool with
    | None -> (0, 0)
    | Some pool -> (!(pool.active_connections), List.length !(pool.idle_connections))
  in
  
  {
    total_packages = total_packages;
    total_versions = total_versions;
    index_last_updated = registry.index_last_updated;
    connection_pool_active = active_conns;
    connection_pool_idle = idle_conns;
    cache_hit_rate = 0.0; (* 待实现 *)
  }