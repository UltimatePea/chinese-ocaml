(** 基准测试协调器模块
    
    提供统一的测试执行框架，消除代码重复，协调各个功能模块的基准测试执行 *)


type performance_metric = {
  name : string;
  execution_time : float;
  memory_usage : int option;
  cpu_usage : float option;
  iterations : int;
  variance : float option;
}

type benchmark_result = {
  module_name : string;
  test_category : string;
  metrics : performance_metric list;
  baseline : performance_metric option;
  timestamp : string;
  environment : string;
}

type benchmark_suite = {
  suite_name : string;
  results : benchmark_result list;
  summary : string;
  total_duration : float;
}

module TestExecutor = struct
  (** 统一的测试执行框架，消除各模块间的代码重复 *)
  
  let execute_benchmark_tests test_configs test_function data_generator =
    List.map
      (fun config ->
        let { Benchmark_core.name; iterations; data_size; description = _ } = config in
        let test_data = 
          Benchmark_core.Utils.generate_test_data data_size data_generator
        in
        let start_time = Sys.time () in
        let _result = test_function test_data in
        let end_time = Sys.time () in
        let execution_time = end_time -. start_time in
        {
          name;
          execution_time;
          memory_usage = None;
          cpu_usage = None;
          iterations;
          variance = None;
        })
      test_configs

  let execute_benchmark_tests_with_memory test_configs test_function data_generator =
    List.map
      (fun config ->
        let { Benchmark_core.name; iterations; data_size; description = _ } = config in
        let test_data = 
          Benchmark_core.Utils.generate_test_data data_size data_generator
        in
        
        let initial_memory = 
          try
            let gc_stat = Gc.stat () in
            Some (gc_stat.Gc.live_words * (Sys.word_size / 8))
          with _ -> None
        in
        
        let start_time = Sys.time () in
        let _result = test_function test_data in
        let end_time = Sys.time () in
        
        let final_memory = 
          try
            let gc_stat = Gc.stat () in
            Some (gc_stat.Gc.live_words * (Sys.word_size / 8))
          with _ -> None
        in
        
        let memory_usage = 
          match (initial_memory, final_memory) with
          | Some initial, Some final -> Some (final - initial)
          | _ -> None
        in
        
        let execution_time = end_time -. start_time in
        {
          name;
          execution_time;
          memory_usage;
          cpu_usage = None;
          iterations;
          variance = None;
        })
      test_configs
end

module SuiteCoordinator = struct
  (** 测试套件协调器，管理各个功能模块的测试执行 *)
  
  let create_benchmark_result module_name test_category metrics timestamp environment =
    { module_name; test_category; metrics; baseline = None; timestamp; environment }

  let get_current_timestamp = Benchmark_core.BenchmarkCore.get_timestamp

  let get_system_environment = Benchmark_core.BenchmarkCore.get_environment_info

  let run_coordinated_benchmarks test_modules =
    let start_time = Sys.time () in
    let timestamp = get_current_timestamp () in
    let environment = get_system_environment () in
    
    let results = List.map (fun (module_name, test_category, test_runner) ->
      let metrics = test_runner () in
      create_benchmark_result module_name test_category metrics timestamp environment
    ) test_modules in
    
    let end_time = Sys.time () in
    let total_duration = end_time -. start_time in
    
    {
      suite_name = "骆言编译器性能基准测试套件";
      results;
      summary = "完成编译器核心模块的性能基准测试，包括词法分析、语法分析和诗词编程特色功能";
      total_duration;
    }
end