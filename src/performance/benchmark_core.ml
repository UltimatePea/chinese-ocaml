(** 性能基准测试核心框架
    
    提供统一的基准测试接口和数据结构定义
    
    创建目的：建立标准化的性能测试框架，支持模块化扩展
    创建时间：技术债务改进 Phase 5.1 - Fix #1083 *)

(* Import handled via library dependencies *)

(** 性能测试指标数据结构 *)
type performance_metric = {
  name : string;  (** 测试名称 *)
  execution_time : float;  (** 执行时间（秒） *)
  memory_usage : int option;  (** 内存使用（字节），可选 *)
  cpu_usage : float option;  (** CPU使用率（百分比），可选 *)
  iterations : int;  (** 测试迭代次数 *)
  variance : float option;  (** 执行时间方差，可选 *)
}

(** 基准测试结果 *)
type benchmark_result = {
  module_name : string;  (** 被测模块名称 *)
  test_category : string;  (** 测试类别（词法/语法/语义等） *)
  metrics : performance_metric list;  (** 性能指标列表 *)
  baseline : performance_metric option;  (** 基线性能，用于对比 *)
  timestamp : string;  (** 测试时间戳 *)
  environment : string;  (** 测试环境信息 *)
}

(** 基准测试套件 *)
type benchmark_suite = {
  suite_name : string;  (** 测试套件名称 *)
  results : benchmark_result list;  (** 测试结果列表 *)
  summary : string;  (** 测试总结 *)
  total_duration : float;  (** 总测试时间 *)
}

(** 测试配置 *)
type test_config = {
  name : string;  (** 测试名称 *)
  iterations : int;  (** 迭代次数 *)
  data_size : int;  (** 数据规模 *)
  description : string;  (** 测试描述 *)
}

(** 核心基准测试接口 *)
module BenchmarkCore = struct
  
  (** 创建性能指标记录 *)
  let create_metric name execution_time ?memory_usage ?cpu_usage ?variance iterations =
    {
      name;
      execution_time;
      memory_usage;
      cpu_usage;
      iterations;
      variance;
    }
  
  (** 创建基准测试结果 *)
  let create_result module_name test_category metrics ?baseline timestamp environment =
    {
      module_name;
      test_category;
      metrics;
      baseline;
      timestamp;
      environment;
    }
  
  (** 创建基准测试套件 *)
  let create_suite suite_name results summary total_duration =
    {
      suite_name;
      results;
      summary;
      total_duration;
    }
  
  (** 获取当前时间戳 *)
  let get_timestamp () =
    let time = Unix.time () in
    let tm = Unix.localtime time in
    Utils.Base_formatter.concat_strings [
      "性能测试_";
      Utils.Base_formatter.int_to_string (tm.tm_year + 1900);
      "-";
      Utils.Base_formatter.int_to_string (tm.tm_mon + 1);
      "-";
      Utils.Base_formatter.int_to_string tm.tm_mday;
      "_";
      Utils.Base_formatter.int_to_string tm.tm_hour;
      ":";
      Utils.Base_formatter.int_to_string tm.tm_min;
      ":";
      Utils.Base_formatter.int_to_string tm.tm_sec;
    ]
  
  (** 获取系统环境信息 *)
  let get_environment_info () =
    let hostname = try Sys.getenv "HOSTNAME" with Not_found -> "未知主机" in
    let ocaml_version = Sys.ocaml_version in
    Utils.Base_formatter.concat_strings ["主机: 主机名="; hostname; ", OCaml版本="; ocaml_version]
  
  (** 运行单个基准测试 *)
  let run_single_test _test_function _data _config =
    (* 这个函数将被具体的测试模块实现 *)
    failwith "run_single_test需要在具体的测试模块中实现"
    
  (** 批量运行基准测试 *)
  let run_batch_tests test_function test_configs data_generator =
    let results = ref [] in
    List.iter (fun config ->
      try
        let data = data_generator config.data_size in
        let result = run_single_test test_function data config in
        results := result :: !results
      with
      | _exn ->
        let error_metric = create_metric 
          (Utils.Base_formatter.concat_strings ["错误-"; config.name])
          0.0 0 in
        results := error_metric :: !results
    ) test_configs;
    List.rev !results
    
end

(** 统计计算工具 *)
module Statistics = struct
  
  (** 计算平均值 *)
  let calculate_mean values =
    let sum = List.fold_left (+.) 0.0 values in
    let count = List.length values in
    if count > 0 then sum /. (float_of_int count) else 0.0
  
  (** 计算方差 *)
  let calculate_variance values =
    let mean = calculate_mean values in
    let squared_diffs = List.map (fun x -> (x -. mean) ** 2.0) values in
    calculate_mean squared_diffs
  
  (** 计算标准差 *)
  let calculate_std_dev values =
    sqrt (calculate_variance values)
  
  (** 计算置信区间 *)
  let calculate_confidence_interval values confidence_level =
    let mean = calculate_mean values in
    let std_dev = calculate_std_dev values in
    let count = float_of_int (List.length values) in
    let margin = std_dev *. confidence_level /. (sqrt count) in
    (mean -. margin, mean +. margin)
    
end

(** 实用工具函数 *)
module Utils = struct
  
  (** 生成测试数据 *)
  let generate_test_data size content_generator =
    let buffer = Buffer.create size in
    for _i = 1 to size do
      Buffer.add_string buffer (content_generator ())
    done;
    Buffer.contents buffer
  
  (** 创建简单的字符串内容生成器 *)
  let simple_content_generator () =
    "让 x = 1 加 2\n"
  
  (** 创建中文诗词内容生成器 *)
  let poetry_content_generator () =
    "春眠不觉晓，处处闻啼鸟。\n"
  
  (** 格式化执行时间 *)
  let format_execution_time time =
    if time < 0.001 then
      Utils.Base_formatter.concat_strings [Utils.Base_formatter.float_to_string (time *. 1_000_000.0); "μs"]
    else if time < 1.0 then
      Utils.Base_formatter.concat_strings [Utils.Base_formatter.float_to_string (time *. 1000.0); "ms"]
    else
      Utils.Base_formatter.concat_strings [Utils.Base_formatter.float_to_string time; "s"]
  
  (** 格式化内存使用 *)
  let format_memory_usage bytes =
    let kb = float_of_int bytes /. 1024.0 in
    let mb = kb /. 1024.0 in
    if mb >= 1.0 then
      Utils.Base_formatter.concat_strings [Utils.Base_formatter.float_to_string mb; "MB"]
    else if kb >= 1.0 then
      Utils.Base_formatter.concat_strings [Utils.Base_formatter.float_to_string kb; "KB"]
    else
      Utils.Base_formatter.concat_strings [Utils.Base_formatter.int_to_string bytes; "B"]
      
end