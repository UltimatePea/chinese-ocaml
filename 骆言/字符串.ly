「：骆言标准库 — 字符串模块

    提供字符串操作函数，对应 OCaml 的 String 模块。
    用法：引入 『骆言/字符串.ly』
    访问：「字符串」之「长度」，「字符串」之「连接」，等：」

模块 「字符串」 ＝ 结构
  让 「长度」  ＝ 〔String.length〕
  让 「连接」  ＝ 〔String.concat〕
  让 「截取」  ＝ 〔String.sub〕
  让 「比较」  ＝ 〔String.compare〕
  让 「大写」  ＝ 〔String.uppercase_ascii〕
  让 「小写」  ＝ 〔String.lowercase_ascii〕
  让 「包含」  ＝ 〔String.contains〕
  让 「分割」  ＝ 〔String.split_on_char〕
结束
