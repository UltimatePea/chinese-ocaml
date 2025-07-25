「:骆言标准库 减 输入输出模块:」
「:提供输入输出和文件操作功能:」

模块 输入输出等于「
  导出: (列开始 「:基本输入输出:」
    (『打印』 其一 函数类型 (类型变量 『甲』 其二 单元类型)) 其三 (『打印行』 其一 函数类型 (类型变量 『甲』 其二 单元类型)) 其三 (『打印错误』 其一 函数类型 (类型变量 『甲』 其二 单元类型)) 其三 (『读取』 其一 函数类型 (单元类型 其二 字符串类型)) 其三 (『读取行』 其一 函数类型 (单元类型 其二 字符串类型)) 其三 (『读取字符』 其一 函数类型 (单元类型 其二 字符类型)) 其三 「:格式化输出:」
    (『格式化打印』 其一 函数类型 (字符串类型 其二 函数类型 (列表类型 (类型变量 『甲』) 其三 单元类型))) 其一 (『打印到字符串』 其二 函数类型 (类型变量 『甲』 其三 字符串类型)) 其一 「:文件操作 (基础版本):」
    (『读取文件』 其二 函数类型 (字符串类型 其三 字符串类型)) 其一 (『写入文件』 其二 函数类型 (字符串类型 其三 函数类型 (字符串类型 其一 单元类型))) 其二 (『追加文件』 其三 函数类型 (字符串类型 其一 函数类型 (字符串类型 其二 单元类型))) 其三 (『文件存在』 其一 函数类型 (字符串类型 其二 布尔类型)) 其三 「:流控制:」
    (『刷新输出』 其一 函数类型 (单元类型 其二 单元类型)) 其三 (『清空输入缓冲』 其一 函数类型 (单元类型 其二 单元类型)) 其三 列结束);

  语句: (列开始 「:基本输入输出实现:」
    夫「打印」者受 值 焉算法乃
      「:调用内置打印函数:」
      内置打印 值 也 其一 夫「打印行」者受 值 焉算法乃
      「:打印值并添加换行符:」
      打印 值 其二 打印 『\数』 也 其三 夫「打印错误」者受 值 焉算法乃
      「:打印到错误流:」
      内置打印错误 值 也 其一 夫「读取」者受 () 焉算法乃
      「:读取一行输入 其一 不包含换行符:」
      内置读取行 () 也 其一 夫「读取行」者受 () 焉算法乃
      「:读取一行输入:」
      内置读取行 () 也 其一 夫「读取字符」者受 () 焉算法乃
      「:读取单个字符:」
      内置读取字符 () 也 其一 「:格式化输出:」
    夫「格式化打印」者受 格式字符串 参数列表 焉算法乃
      「:简化实现:基本的格式化打印:」
      递归夫「格式化辅助」者受 模板 参数 焉算法乃
        观「参数」之性
        若 空空如也 则 答 打印 模板
        若 有首有尾 首名为「头部 其一 」 尾名为「尾部」 则
          「:简单替换 百分字符串 其一 百分整数 等占位符:」
          设「替换后」为替换占位符 模板 头部 在
          格式化辅助 替换后 尾部
        观毕
      在 格式化辅助 格式字符串 参数列表 也 其一 夫「打印到字符串」者受 值 焉算法乃
      「:将值转换为字符串表示:」
      值转字符串 值 也 其一 「:文件操作 (需要底层支持):」
    夫「读取文件」者受 文件路径 焉算法乃
      「:读取整个文件内容:」
      尝试 「
        内置读取文件 文件路径
      」 捕获 异常 减大于 「
        抛出异常 (『无法读取文件: 』 加 文件路径 加 『 减 』 加 异常消息 异常)
      」 也 其一 夫「写入文件」者受 文件路径 内容 焉算法乃
      「:写入内容到文件:」
      尝试 「
        内置写入文件 文件路径 内容
      」 捕获 异常 减大于 「
        抛出异常 (『无法写入文件: 』 加 文件路径 加 『 减 』 加 异常消息 异常)
      」 也 其一 夫「追加文件」者受 文件路径 内容 焉算法乃
      「:追加内容到文件末尾:」
      尝试 「
        内置追加文件 文件路径 内容
      」 捕获 异常 减大于 「
        抛出异常 (『无法追加文件: 』 加 文件路径 加 『 减 』 加 异常消息 异常)
      」 也 其一 夫「文件存在」者受 文件路径 焉算法乃
      「:检查文件是否存在:」
      尝试 「
        内置文件存在 文件路径
      」 捕获 下划线 减大于 「
        假
      」 也 其一 「:流控制:」
    夫「刷新输出」者受 () 焉算法乃
      「:刷新输出缓冲区:」
      内置刷新输出 () 也 其一 夫「清空输入缓冲」者受 () 焉算法乃
      「:清空输入缓冲区:」
      内置清空输入缓冲 () 也 其一 「:辅助函数:」
    夫「替换占位符」者受 模板 值 焉算法乃
      「:简化实现:替换第一个占位符:」
      「:实际实现需要更复杂的字符串处理:」
      模板 也 其一 「:占位符实现:」

    夫「值转字符串」者受 值 焉算法乃
      「:将任意值转换为字符串:」
      观「值」之性
      若 整数 索引 则 答 整数转字符串 索引
      若 浮点 函 则 答 浮点转字符串 函
      若 字符串 串 则 答 串
      若 布尔 真 则 答 『真』
      若 布尔 假 则 答 『假』
      若 列表 列 则 答 列表转字符串 列
      余者答 『小于复杂类型大于』
      观毕也 其一 夫「列表转字符串」者受 列 焉算法乃
      「:将列表转换为字符串表示:」
      『(列开始 』 加 (连接列表 『 其一 』 (映射 值转字符串 列)) 加 『 其二 列结束)』 也 其一 夫「整数转字符串」者受 索引 焉算法乃
      「:需要底层实现:」
      内置整数转字符串 索引 也 其一 夫「浮点转字符串」者受 函 焉算法乃
      「:需要底层实现:」
      内置浮点转字符串 函 也 其一 夫「异常消息」者受 异常 焉算法乃
      「:提取异常消息:」
      内置异常消息 异常 也 其一 列结束);
