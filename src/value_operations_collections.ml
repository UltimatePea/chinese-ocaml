(** 骆言集合值操作模块 - Collection Value Operations Module
    
    技术债务改进：大型模块重构优化 Phase 2.3 - 集合值类型操作模块化
    处理集合值类型：ListValue, ArrayValue, TupleValue
    
    @author 骆言AI代理
    @version 2.3 - 集合值操作模块
    @since 2025-07-24 Fix #1046
*)

open Value_types

(** 初始化模块日志器 *)
let () = Logger_utils.init_no_logger "ValueOperationsCollections"

(** 集合值转换为字符串 *)
let string_of_collection_value value =
  let value_to_string = function
    | IntValue i -> string_of_int i
    | FloatValue f -> string_of_float f
    | StringValue s -> "\"" ^ s ^ "\""
    | BoolValue b -> if b then "真" else "假"
    | UnitValue -> "()"
    | v -> string_of_value_type v (* 使用基础的类型名称 *)
  in
  match value with
  | ListValue items ->
      let items_str = List.map value_to_string items |> String.concat "; " in
      "[" ^ items_str ^ "]"
  | ArrayValue arr ->
      let items_str = Array.to_list arr |> List.map value_to_string |> String.concat "; " in
      "[|" ^ items_str ^ "|]"
  | TupleValue items ->
      let items_str = List.map value_to_string items |> String.concat ", " in
      "(" ^ items_str ^ ")"
  | _ -> failwith "非集合值类型"

(** 列表操作 - 获取长度 *)
let list_length = function
  | ListValue items -> IntValue (List.length items)
  | _ -> raise (RuntimeError "列表长度操作需要列表值")

(** 列表操作 - 头部 *)
let list_head = function
  | ListValue [] -> raise (RuntimeError "空列表没有头部")
  | ListValue (head :: _) -> head
  | _ -> raise (RuntimeError "列表头部操作需要列表值")

(** 列表操作 - 尾部 *)
let list_tail = function
  | ListValue [] -> raise (RuntimeError "空列表没有尾部")
  | ListValue (_ :: tail) -> ListValue tail
  | _ -> raise (RuntimeError "列表尾部操作需要列表值")

(** 列表操作 - 追加元素到头部 *)
let list_cons value = function
  | ListValue items -> ListValue (value :: items)
  | _ -> raise (RuntimeError "列表cons操作需要列表值")

(** 列表操作 - 连接两个列表 *)
let list_append list1 list2 =
  match (list1, list2) with
  | (ListValue items1, ListValue items2) -> ListValue (items1 @ items2)
  | _ -> raise (RuntimeError "列表连接需要两个列表值")

(** 列表操作 - 反转列表 *)
let list_reverse = function
  | ListValue items -> ListValue (List.rev items)
  | _ -> raise (RuntimeError "列表反转操作需要列表值")

(** 列表操作 - 映射函数到列表 *)
let list_map f = function
  | ListValue items -> ListValue (List.map f items)
  | _ -> raise (RuntimeError "列表映射操作需要列表值")

(** 列表操作 - 过滤列表 *)
let list_filter pred = function
  | ListValue items -> 
      let filtered = List.filter (fun item -> 
        match pred item with
        | BoolValue true -> true
        | BoolValue false -> false
        | _ -> raise (RuntimeError "过滤谓词必须返回布尔值")
      ) items in
      ListValue filtered
  | _ -> raise (RuntimeError "列表过滤操作需要列表值")

(** 列表操作 - 获取指定索引的元素 *)
let list_nth list index =
  match (list, index) with
  | (ListValue items, IntValue i) ->
      if i < 0 || i >= List.length items then
        raise (RuntimeError "列表索引超出范围")
      else
        List.nth items i
  | _ -> raise (RuntimeError "列表索引访问需要列表值和整数索引")

(** 数组操作 - 获取长度 *)
let array_length = function
  | ArrayValue arr -> IntValue (Array.length arr)
  | _ -> raise (RuntimeError "数组长度操作需要数组值")

