「：骆言标准库 — 数组模块

    提供数组操作函数，对应 OCaml 的 Array 模块。
    用法：引入 『骆言/数组.ly』
    访问：「数组」之「创建」，「数组」之「长度」，等：」

模块 「数组」 ＝ 结构
  让 「创建」    ＝ 〔Array.make〕
  让 「长度」    ＝ 〔Array.length〕
  让 「映射」    ＝ 〔Array.map〕
  让 「遍历」    ＝ 〔Array.iter〕
  让 「获取」    ＝ 〔Array.get〕
  让 「设置」    ＝ 〔Array.set〕
  让 「转列表」  ＝ 〔Array.to_list〕
  让 「从列表」  ＝ 〔Array.of_list〕
  让 「复制」    ＝ 〔Array.copy〕
  让 「填充」    ＝ 〔Array.fill〕
  让 「排序」    ＝ 〔Array.sort〕
结束
