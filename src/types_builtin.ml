(** 骆言类型系统内置函数环境 - Built-in Function Type Environment *)

open Core_types

(** 内置函数类型环境 *)
let builtin_env =
  let env = TypeEnv.empty in

  (* 基础IO函数 *)
  let env = TypeEnv.add "打印" (TypeScheme ([], FunType_T (StringType_T, UnitType_T))) env in
  let env = TypeEnv.add "读取" (TypeScheme ([], FunType_T (UnitType_T, StringType_T))) env in

  (* 列表函数 *)
  let env =
    TypeEnv.add "长度" (TypeScheme ([ "'a" ], FunType_T (ListType_T (TypeVar_T "'a"), IntType_T))) env
  in
  let env =
    TypeEnv.add "连接"
      (TypeScheme
         ( [ "'a" ],
           FunType_T
             ( ListType_T (TypeVar_T "'a"),
               FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a")) ) ))
      env
  in
  let env =
    TypeEnv.add "过滤"
      (TypeScheme
         ( [ "'a" ],
           FunType_T
             ( FunType_T (TypeVar_T "'a", BoolType_T),
               FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a")) ) ))
      env
  in
  let env =
    TypeEnv.add "映射"
      (TypeScheme
         ( [ "'a"; "'b" ],
           FunType_T
             ( FunType_T (TypeVar_T "'a", TypeVar_T "'b"),
               FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'b")) ) ))
      env
  in
  let env =
    TypeEnv.add "折叠"
      (TypeScheme
         ( [ "'a"; "'b" ],
           FunType_T
             ( FunType_T (TypeVar_T "'a", FunType_T (TypeVar_T "'b", TypeVar_T "'b")),
               FunType_T (TypeVar_T "'b", FunType_T (ListType_T (TypeVar_T "'a"), TypeVar_T "'b"))
             ) ))
      env
  in
  let env =
    TypeEnv.add "范围"
      (TypeScheme ([], FunType_T (IntType_T, FunType_T (IntType_T, ListType_T IntType_T))))
      env
  in
  let env =
    TypeEnv.add "排序" (TypeScheme ([], FunType_T (ListType_T IntType_T, ListType_T IntType_T))) env
  in
  let env =
    TypeEnv.add "反转"
      (TypeScheme ([ "'a" ], FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a"))))
      env
  in
  let env =
    TypeEnv.add "包含"
      (TypeScheme ([], FunType_T (IntType_T, FunType_T (ListType_T IntType_T, BoolType_T))))
      env
  in

  (* 数学函数 *)
  let env = TypeEnv.add "求和" (TypeScheme ([], FunType_T (ListType_T IntType_T, IntType_T))) env in
  let env = TypeEnv.add "最大值" (TypeScheme ([], FunType_T (ListType_T IntType_T, IntType_T))) env in
  let env = TypeEnv.add "最小值" (TypeScheme ([], FunType_T (ListType_T IntType_T, IntType_T))) env in
  let env =
    TypeEnv.add "平均值" (TypeScheme ([], FunType_T (ListType_T IntType_T, FloatType_T))) env
  in
  let env = TypeEnv.add "乘积" (TypeScheme ([], FunType_T (ListType_T IntType_T, IntType_T))) env in
  let env = TypeEnv.add "绝对值" (TypeScheme ([], FunType_T (IntType_T, IntType_T))) env in
  let env = TypeEnv.add "平方" (TypeScheme ([], FunType_T (IntType_T, IntType_T))) env in
  let env =
    TypeEnv.add "幂运算"
      (TypeScheme ([], FunType_T (FloatType_T, FunType_T (FloatType_T, FloatType_T))))
      env
  in
  let env = TypeEnv.add "余弦" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "正弦" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "平方根" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "取整" (TypeScheme ([], FunType_T (FloatType_T, IntType_T))) env in
  let env = TypeEnv.add "随机数" (TypeScheme ([], FunType_T (UnitType_T, IntType_T))) env in

  (* 扩展数学函数 *)
  let env = TypeEnv.add "对数" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "自然对数" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "十进制对数" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "指数" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "正切" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "反正弦" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "反余弦" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "反正切" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "向上取整" (TypeScheme ([], FunType_T (FloatType_T, IntType_T))) env in
  let env = TypeEnv.add "向下取整" (TypeScheme ([], FunType_T (FloatType_T, IntType_T))) env in
  let env = TypeEnv.add "四舍五入" (TypeScheme ([], FunType_T (FloatType_T, IntType_T))) env in
  let env =
    TypeEnv.add "最大公约数"
      (TypeScheme ([], FunType_T (IntType_T, FunType_T (IntType_T, IntType_T))))
      env
  in
  let env =
    TypeEnv.add "最小公倍数"
      (TypeScheme ([], FunType_T (IntType_T, FunType_T (IntType_T, IntType_T))))
      env
  in

  (* 数组函数 *)
  let env =
    TypeEnv.add "创建数组"
      (TypeScheme
         ([ "'a" ], FunType_T (IntType_T, FunType_T (TypeVar_T "'a", ArrayType_T (TypeVar_T "'a")))))
      env
  in
  let env =
    TypeEnv.add "数组长度"
      (TypeScheme ([ "'a" ], FunType_T (ArrayType_T (TypeVar_T "'a"), IntType_T)))
      env
  in
  let env =
    TypeEnv.add "复制数组"
      (TypeScheme ([ "'a" ], FunType_T (ArrayType_T (TypeVar_T "'a"), ArrayType_T (TypeVar_T "'a"))))
      env
  in

  (* 引用函数 *)
  let env =
    TypeEnv.add "引用"
      (TypeScheme ([ "'a" ], FunType_T (TypeVar_T "'a", RefType_T (TypeVar_T "'a"))))
      env
  in

  (* 字符串函数 *)
  let env = TypeEnv.add "字符串长度" (TypeScheme ([], FunType_T (StringType_T, IntType_T))) env in
  let env =
    TypeEnv.add "字符串连接"
      (TypeScheme ([], FunType_T (StringType_T, FunType_T (StringType_T, StringType_T))))
      env
  in
  let env =
    TypeEnv.add "字符串分割"
      (TypeScheme ([], FunType_T (StringType_T, FunType_T (StringType_T, ListType_T StringType_T))))
      env
  in

  (* 文件操作函数 *)
  let env = TypeEnv.add "读取文件" (TypeScheme ([], FunType_T (StringType_T, StringType_T))) env in
  let env =
    TypeEnv.add "写入文件"
      (TypeScheme ([], FunType_T (StringType_T, FunType_T (StringType_T, UnitType_T))))
      env
  in
  let env = TypeEnv.add "文件存在" (TypeScheme ([], FunType_T (StringType_T, BoolType_T))) env in
  let env = TypeEnv.add "大写转换" (TypeScheme ([], FunType_T (StringType_T, StringType_T))) env in
  let env = TypeEnv.add "小写转换" (TypeScheme ([], FunType_T (StringType_T, StringType_T))) env in
  let env = TypeEnv.add "去除空白" (TypeScheme ([], FunType_T (StringType_T, StringType_T))) env in
  let env =
    TypeEnv.add "字符串替换"
      (TypeScheme
         ( [],
           FunType_T (StringType_T, FunType_T (StringType_T, FunType_T (StringType_T, StringType_T)))
         ))
      env
  in
  let env =
    TypeEnv.add "子字符串"
      (TypeScheme
         ([], FunType_T (StringType_T, FunType_T (IntType_T, FunType_T (IntType_T, StringType_T)))))
      env
  in
  let env =
    TypeEnv.add "字符串比较"
      (TypeScheme ([], FunType_T (StringType_T, FunType_T (StringType_T, IntType_T))))
      env
  in

  (* 类型转换函数 *)
  let env = TypeEnv.add "整数到字符串" (TypeScheme ([], FunType_T (IntType_T, StringType_T))) env in
  let env = TypeEnv.add "浮点数到字符串" (TypeScheme ([], FunType_T (FloatType_T, StringType_T))) env in
  let env = TypeEnv.add "字符串到整数" (TypeScheme ([], FunType_T (StringType_T, IntType_T))) env in
  let env = TypeEnv.add "字符串到浮点数" (TypeScheme ([], FunType_T (StringType_T, FloatType_T))) env in

  env

(** 内置函数重载环境 *)
let builtin_overload_env = OverloadMap.empty

(** 获取内置函数列表 *)
let get_builtin_functions () = TypeEnv.bindings builtin_env |> List.map fst

(** 检查是否是内置函数 *)
let is_builtin_function name = TypeEnv.mem name builtin_env

(** 获取内置函数类型 *)
let get_builtin_type name = try Some (TypeEnv.find name builtin_env) with Not_found -> None

(** 添加自定义内置函数 *)
let add_builtin_function name type_scheme env = TypeEnv.add name type_scheme env

(** 获取类别的内置函数 *)
let get_math_functions () =
  [
    "求和";
    "最大值";
    "最小值";
    "平均值";
    "乘积";
    "绝对值";
    "平方";
    "幂运算";
    "余弦";
    "正弦";
    "平方根";
    "取整";
    "随机数";
    "对数";
    "自然对数";
    "十进制对数";
    "指数";
    "正切";
    "反正弦";
    "反余弦";
    "反正切";
    "向上取整";
    "向下取整";
    "四舍五入";
    "最大公约数";
    "最小公倍数";
  ]

let get_list_functions () = [ "长度"; "连接"; "过滤"; "映射"; "折叠"; "范围"; "排序"; "反转"; "包含" ]

let get_string_functions () =
  [ "字符串长度"; "字符串连接"; "字符串分割"; "大写转换"; "小写转换"; "去除空白"; "字符串替换"; "子字符串"; "字符串比较" ]

let get_io_functions () = [ "打印"; "读取"; "读取文件"; "写入文件"; "文件存在" ]

let get_conversion_functions () = [ "整数到字符串"; "浮点数到字符串"; "字符串到整数"; "字符串到浮点数" ]

let get_array_functions () = [ "创建数组"; "数组长度"; "复制数组" ]
let get_reference_functions () = [ "引用" ]
