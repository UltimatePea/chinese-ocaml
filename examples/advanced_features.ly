(* 骆言高级特性示例 *)

(* 类型定义 *)
类型 选项 = 
  | 无
  | 有 of int

类型 二叉树 = 
  | 空
  | 节点 of int * 二叉树 * 二叉树

(* 高阶函数 *)
递归 让 映射 = 函数 f lst ->
  匹配 lst 与
  | [] -> []
  | [head; ...tail] -> [f head; ...映射 f tail]

递归 让 过滤 = 函数 pred lst ->
  匹配 lst 与
  | [] -> []
  | [head; ...tail] ->
    如果 pred head 那么
      [head; ...过滤 pred tail]
    否则
      过滤 pred tail

递归 让 折叠 = 函数 f acc lst ->
  匹配 lst 与
  | [] -> acc
  | [head; ...tail] -> 折叠 f (f acc head) tail

(* 二叉树操作 *)
递归 让 插入 = 函数 value tree ->
  匹配 tree 与
  | 空 -> 节点 (value, 空, 空)
  | 节点 (v, left, right) ->
    如果 value < v 那么
      节点 (v, 插入 value left, right)
    否则
      节点 (v, left, 插入 value right)

递归 让 中序遍历 = 函数 tree ->
  匹配 tree 与
  | 空 -> []
  | 节点 (v, left, right) -> 
    中序遍历 left @ [v] @ 中序遍历 right

(* 测试数据 *)
让 数字列表 = [3; 1; 4; 1; 5; 9; 2; 6]
让 平方列表 = 映射 (函数 x -> x * x) 数字列表
让 偶数列表 = 过滤 (函数 x -> x % 2 == 0) 数字列表
让 总和 = 折叠 (函数 acc x -> acc + x) 0 数字列表

(* 构建二叉树 *)
让 树 = 插入 5 (插入 3 (插入 7 (插入 1 空)))
让 排序结果 = 中序遍历 树

(* 打印结果 *)
打印 "原始列表:"
打印 数字列表
打印 "平方列表:"
打印 平方列表
打印 "偶数列表:"
打印 偶数列表
打印 "总和:"
打印 总和
打印 "排序结果:"
打印 排序结果 