(** 数组操作 - 获取指定索引的元素 *)
let array_get array index =
  match (array, index) with
  | (ArrayValue arr, IntValue i) ->
      if i < 0 || i >= Array.length arr then
        raise (RuntimeError "数组索引超出范围")
      else
        arr.(i)
  | _ -> raise (RuntimeError "数组访问需要数组值和整数索引")

(** 数组操作 - 设置指定索引的元素 *)
let array_set array index value =
  match (array, index) with
  | (ArrayValue arr, IntValue i) ->
      if i < 0 || i >= Array.length arr then
        raise (RuntimeError "数组索引超出范围")
      else (
        arr.(i) <- value;
        UnitValue
      )
  | _ -> raise (RuntimeError "数组设置需要数组值和整数索引")

(** 数组操作 - 创建指定长度和初始值的数组 *)
let array_make length init_value =
  match length with
  | IntValue len ->
      if len < 0 then
        raise (RuntimeError "数组长度不能为负数")
      else
        ArrayValue (Array.make len init_value)
  | _ -> raise (RuntimeError "数组创建需要整数长度")

(** 数组操作 - 从列表创建数组 *)
let array_of_list = function
  | ListValue items -> ArrayValue (Array.of_list items)
  | _ -> raise (RuntimeError "从列表创建数组需要列表值")

(** 数组操作 - 将数组转换为列表 *)
let array_to_list = function
  | ArrayValue arr -> ListValue (Array.to_list arr)
  | _ -> raise (RuntimeError "数组转列表操作需要数组值")

(** 元组操作 - 获取长度 *)
let tuple_length = function
  | TupleValue items -> IntValue (List.length items)
  | _ -> raise (RuntimeError "元组长度操作需要元组值")

(** 元组操作 - 获取指定索引的元素 *) 
let tuple_nth tuple index =
  match (tuple, index) with
  | (TupleValue items, IntValue i) ->
      if i < 0 || i >= List.length items then
        raise (RuntimeError "元组索引超出范围")
      else
        List.nth items i
  | _ -> raise (RuntimeError "元组索引访问需要元组值和整数索引")

(** 集合通用操作 - 检查是否为空 *)
let is_empty = function
  | ListValue [] -> BoolValue true
  | ListValue _ -> BoolValue false
  | ArrayValue arr -> BoolValue (Array.length arr = 0)
  | TupleValue [] -> BoolValue true
  | TupleValue _ -> BoolValue false
  | _ -> raise (RuntimeError "空检查仅支持集合类型")

(** 集合通用操作 - 获取大小 *)
let collection_size = function
  | ListValue items -> IntValue (List.length items) 
  | ArrayValue arr -> IntValue (Array.length arr)
  | TupleValue items -> IntValue (List.length items)
  | _ -> raise (RuntimeError "大小获取仅支持集合类型")

(** 集合相等性比较 *)
let rec compare_collections v1 v2 =
  match (v1, v2) with
  | (ListValue items1, ListValue items2) ->
      compare_list_items items1 items2
  | (ArrayValue arr1, ArrayValue arr2) ->
      compare_list_items (Array.to_list arr1) (Array.to_list arr2)
  | (TupleValue items1, TupleValue items2) ->
      compare_list_items items1 items2
  | _ -> failwith "类型不匹配的集合比较"

and compare_list_items items1 items2 =
  match (items1, items2) with
  | ([], []) -> 0
  | ([], _) -> -1
  | (_, []) -> 1
  | (h1::t1, h2::t2) ->
      let cmp = compare_values h1 h2 in
      if cmp = 0 then compare_list_items t1 t2 else cmp

and compare_values v1 v2 =
  (* 简化的值比较，实际应该调用完整的值比较函数 *)
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> compare i1 i2
  | (FloatValue f1, FloatValue f2) -> compare f1 f2
  | (StringValue s1, StringValue s2) -> compare s1 s2
  | (BoolValue b1, BoolValue b2) -> compare b1 b2
  | (UnitValue, UnitValue) -> 0
  | _ when is_collection_value v1 && is_collection_value v2 -> 
      compare_collections v1 v2
  | _ -> failwith "不支持的值类型比较"