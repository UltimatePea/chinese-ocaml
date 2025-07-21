(** 骆言统一列表工具模块实现 - Unified List Utilities Implementation *)

(** Either类型定义 *)
type ('a, 'b) either = Left of 'a | Right of 'b

(** 安全的列表操作工具 *)
module Safe = struct
  (** 安全的列表头部获取 *)
  let head = function
    | [] -> None
    | h :: _ -> Some h

  (** 安全的列表尾部获取 *)
  let tail = function
    | [] -> None
    | _ :: t -> Some t

  (** 安全的列表元素访问 *)
  let rec nth lst n =
    if n < 0 then None
    else match lst with
      | [] -> None
      | h :: t -> if n = 0 then Some h else nth t (n - 1)

  (** 安全的列表最后一个元素 *)
  let rec last = function
    | [] -> None
    | [x] -> Some x
    | _ :: t -> last t

  (** 安全的列表初始部分（除最后一个元素） *)
  let rec init = function
    | [] -> None
    | [_] -> Some []
    | h :: t -> match init t with
        | None -> None
        | Some t' -> Some (h :: t')
end

(** 列表转换和映射工具 *)
module Transform = struct
  (** 带索引的映射 *)
  let mapi_safe f lst =
    let rec aux acc i = function
      | [] -> List.rev acc
      | h :: t -> match f i h with
          | None -> aux acc (i + 1) t
          | Some v -> aux (v :: acc) (i + 1) t
    in
    aux [] 0 lst

  (** 过滤并映射，一步完成 *)
  let filter_map f lst =
    let rec aux acc = function
      | [] -> List.rev acc
      | h :: t -> match f h with
          | None -> aux acc t
          | Some v -> aux (v :: acc) t
    in
    aux [] lst

  (** 分区并映射 *)
  let partition_map f lst =
    let rec aux left_acc right_acc = function
      | [] -> (List.rev left_acc, List.rev right_acc)
      | h :: t -> match f h with
          | Left v -> aux (v :: left_acc) right_acc t
          | Right v -> aux left_acc (v :: right_acc) t
    in
    aux [] [] lst

  (** 展平并映射 *)
  let flat_map f lst =
    List.concat (List.map f lst)

  (** 累积映射（保留中间结果） *)
  let scan_left f init lst =
    let rec aux acc current = function
      | [] -> List.rev (current :: acc)
      | h :: t -> 
          let next = f current h in
          aux (current :: acc) next t
    in
    aux [] init lst
end

(** 列表聚合和统计工具 *)
module Aggregate = struct
  (** 安全的列表求和 *)
  let sum_int lst = List.fold_left (+) 0 lst

  (** 安全的列表求和（浮点数） *)
  let sum_float lst = List.fold_left (+.) 0.0 lst

  (** 求列表最大值 *)
  let max_opt = function
    | [] -> None
    | h :: t -> Some (List.fold_left max h t)

  (** 求列表最小值 *)
  let min_opt = function
    | [] -> None
    | h :: t -> Some (List.fold_left min h t)

  (** 计算列表平均值 *)
  let average_float = function
    | [] -> None
    | lst -> 
        let sum = sum_float lst in
        let count = float_of_int (List.length lst) in
        Some (sum /. count)

  (** 计算列表中元素出现次数 *)
  let count_occurrences x lst =
    List.fold_left (fun acc y -> if x = y then acc + 1 else acc) 0 lst

  (** 按条件计数 *)
  let count_if predicate lst =
    List.fold_left (fun acc x -> if predicate x then acc + 1 else acc) 0 lst
end

