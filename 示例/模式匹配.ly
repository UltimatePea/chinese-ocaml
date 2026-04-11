「：自定义类型与模式匹配示例

    构造子必须以大写ASCII字母开头（OCaml规范）。
    例如 Leaf、Node 而非 「叶」、「节点」。：」

类型 「树」 =
  | Leaf
  | Node 的 「树」 * 整数 * 「树」

让 递归 「树的深度」 「t」 =
  匹配 「t」 与
  | Leaf → 0
  | Node （「左」，「_v」，「右」） →
      1 + max （「树的深度」 「左」） （「树的深度」 「右」）

让 「示例树」 =
  Node （Node （Leaf，1，Leaf），2，Node （Leaf，3，Leaf））

让 （） =
  Printf.printf "树的深度：%d\n" （「树的深度」 「示例树」）
