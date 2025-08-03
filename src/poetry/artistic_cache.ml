(** 诗词艺术评估缓存管理模块 - Issue #2000 整合实施
 *
 * 此文件整合了缓存相关功能，提供统一的缓存管理。
 *
 * 整合完成后，分散的缓存逻辑将被统一管理。
 * @consolidation_issue #2000
 * @author Whisky, PR Worker
 *)

(** {1 缓存类型定义} *)

type cache_key = string
type cache_value = string
type cache_entry = {
  value : cache_value;
  created_at : float;
  access_count : int;
  last_access : float;
}

type cache_policy = 
  | LRU of int     (** 最近最少使用，参数为最大容量 *)
  | TTL of float   (** 生存时间，参数为秒数 *)
  | NoEviction     (** 不删除 *)

(** {1 缓存存储} *)

let cache_storage = Hashtbl.create 1000
let cache_metadata = Hashtbl.create 1000
let cache_policy_ref = ref (LRU 500)

(** {1 辅助函数} *)

(** 本地take函数实现 *)
let rec take n lst =
  if n <= 0 then []
  else match lst with
    | [] -> []
    | h :: t -> h :: take (n - 1) t

(** {1 缓存操作} *)

(** 获取缓存值 *)
let get_cached key =
  try
    let entry = Hashtbl.find cache_metadata key in
    let value = Hashtbl.find cache_storage key in
    
    (* 更新访问统计 *)
    let updated_entry = {
      entry with
      access_count = entry.access_count + 1;
      last_access = Unix.time ();
    } in
    Hashtbl.replace cache_metadata key updated_entry;
    
    Some value
  with Not_found -> None

(** 设置缓存值 *)
let rec set_cached key value =
  let current_time = Unix.time () in
  let entry = {
    value;
    created_at = current_time;
    access_count = 1;
    last_access = current_time;
  } in
  
  Hashtbl.replace cache_storage key value;
  Hashtbl.replace cache_metadata key entry;
  
  (* 应用缓存策略 *)
  apply_cache_policy ()

and apply_cache_policy () =
  match !cache_policy_ref with
  | LRU max_size ->
    if Hashtbl.length cache_storage > max_size then
      evict_lru ((Hashtbl.length cache_storage) - max_size)
  | TTL ttl_seconds ->
    evict_expired ttl_seconds
  | NoEviction -> ()

and evict_lru count =
  let entries = Hashtbl.fold (fun key entry acc -> (key, entry) :: acc) cache_metadata [] in
  let sorted_entries = List.sort (fun (_, e1) (_, e2) -> 
    compare e1.last_access e2.last_access
  ) entries in
  
  let to_evict = take count sorted_entries in
  List.iter (fun (key, _) ->
    Hashtbl.remove cache_storage key;
    Hashtbl.remove cache_metadata key
  ) to_evict

and evict_expired ttl_seconds =
  let current_time = Unix.time () in
  let expired_keys = Hashtbl.fold (fun key entry acc ->
    if current_time -. entry.created_at > ttl_seconds then key :: acc else acc
  ) cache_metadata [] in
  
  List.iter (fun key ->
    Hashtbl.remove cache_storage key;
    Hashtbl.remove cache_metadata key
  ) expired_keys

(** 删除缓存项 *)
let remove_cached key =
  Hashtbl.remove cache_storage key;
  Hashtbl.remove cache_metadata key

(** 清空缓存 *)
let clear_cache () =
  Hashtbl.clear cache_storage;
  Hashtbl.clear cache_metadata

(** {1 缓存策略管理} *)

(** 设置缓存策略 *)
let set_cache_policy policy =
  cache_policy_ref := policy;
  apply_cache_policy ()

(** 获取当前缓存策略 *)
let get_cache_policy () = !cache_policy_ref

(** {1 缓存统计} *)

(** 获取缓存统计信息 *)
let get_cache_stats () =
  let total_entries = Hashtbl.length cache_storage in
  let total_access = Hashtbl.fold (fun _ entry acc -> acc + entry.access_count) cache_metadata 0 in
  let current_time = Unix.time () in
  
  let ages = Hashtbl.fold (fun _ entry acc -> 
    (current_time -. entry.created_at) :: acc
  ) cache_metadata [] in
  
  let avg_age = if ages = [] then 0.0 
               else List.fold_left (+.) 0.0 ages /. float_of_int (List.length ages) in
  
  [
    ("总条目数", string_of_int total_entries);
    ("总访问次数", string_of_int total_access);
    ("平均年龄(秒)", Printf.sprintf "%.2f" avg_age);
    ("命中率", "N/A");  (* 需要单独跟踪 *)
  ]

