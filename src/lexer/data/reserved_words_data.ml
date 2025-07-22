(** 骆言保留词数据模块 - 按分类组织 *)

(** 保留词分类模块 *)
module ReservedWordCategories = struct
  (** 基本数据类型相关 *)
  let basic_data_types = [ "浮点"; "字符" ]

  (** 函数式编程概念 *)
  let functional_programming = [ "高阶"; "柯里"; "部分应用"; "函数组合"; "不动点" ]

  (** 类型系统相关 *)
  let type_system = [ "约束"; "推断"; "多态"; "单态"; "协变"; "逆变"; "不变" ]

  (** 模块系统相关 *)
  let module_system = [ "模块路径"; "限定符"; "命名空间" ]

  (** 并发和异步相关 *)
  let concurrency = [ "并发"; "异步"; "同步"; "原子"; "锁"; "互斥" ]

  (** 内存管理相关 *)
  let memory_management = [ "堆"; "栈"; "垃圾回收"; "引用计数" ]

  (** 编译器内部相关 *)
  let compiler_internals = [ "词法"; "语法"; "语义"; "代码生成"; "优化"; "调试信息" ]

  (** 元编程相关 *)
  let metaprogramming = [ "反射"; "内省"; "代码模板"; "代码生成器" ]

  (** 错误处理扩展 *)
  let error_handling = [ "断言"; "前置条件"; "后置条件"; "不变量" ]

  (** 数据结构相关 *)
  let data_structures = [ "队列"; "栈"; "堆"; "树"; "图"; "哈希表" ]

  (** IO和系统相关 *)
  let io_and_system = [ "标准输入"; "标准输出"; "标准错误"; "文件系统"; "网络" ]

  (** 数学计算相关 *)
  let mathematical_computing = [ "精确计算"; "浮点误差"; "无穷"; "非数值" ]

  (** 字符串处理相关 *)
  let string_processing = [ "正则表达式"; "模式匹配"; "字符编码"; "Unicode" ]

  (** 测试相关 *)
  let testing = [ "单元测试"; "集成测试"; "性能测试"; "基准测试" ]

  (** 日志和调试相关 *)
  let logging_and_debugging = [ "日志级别"; "调试模式"; "性能分析"; "内存分析" ]
end

(** 保留词生成器模块 *)
module ReservedWordGenerator = struct
  (** 合并所有分类的保留词 *)
  let generate_all_reserved_words () =
    let open ReservedWordCategories in
    List.concat
      [
        basic_data_types;
        functional_programming;
        type_system;
        module_system;
        concurrency;
        memory_management;
        compiler_internals;
        metaprogramming;
        error_handling;
        data_structures;
        io_and_system;
        mathematical_computing;
        string_processing;
        testing;
        logging_and_debugging;
      ]
end

(** 保留词表（优先于关键字处理，避免复合词被错误分割）*)
let reserved_words_list = ReservedWordGenerator.generate_all_reserved_words ()
