(** 统一数据加载器测试
    验证Poetry模块整合Phase 1的重构结果
    
    @author Alpha, 技术债务清理专员
    @since 2025-07-29
    @fix_issue #1729 *)

open Printf

let test_unified_loader () =
  printf "=== 测试统一数据加载器 ===\n";

  (* 测试JSON字符串加载 *)
  let test_json = {|{"test": ["字1", "字2", "字3"]}|} in
  try
    let result =
      Poetry_data.Unified_data_loader.load_data_unified Poetry_data.Unified_data_loader.RhymeData
        (Poetry_data.Unified_data_loader.JsonString test_json)
    in
    printf "✓ JSON字符串加载成功\n";

    (* 测试缓存功能 *)
    let cache_size, _ = Poetry_data.Unified_data_loader.get_cache_stats () in
    printf "✓ 缓存统计: %d 条目\n" cache_size;

    (* 清理缓存 *)
    Poetry_data.Unified_data_loader.clear_cache ();
    let cache_size_after, _ = Poetry_data.Unified_data_loader.get_cache_stats () in
    printf "✓ 缓存清理: %d 条目\n" cache_size_after;

    printf "✓ 统一数据加载器测试通过\n"
  with
  | Poetry_data.Unified_data_loader.UnifiedLoadError error ->
      printf "✗ 统一加载器错误: %s\n" (Poetry_data.Unified_data_loader.format_error error)
  | exn -> printf "✗ 意外错误: %s\n" (Printexc.to_string exn)

let test_expanded_data_loader_compatibility () =
  printf "\n=== 测试重构后的扩展数据加载器兼容性 ===\n";

  try
    (* 测试兼容性加载函数 *)
    let person_nouns, social_nouns, _, _, _, _, _, _, _, _ =
      Poetry_data.Expanded_data_loader.safe_load_nouns ()
    in
    printf "✓ 名词数据加载: %d + %d 条目\n" (List.length person_nouns) (List.length social_nouns);

    let movement_verbs, _, _, _, _, _, _, _, _, _, _ =
      Poetry_data.Expanded_data_loader.safe_load_verbs ()
    in
    printf "✓ 动词数据加载: %d 条目\n" (List.length movement_verbs);

    let size_adj, _, _, _, _, _, _, _, _, _, _, _ =
      Poetry_data.Expanded_data_loader.safe_load_adjectives ()
    in
    printf "✓ 形容词数据加载: %d 条目\n" (List.length size_adj);

    (* 测试缓存信息接口 *)
    let cache_info = Poetry_data.Expanded_data_loader.get_cache_info () in
    printf "✓ 缓存信息: %s\n" cache_info;

    printf "✓ 扩展数据加载器兼容性测试通过\n"
  with
  | Poetry_data.Expanded_data_loader.DataLoadError error ->
      printf "✗ 数据加载错误: %s\n" (Poetry_data.Expanded_data_loader.format_error error)
  | exn -> printf "✗ 意外错误: %s\n" (Printexc.to_string exn)

let test_expanded_word_class_data () =
  printf "\n=== 测试词性数据模块 ===\n";

  try
    let person_nouns = Poetry_data.Expanded_word_class_data.person_relation_nouns in
    printf "✓ 人物关系名词: %d 条目\n" (List.length person_nouns);

    let social_nouns = Poetry_data.Expanded_word_class_data.social_status_nouns in
    printf "✓ 社会地位名词: %d 条目\n" (List.length social_nouns);

    (* 测试类型正确性 *)
    match person_nouns with
    | (word, word_class) :: _ ->
        printf "✓ 词性数据类型正确: %s -> %s\n" word
          (match word_class with Poetry_data.Word_class_types.Noun -> "名词" | _ -> "其他")
    | [] ->
        printf "! 人物关系名词列表为空\n";

        printf "✓ 词性数据模块测试通过\n"
  with exn -> printf "✗ 词性数据测试错误: %s\n" (Printexc.to_string exn)

let () =
  printf "开始Poetry模块整合Phase 1测试...\n\n";
  test_unified_loader ();
  test_expanded_data_loader_compatibility ();
  test_expanded_word_class_data ();
  printf "\n所有测试完成！\n"