(** 列表分组和排序工具 *)
module Group = struct
  (** 按键值分组 *)
  let group_by key_func lst =
    let rec aux acc = function
      | [] -> acc
      | h :: t ->
          let key = key_func h in
          let existing = try Some (List.assoc key acc) with Not_found -> None in
          let updated_acc = match existing with
            | None -> (key, [h]) :: acc
            | Some group -> (key, h :: group) :: (List.remove_assoc key acc)
          in
          aux updated_acc t
    in
    aux [] lst

  (** 去重（保持顺序） *)
  let unique lst =
    let rec aux acc seen = function
      | [] -> List.rev acc
      | h :: t -> if List.mem h seen then aux acc seen t
                  else aux (h :: acc) (h :: seen) t
    in
    aux [] [] lst

  (** 按条件去重 *)
  let unique_by key_func lst =
    let rec aux acc seen = function
      | [] -> List.rev acc
      | h :: t ->
          let key = key_func h in
          if List.mem key seen then aux acc seen t
          else aux (h :: acc) (key :: seen) t
    in
    aux [] [] lst

  (** 分块处理 *)
  let chunk size lst =
    if size <= 0 then failwith "Chunk size must be positive"
    else
      let rec aux acc current_chunk current_size = function
        | [] -> if current_chunk = [] then List.rev acc
                else List.rev (List.rev current_chunk :: acc)
        | h :: t ->
            if current_size = size then
              aux (List.rev current_chunk :: acc) [h] 1 t
            else
              aux acc (h :: current_chunk) (current_size + 1) t
      in
      aux [] [] 0 lst

  (** 交替组合两个列表 *)
  let rec interleave lst1 lst2 =
    match lst1, lst2 with
    | [], lst2 -> lst2
    | lst1, [] -> lst1
    | h1 :: t1, h2 :: t2 -> h1 :: h2 :: interleave t1 t2
end

(** 列表验证和检查工具 *)
module Validate = struct
  (** 检查列表是否所有元素都满足条件 *)
  let all predicate lst = List.for_all predicate lst

  (** 检查列表是否有元素满足条件 *)
  let any predicate lst = List.exists predicate lst

  (** 检查列表是否为空 *)
  let is_empty = function [] -> true | _ -> false

  (** 检查列表是否有重复元素 *)
  let has_duplicates lst =
    let rec aux seen = function
      | [] -> false
      | h :: t -> List.mem h seen || aux (h :: seen) t
    in
    aux [] lst

  (** 检查两个列表是否有相同元素 *)
  let has_intersection lst1 lst2 =
    List.exists (fun x -> List.mem x lst2) lst1
end

(** 高级列表操作工具 *)
module Advanced = struct
  (** 列表的笛卡尔积 *)
  let cartesian_product lst1 lst2 =
    Transform.flat_map (fun x -> List.map (fun y -> (x, y)) lst2) lst1

  (** 列表的排列组合 *)
  let rec combinations n lst =
    if n <= 0 then [[]]
    else match lst with
      | [] -> []
      | h :: t ->
          let with_h = List.map (fun comb -> h :: comb) (combinations (n - 1) t) in
          let without_h = combinations n t in
          with_h @ without_h

  (** 列表的全排列 *)
  let rec permutations = function
    | [] -> [[]]
    | lst ->
        Transform.flat_map (fun x ->
          let remaining = List.filter (fun y -> y <> x) lst in
          List.map (fun perm -> x :: perm) (permutations remaining)
        ) lst

  (** 滑动窗口 *)
  let sliding_window size lst =
    if size <= 0 then []
    else
      (* 实现List.take函数 *)
      let rec take n = function
        | [] -> []
        | h :: t when n > 0 -> h :: take (n - 1) t
        | _ -> []
      in
      let rec aux acc = function
        | lst when List.length lst < size -> List.rev acc
        | lst ->
            let window = take size lst in
            let rest = match lst with [] -> [] | _ :: t -> t in
            aux (window :: acc) rest
      in
      aux [] lst

  (** 转置（矩阵转置） *)
  let rec transpose = function
    | [] -> []
    | [] :: _ -> []
    | matrix ->
        let heads = List.map List.hd matrix in
        let tails = List.map List.tl matrix in
        heads :: transpose tails
end