「：骆言标准库 — 列表模块

    提供列表操作函数，对应 OCaml 的 List 模块。
    用法：引入 『骆言/列表.ly』
    访问：「列表」之「映射」，「列表」之「左折」，等：」

模块 「列表」 ＝ 结构
  让 「长度」  ＝ 《List.length》
  让 「映射」  ＝ 《List.map》
  让 「过滤」  ＝ 《List.filter》
  让 「左折」  ＝ 《List.fold_left》
  让 「右折」  ＝ 《List.fold_right》
  让 「反转」  ＝ 《List.rev》
  让 「拼接」  ＝ 《List.append》
  让 「遍历」  ＝ 《List.iter》
  让 「查找」  ＝ 《List.find》
  让 「排序」  ＝ 《List.sort》
  让 「头」    ＝ 《List.hd》
  让 「尾」    ＝ 《List.tl》
  让 「存在」  ＝ 《List.exists》
  让 「全部」  ＝ 《List.for_all》
  让 「组合」  ＝ 《List.combine》
  让 「展平」  ＝ 《List.concat》
结束
