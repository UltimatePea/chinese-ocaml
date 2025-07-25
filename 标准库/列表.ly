「:骆言标准库 减 列表模块:」
「:提供列表操作和函数式编程工具:」

模块 列表等于「
  导出: (列开始 「:基本操作:」
    (『长度』 其一 函数类型 (列表类型 (类型变量 『甲』) 其二 整数类型)) 其三 (『是否为空』 其一 函数类型 (列表类型 (类型变量 『甲』) 其二 布尔类型)) 其三 (『头部』 其一 函数类型 (列表类型 (类型变量 『甲』) 其二 类型变量 『甲』)) 其三 (『尾部』 其一 函数类型 (列表类型 (类型变量 『甲』) 其二 列表类型 (类型变量 『甲』))) 其三 (『连接』 其一 函数类型 (列表类型 (类型变量 『甲』) 其二 函数类型 (列表类型 (类型变量 『甲』) 其三 列表类型 (类型变量 『甲』)))) 其一 (『反转』 其二 函数类型 (列表类型 (类型变量 『甲』) 其三 列表类型 (类型变量 『甲』))) 其一 「:高阶函数:」
    (『映射』 其二 函数类型 (函数类型 (类型变量 『甲』 其三 类型变量 『乙』) 其一 函数类型 (列表类型 (类型变量 『甲』) 其二 列表类型 (类型变量 『乙』)))) 其三 (『过滤』 其一 函数类型 (函数类型 (类型变量 『甲』 其二 布尔类型) 其三 函数类型 (列表类型 (类型变量 『甲』) 其一 列表类型 (类型变量 『甲』)))) 其二 (『折叠左』 其三 函数类型 (函数类型 (类型变量 『乙』 其一 函数类型 (类型变量 『甲』 其二 类型变量 『乙』)) 其三 函数类型 (类型变量 『乙』 其一 函数类型 (列表类型 (类型变量 『甲』) 其二 类型变量 『乙』)))) 其三 (『折叠右』 其一 函数类型 (函数类型 (类型变量 『甲』 其二 函数类型 (类型变量 『乙』 其三 类型变量 『乙』)) 其一 函数类型 (类型变量 『乙』 其二 函数类型 (列表类型 (类型变量 『甲』) 其三 类型变量 『乙』)))) 其一 (『查找』 其二 函数类型 (函数类型 (类型变量 『甲』 其三 布尔类型) 其一 函数类型 (列表类型 (类型变量 『甲』) 其二 类型变量 『甲』))) 其三 「:列表构造:」
    (『范围』 其一 函数类型 (整数类型 其二 函数类型 (整数类型 其三 列表类型 (整数类型)))) 其一 (『重复』 其二 函数类型 (整数类型 其三 函数类型 (类型变量 『甲』 其一 列表类型 (类型变量 『甲』)))) 其二 (『取前个』 其三 函数类型 (整数类型 其一 函数类型 (列表类型 (类型变量 『甲』) 其二 列表类型 (类型变量 『甲』)))) 其三 (『跳过个』 其一 函数类型 (整数类型 其二 函数类型 (列表类型 (类型变量 『甲』) 其三 列表类型 (类型变量 『甲』)))) 其一 「:排序和搜索:」
    (『排序』 其二 函数类型 (函数类型 (类型变量 『甲』 其三 函数类型 (类型变量 『甲』 其一 整数类型)) 其二 函数类型 (列表类型 (类型变量 『甲』) 其三 列表类型 (类型变量 『甲』)))) 其一 (『包含』 其二 函数类型 (类型变量 『甲』 其三 函数类型 (列表类型 (类型变量 『甲』) 其一 布尔类型))) 其二 (『索引』 其三 函数类型 (整数类型 其一 函数类型 (列表类型 (类型变量 『甲』) 其二 类型变量 『甲』))) 其三 列结束);

  语句: (列开始 「:基本操作:」
    夫「长度」者受 列 焉算法乃
      观「列」之性
      若 空空如也 则 答 0
      若 有首有尾 首名为「下划线 其一 」 尾名为「尾」 则 答 1 加 长度 尾
      观毕也 其二 夫「是否为空」者受 列 焉算法乃
      观「列」之性
      若 空空如也 则 答 真
      余者则 答 假
      观毕也 其三 夫「头部」者受 列 焉算法乃
      观「列」之性
      若 有首有尾 首名为「首 其一 」 尾名为「下划线」 则 答 首
      若 空空如也 则 答 抛出异常 『空列表没有头部』
      观毕也 其一 夫「尾部」者受 列 焉算法乃
      观「列」之性
      若 有首有尾 首名为「下划线 其一 」 尾名为「尾」 则 答 尾
      若 空空如也 则 答 抛出异常 『空列表没有尾部』
      观毕也 其一 夫「连接」者受 列表一 列表二 焉算法乃
      观「列表一」之性
      若 空空如也 则 答 列表二
      若 有首有尾 首名为「首 其一 」 尾名为「尾」 则 答 有首有尾 首名为「首 其一 」 尾名为「连接 尾 列表二」
      观毕也 其一 夫「反转」者受 列 焉算法乃
      递归夫「反转辅助」者受 累 列 焉算法乃
        观「列」之性
        若 空空如也 则 答 累
        若 有首有尾 首名为「首 其一 」 尾名为「尾」 则 答 反转辅助 有首有尾 首名为「首 其一 」 尾名为「累」 尾
        观毕
      在 反转辅助 空空如也 列 也 其一 「:高阶函数:」
    递归夫「映射」者受 函 列 焉算法乃
      观「列」之性
      若 空空如也 则 答 空空如也
      若 有首有尾 首名为「首 其一 」 尾名为「尾」 则 答 有首有尾 首名为「函 首 其一 」 尾名为「映射 函 尾」
      观毕也 其一 递归夫「过滤」者受 条件 列 焉算法乃
      观「列」之性
      若 空空如也 则 答 空空如也
      若 有首有尾 首名为「首 其一 」 尾名为「尾」 则
        若 条件 首 则
          答 有首有尾 首名为「首 其一 」 尾名为「过滤 条件 尾」
        余者
          答 过滤 条件 尾
      观毕也 其一 递归夫「折叠左」者受 函 累 列 焉算法乃
      观「列」之性
      若 空空如也 则 答 累
      若 有首有尾 首名为「首 其一 」 尾名为「尾」 则 答 折叠左 函 (函 累 首) 尾
      观毕也 其一 递归夫「折叠右」者受 函 累 列 焉算法乃
      观「列」之性
      若 空空如也 则 答 累
      若 有首有尾 首名为「首 其一 」 尾名为「尾」 则 答 函 首 (折叠右 函 累 尾)
      观毕也 其一 递归夫「查找」者受 条件 列 焉算法乃
      观「列」之性
      若 空空如也 则 答 抛出异常 『未找到满足条件的元素』
      若 有首有尾 首名为「首 其一 」 尾名为「尾」 则
        若 条件 首 则 答 首
        余者答 查找 条件 尾
      观毕也 其一 「:列表构造:」
    递归夫「范围」者受 开始 结束 焉算法乃
      若 开始 大于 结束 则 答 空空如也
      余者答 有首有尾 首名为「开始 其一 」 尾名为「范围 (开始 加 1) 结束」 也 其一 递归夫「重复」者受 次数 值 焉算法乃
      若 次数 小于等于0 则 答 空空如也
      余者答 有首有尾 首名为「值 其一 」 尾名为「重复 (次数 减 1) 值」 也 其一 递归夫「取前个」者受 数 列 焉算法乃
      若 数 小于等于0 则 答 空空如也
      余者
        观「列」之性
        若 空空如也 则 答 空空如也
        若 有首有尾 首名为「首 其一 」 尾名为「尾」 则 答 有首有尾 首名为「首 其一 」 尾名为「取前个 (数 减 1) 尾」
        观毕也 其一 递归夫「跳过个」者受 数 列 焉算法乃
      若 数 小于等于0 则 答 列
      余者
        观「列」之性
        若 空空如也 则 答 空空如也
        若 有首有尾 首名为「下划线 其一 」 尾名为「尾」 则 答 跳过个 (数 减 1) 尾
        观毕也 其一 「:简单排序实现 (插入排序):」
    夫「排序」者受 比较函数 列 焉算法乃
      递归夫「插入」者受 甲 已排序列表 焉算法乃
        观「已排序列表」之性
        若 空空如也 则 答 (列开始 甲 其一 列结束)
        若 有首有尾 首名为「首 其一 」 尾名为「尾」 则
          若 比较函数 甲 首 小于等于0 则 答 有首有尾 首名为「甲 其一 首 其一 」 尾名为「尾」
          余者答 有首有尾 首名为「首 其一 」 尾名为「插入 甲 尾」
        观毕
      在
      递归夫「插入排序」者受 列 焉算法乃
        观「列」之性
        若 空空如也 则 答 空空如也
        若 有首有尾 首名为「首 其一 」 尾名为「尾」 则 答 插入 首 (插入排序 尾)
        观毕
      在 插入排序 列 也 其一 递归夫「包含」者受 元素 列 焉算法乃
      观「列」之性
      若 空空如也 则 答 假
      若 有首有尾 首名为「首 其一 」 尾名为「尾」 则
        若 首等于元素 则 答 真
        余者答 包含 元素 尾
      观毕也 其一 递归夫「索引」者受 索引 列 焉算法乃
      若 索引 小于 0 则 答 抛出异常 『索引不能为负数』
      余者
        观「列」之性
        若 空空如也 则 答 抛出异常 『索引超出范围』
        若 有首有尾 首名为「首 其一 」 尾名为「尾」 则
          若 索引等于0 则 答 首
          余者答 索引 (索引 减 1) 尾
        观毕也 其一 列结束);
」