(** 获取热点数据 *)
let get_hot_entries limit =
  let entries = Hashtbl.fold (fun key entry acc -> (key, entry.access_count) :: acc) cache_metadata [] in
  let sorted = List.sort (fun (_, c1) (_, c2) -> compare c2 c1) entries in
  take limit sorted

(** {1 专门的艺术评估缓存} *)

(** 评估结果缓存 *)
let cache_evaluation_result poem_text result =
  let key = "eval_" ^ (Digest.string poem_text |> Digest.to_hex) in
  set_cached key result

(** 获取评估结果缓存 *)
let get_cached_evaluation poem_text =
  let key = "eval_" ^ (Digest.string poem_text |> Digest.to_hex) in
  get_cached key

(** 缓存韵律分析结果 *)
let cache_rhyme_analysis poem_text rhyme_data =
  let key = "rhyme_" ^ (Digest.string poem_text |> Digest.to_hex) in
  set_cached key rhyme_data

(** 获取韵律分析缓存 *)
let get_cached_rhyme_analysis poem_text =
  let key = "rhyme_" ^ (Digest.string poem_text |> Digest.to_hex) in
  get_cached key

(** 缓存意境分析结果 *)
let cache_mood_analysis poem_text mood_data =
  let key = "mood_" ^ (Digest.string poem_text |> Digest.to_hex) in
  set_cached key mood_data

(** 获取意境分析缓存 *)
let get_cached_mood_analysis poem_text =
  let key = "mood_" ^ (Digest.string poem_text |> Digest.to_hex) in
  get_cached key

(** {1 缓存预热} *)

(** 预热常用数据 *)
let warm_up_cache () =
  (* 预加载常用的评估标准和模板 *)
  set_cached "default_weights" "韵律:0.2,声调:0.2,对仗:0.15,意象:0.15,形式:0.1,内容:0.1,意境:0.1";
  set_cached "evaluation_levels" "优秀:0.9,良好:0.8,中等:0.7,及格:0.6";
  set_cached "common_patterns" "绝句:4行,律诗:8行,古体:变长";
  
  (* 预加载常用韵律数据 *)
  set_cached "ping_ze_basic" "平:1,仄:0";
  set_cached "rhyme_categories" "平声:东冬江阳,仄声:上去入"

(** {1 缓存维护} *)

(** 缓存清理任务 *)
let cleanup_cache () =
  match !cache_policy_ref with
  | TTL ttl -> evict_expired ttl
  | LRU max_size -> 
    if Hashtbl.length cache_storage > max_size then
      evict_lru ((Hashtbl.length cache_storage) - max_size + 10)
  | NoEviction -> ()

(** 缓存大小优化 *)
let optimize_cache_size () =
  let current_size = Hashtbl.length cache_storage in
  let _stats = get_cache_stats () in
  let avg_access = Hashtbl.fold (fun _ entry acc -> 
    acc +. float_of_int entry.access_count
  ) cache_metadata 0.0 /. float_of_int current_size in
  
  (* 根据访问模式调整策略 *)
  if avg_access < 2.0 then
    set_cache_policy (LRU (current_size / 2))
  else if avg_access > 10.0 then
    set_cache_policy (LRU (current_size + 100))

(** {1 缓存导出和导入} *)

(** 导出缓存数据 *)
let export_cache () =
  let entries = Hashtbl.fold (fun key value acc -> (key, value) :: acc) cache_storage [] in
  List.map (fun (key, value) -> key ^ ":" ^ value) entries
  |> String.concat "\n"

(** 导入缓存数据 *)
let import_cache data =
  clear_cache ();
  let lines = String.split_on_char '\n' data in
  List.iter (fun line ->
    match String.split_on_char ':' line with
    | key :: value_parts -> 
      let value = String.concat ":" value_parts in
      set_cached key value
    | [] -> ()
  ) lines

(** {1 初始化} *)

(* 自动初始化缓存 *)
let () = 
  set_cache_policy (LRU 500);
  warm_up_cache ()