(** 骆言内置数学函数模块 - Chinese Programming Language Builtin Math Functions *)

open Builtin_common
open Numeric_ops

(** 范围生成函数 *)
let range_function args =
  let start_val, end_val = check_double_args args "范围" in
  let start = expect_int start_val "范围" in
  let end_num = expect_int end_val "范围" in
  let rec range s e acc =
    if s > e then ListValue (List.rev acc) else range (s + 1) e (IntValue s :: acc)
  in
  range start end_num []

(** 求和函数 - 使用统一数值操作 *)
let sum_function args =
  let lst = expect_list (check_single_arg args "求和") "求和" in
  let aggregator = create_numeric_aggregator add_op (IntValue 0) "求和函数" in
  aggregator lst

(** 最大值函数 - 使用统一数值操作 *)
let max_function args =
  let lst = expect_nonempty_list (check_single_arg args "最大值") "最大值" in
  let aggregator = create_nonempty_numeric_aggregator max_op "最大值函数" in
  aggregator lst

(** 最小值函数 - 使用统一数值操作 *)
let min_function args =
  let lst = expect_nonempty_list (check_single_arg args "最小值") "最小值" in
  let aggregator = create_nonempty_numeric_aggregator min_op "最小值函数" in
  aggregator lst

(** 三角函数实现 - Issue #2189 数学模块核心功能完善 *)

(** 正弦函数 - 使用泰勒级数近似 *)
let sin_function args =
  let angle = expect_float (check_single_arg args "正弦") "正弦" in
  (* 检查NaN和无穷大 *)
  if classify_float angle = FP_nan then FloatValue nan
  else if classify_float angle = FP_infinite then FloatValue nan
  else
    (* 将角度规范化到 -π 到 π *)
    let pi = 3.141592653589793 in
    let norm_angle = mod_float angle (2.0 *. pi) in
    let final_angle =
      if norm_angle > pi then norm_angle -. (2.0 *. pi)
      else if norm_angle < -.pi then norm_angle +. (2.0 *. pi)
      else norm_angle
    in
    (* 泰勒级数计算 sin(x) = x - x³/3! + x⁵/5! - x⁷/7! + ... *)
    let factorial n =
      let rec iter current result =
        if current <= 1 then result else iter (current - 1) (result *. float_of_int current)
      in
      iter n 1.0
    in
    let rec taylor_sin x n acc =
      if n > 25 then acc
      else
        let power = (2 * n) + 1 in
        let sign = if n mod 2 = 0 then 1.0 else -1.0 in
        let term = sign *. (x ** float_of_int power) /. factorial power in
        taylor_sin x (n + 1) (acc +. term)
    in
    FloatValue (taylor_sin final_angle 0 0.0)

(** 余弦函数 - 使用泰勒级数近似 *)
let cos_function args =
  let angle = expect_float (check_single_arg args "余弦") "余弦" in
  (* 检查NaN和无穷大 *)
  if classify_float angle = FP_nan then FloatValue nan
  else if classify_float angle = FP_infinite then FloatValue nan
  else
    let pi = 3.141592653589793 in
    let norm_angle = mod_float angle (2.0 *. pi) in
    let final_angle =
      if norm_angle > pi then norm_angle -. (2.0 *. pi)
      else if norm_angle < -.pi then norm_angle +. (2.0 *. pi)
      else norm_angle
    in
    (* 泰勒级数计算 cos(x) = 1 - x²/2! + x⁴/4! - x⁶/6! + ... *)
    let factorial n =
      let rec iter current result =
        if current <= 1 then result else iter (current - 1) (result *. float_of_int current)
      in
      iter n 1.0
    in
    let rec taylor_cos x n acc =
      if n > 25 then acc
      else
        let power = 2 * n in
        let sign = if n mod 2 = 0 then 1.0 else -1.0 in
        let term =
          if power = 0 then 1.0 else sign *. (x ** float_of_int power) /. factorial power
        in
        taylor_cos x (n + 1) (acc +. term)
    in
    FloatValue (taylor_cos final_angle 0 0.0)

(** 正切函数 - tan(x) = sin(x) / cos(x) *)
let tan_function args =
  let angle = expect_float (check_single_arg args "正切") "正切" in
  (* 检查NaN和无穷大 *)
  if classify_float angle = FP_nan then FloatValue nan
  else if classify_float angle = FP_infinite then FloatValue nan
  else
    let sin_val = match sin_function [ FloatValue angle ] with FloatValue f -> f | _ -> 0.0 in
    let cos_val = match cos_function [ FloatValue angle ] with FloatValue f -> f | _ -> 1.0 in
    if abs_float cos_val < 1e-10 then
      (* 处理正切无穷大的情况 *)
      FloatValue (if sin_val > 0.0 then 1e6 else -1e6)
    else FloatValue (sin_val /. cos_val)

(** 反正弦函数 - asin(x) 定义域 [-1, 1] 值域 [-π/2, π/2] *)
let asin_function args =
  let x = expect_float (check_single_arg args "反正弦") "反正弦" in
  if x < -1.0 || x > 1.0 then raise (RuntimeError "反正弦函数输入值必须在 [-1, 1] 范围内")
  else if abs_float x = 1.0 then
    FloatValue (if x > 0.0 then 1.5707963267948966 else -1.5707963267948966) (* ±π/2 *)
  else
    (* 使用泰勒级数: asin(x) = x + x³/6 + 3x⁵/40 + 5x⁷/112 + ... *)
    let rec asin_series x n acc =
      if n > 20 then acc
      else
        let power = (2 * n) + 1 in
        let numerator = ref 1.0 in
        let denominator = ref 1.0 in
        (* 计算 (2n-1)!! *)
        for i = 1 to n do
          numerator := !numerator *. float_of_int ((2 * i) - 1);
          denominator := !denominator *. float_of_int (2 * i)
        done;
        let coeff = !numerator /. (!denominator *. float_of_int power) in
        let term = coeff *. (x ** float_of_int power) in
        asin_series x (n + 1) (acc +. term)
    in
    FloatValue (asin_series x 0 0.0)

(** 反余弦函数 - acos(x) = π/2 - asin(x) 定义域 [-1, 1] 值域 [0, π] *)
let acos_function args =
  let x = expect_float (check_single_arg args "反余弦") "反余弦" in
  if x < -1.0 || x > 1.0 then raise (RuntimeError "反余弦函数输入值必须在 [-1, 1] 范围内")
  else
    let asin_val = match asin_function [ FloatValue x ] with FloatValue f -> f | _ -> 0.0 in
    FloatValue (1.5707963267948966 -. asin_val)
(* π/2 - asin(x) *)

(** 反正切函数 - atan(x) 定义域 (-∞, ∞) 值域 (-π/2, π/2) *)
let rec atan_function args =
  let x = expect_float (check_single_arg args "反正切") "反正切" in
  if abs_float x > 1.0 then
    (* 对于大值使用恒等式: atan(x) = π/2 - atan(1/x) for |x| > 1 *)
    let sign = if x > 0.0 then 1.0 else -1.0 in
    let reciprocal_atan =
      match atan_function [ FloatValue (1.0 /. x) ] with FloatValue f -> f | _ -> 0.0
    in
    FloatValue ((sign *. 1.5707963267948966) -. reciprocal_atan)
  else
    (* 使用泰勒级数: atan(x) = x - x³/3 + x⁵/5 - x⁷/7 + ... for |x| ≤ 1 *)
    let rec atan_series x n acc =
      if n > 30 then acc
      else
        let power = (2 * n) + 1 in
        let sign = if n mod 2 = 0 then 1.0 else -1.0 in
        let term = sign *. (x ** float_of_int power) /. float_of_int power in
        atan_series x (n + 1) (acc +. term)
    in
    FloatValue (atan_series x 0 0.0)

(** 统计函数实现 - Issue #2189 *)

(** 平均值函数 *)
let mean_function args =
  let lst = expect_list (check_single_arg args "平均值") "平均值" in
  let sum =
    List.fold_left
      (fun acc v ->
        match (acc, v) with
        | FloatValue a, FloatValue b -> FloatValue (a +. b)
        | FloatValue a, IntValue b -> FloatValue (a +. float_of_int b)
        | IntValue a, FloatValue b -> FloatValue (float_of_int a +. b)
        | IntValue a, IntValue b -> IntValue (a + b)
        | _ -> raise (RuntimeError "平均值函数只能处理数值列表"))
      (IntValue 0) lst
  in
  let count = List.length lst in
  if count = 0 then FloatValue 0.0
  else
    match sum with
    | FloatValue s -> FloatValue (s /. float_of_int count)
    | IntValue s -> FloatValue (float_of_int s /. float_of_int count)
    | _ -> FloatValue 0.0

(** 方差函数 *)
let variance_function args =
  let lst = expect_list (check_single_arg args "方差") "方差" in
  let mean_val =
    match mean_function [ ListValue lst ] with
    | FloatValue m -> m
    | IntValue m -> float_of_int m
    | _ -> 0.0
  in
  let count = List.length lst in
  if count <= 1 then FloatValue 0.0
  else
    let sum_sq_diff =
      List.fold_left
        (fun acc v ->
          let val_f =
            match v with
            | FloatValue f -> f
            | IntValue i -> float_of_int i
            | _ -> raise (RuntimeError "方差函数只能处理数值列表")
          in
          let diff = val_f -. mean_val in
          acc +. (diff *. diff))
        0.0 lst
    in
    FloatValue (sum_sq_diff /. float_of_int (count - 1))

(** 标准差函数 *)
let standard_deviation_function args =
  let var_val = match variance_function args with FloatValue v -> v | _ -> 0.0 in
  FloatValue (sqrt var_val)

(** 中位数函数 *)
let median_function args =
  let lst = expect_list (check_single_arg args "中位数") "中位数" in
  if List.length lst = 0 then FloatValue 0.0
  else
    let float_list =
      List.map
        (fun v ->
          match v with
          | FloatValue f -> f
          | IntValue i -> float_of_int i
          | _ -> raise (RuntimeError "中位数函数只能处理数值列表"))
        lst
    in
    let sorted = List.sort compare float_list in
    let len = List.length sorted in
    if len mod 2 = 1 then FloatValue (List.nth sorted (len / 2))
    else
      let mid1 = List.nth sorted ((len / 2) - 1) in
      let mid2 = List.nth sorted (len / 2) in
      FloatValue ((mid1 +. mid2) /. 2.0)

(** 数论函数实现 - Issue #2189 *)

(** 素数优化判断 - 6k±1 优化算法 *)
let optimized_prime_function args =
  let n = expect_int (check_single_arg args "素数优化判断") "素数优化判断" in
  if n <= 1 then BoolValue false
  else if n <= 3 then BoolValue true
  else if n mod 2 = 0 || n mod 3 = 0 then BoolValue false
  else
    let rec check_factors i =
      if i * i > n then true
      else if n mod i = 0 || n mod (i + 2) = 0 then false
      else check_factors (i + 6)
    in
    BoolValue (check_factors 5)

(** 质因数分解函数 *)
let prime_factorization_function args =
  let n = expect_int (check_single_arg args "质因数分解") "质因数分解" in
  if n <= 1 then ListValue []
  else
    let rec factorize num factor acc =
      if num = 1 then List.rev acc
      else if factor * factor > num then List.rev (IntValue num :: acc)
      else if num mod factor = 0 then factorize (num / factor) factor (IntValue factor :: acc)
      else
        let next_factor = if factor = 2 then 3 else factor + 2 in
        factorize num next_factor acc
    in
    ListValue (factorize n 2 [])

(** 欧拉函数 φ(n) - 计算小于等于n且与n互质的正整数个数 *)
let euler_phi_function args =
  let n = expect_int (check_single_arg args "欧拉函数") "欧拉函数" in
  if n <= 0 then IntValue 0
  else if n = 1 then IntValue 1
  else
    (* 使用公式: φ(n) = n * ∏(1 - 1/p) 对所有质因子p *)
    let get_unique_prime_factors num =
      let rec check_factor num f acc =
        if f * f > num then if num > 1 then num :: acc else acc
        else if num mod f = 0 then
          let rec divide_out n d = if n mod d = 0 then divide_out (n / d) d else n in
          check_factor (divide_out num f) (if f = 2 then 3 else f + 2) (f :: acc)
        else check_factor num (if f = 2 then 3 else f + 2) acc
      in
      check_factor num 2 []
    in
    let prime_factors = get_unique_prime_factors n in
    (* 计算 φ(n) = n * ∏((p-1)/p) *)
    let result = List.fold_left (fun acc p -> acc * (p - 1) / p) n prime_factors in
    IntValue result

(** 数学常量 - Issue #2189 *)

let pi_constant args =
  let _ = check_no_args args "圆周率" in
  FloatValue 3.141592653589793

let e_constant args =
  let _ = check_no_args args "自然对数底" in
  FloatValue 2.718281828459045

let euler_constant args =
  let _ = check_no_args args "欧拉常数" in
  FloatValue 0.5772156649015329

let golden_ratio_constant args =
  let _ = check_no_args args "黄金比例" in
  FloatValue 1.618033988749895

(** 增强的数学函数表 - Issue #2189 数学模块核心功能完善任务 Author: Whisky, PR Worker

    本次更新新增4个函数，总计21个函数，满足Issue #2189要求的20+函数：
    - 反正弦函数 (asin) - 反正弦函数
    - 反余弦函数 (acos) - 反余弦函数
    - 反正切函数 (atan) - 反正切函数
    - 欧拉函数 (φ) - 欧拉φ函数，数论核心函数 *)
let math_functions =
  [
    (* 基础函数 *)
    ("范围", BuiltinFunctionValue range_function);
    ("求和", BuiltinFunctionValue sum_function);
    ("最大值", BuiltinFunctionValue max_function);
    ("最小值", BuiltinFunctionValue min_function);
    (* 三角函数 *)
    ("正弦", BuiltinFunctionValue sin_function);
    ("余弦", BuiltinFunctionValue cos_function);
    ("正切", BuiltinFunctionValue tan_function);
    (* 反三角函数 - Issue #2189 增强功能 *)
    ("反正弦", BuiltinFunctionValue asin_function);
    ("反余弦", BuiltinFunctionValue acos_function);
    ("反正切", BuiltinFunctionValue atan_function);
    (* 统计函数 *)
    ("平均值", BuiltinFunctionValue mean_function);
    ("方差", BuiltinFunctionValue variance_function);
    ("标准差", BuiltinFunctionValue standard_deviation_function);
    ("中位数", BuiltinFunctionValue median_function);
    (* 数论函数 *)
    ("素数优化判断", BuiltinFunctionValue optimized_prime_function);
    ("质因数分解", BuiltinFunctionValue prime_factorization_function);
    ("欧拉函数", BuiltinFunctionValue euler_phi_function);
    (* 数学常量 *)
    ("圆周率", BuiltinFunctionValue pi_constant);
    ("自然对数底", BuiltinFunctionValue e_constant);
    ("欧拉常数", BuiltinFunctionValue euler_constant);
    ("黄金比例", BuiltinFunctionValue golden_ratio_constant);
  ]