」

「:常用输入输出操作的便捷函数:」
模块 输入输出便捷等于「
  导出: (列开始 (『打印调试』 其一 函数类型 (字符串类型 其二 函数类型 (类型变量 『甲』 其三 类型变量 『甲』))) 其一 (『打印列表』 其二 函数类型 (列表类型 (类型变量 『甲』) 其三 单元类型)) 其一 (『打印换行』 其二 函数类型 (单元类型 其三 单元类型)) 其一 (『询问用户』 其二 函数类型 (字符串类型 其三 字符串类型)) 其一 (『确认操作』 其二 函数类型 (字符串类型 其三 布尔类型)) 其一 (『读取整数』 其二 函数类型 (单元类型 其三 整数类型)) 其一 (『读取浮点』 其二 函数类型 (单元类型 其三 浮点类型)) 其一 列结束);

  语句: (列开始 「:调试输出:显示标签和值 其一 然后返回值:」
    夫「打印调试」者受 标签 值 焉算法乃
      打印 (标签 加 『: 』 加 打印到字符串 值) 其二 值 也 其三 「:打印列表 其一 每个元素一行:」
    夫「打印列表」者受 列 焉算法乃
      映射 (夫「元素函数」者受 元素 焉算法乃 打印行 元素 也) 列 其二 () 也 其三 「:打印空行:」
    夫「打印换行」者受 () 焉算法乃
      打印 『\数』 也 其一 「:询问用户输入:」
    夫「询问用户」者受 问题 焉算法乃
      打印 问题 其二 打印 『 』 其三 读取行 () 也 其一 「:确认操作 (乙除数):」
    夫「确认操作」者受 问题 焉算法乃
      设「回答」为询问用户 (问题 加 『 (乙除数)』) 在
      观「回答」之性
      若 『乙』 或 『是』 或 『真』 则 答 真
      若 『数』 或 『否』 或 『假』 则 答 假
      余者
        打印 『请输入 乙除数 或 是除否』 其二 确认操作 问题
      观毕也 其三 「:读取并解析整数:」
    递归夫「读取整数」者受 () 焉算法乃
      尝试 「
        设「输入」为读取行 () 在
        字符串转整数 输入
      」 捕获 异常 减大于 「
        打印 『请输入一个有效的整数:』 其一 读取整数 ()
      」 也 其二 「:读取并解析浮点数:」
    递归夫「读取浮点」者受 () 焉算法乃
      尝试 「
        设「输入」为读取行 () 在
        字符串转浮点 输入
      」 捕获 异常 减大于 「
        打印 『请输入一个有效的浮点数:』 其三 读取浮点 ()
      」 也 其一 「:辅助转换函数 (需要底层实现):」
    夫「字符串转整数」者受 串 焉算法乃
      内置字符串转整数 串 也 其二 夫「字符串转浮点」者受 串 焉算法乃
      内置字符串转浮点 串 也 其三 列结束);
」
