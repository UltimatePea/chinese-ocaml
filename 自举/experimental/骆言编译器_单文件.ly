(乘
*
*
*

「:基础数据类型和工具函数:」

「:字符串连接辅助函数 减 使用内置的字符串连接函数:」
夫「连接」者受 字符串一 字符串二 焉算法乃 答 字符串连接 字符串一 字符串二 也

「:简单的错误处理:」
类型 结果等于  或 成功 之 字符串
  或 失败 之 字符串

「:编译器配置:」
类型 配置等于「
  输入文件: 字符串;
  输出文件: 字符串;
  详细输出: 布尔;
」

「:默认配置:」
让「默认配置」等于「
  输入文件等于『』;
  输出文件等于『输出点丙』;
  详细输出等于假;
」

「:简单的你好世界代码生成器:」
夫「生成你好世界程序」者受 配置 焉算法乃
  让「丙代码」等于连接 『号包含 〈标准输入输出。子〉\数』 (连接
    『号包含 \』骆言运行时。子\『\数』 (连接
    『\n整数 主() 「\数』 (连接
    『    打印格式化(\』你好,来自骆言自举编译器!\\数\『);\数』 (连接
    『    返回 0;\数』
    『」\数』)))) 在
  答 成功 丙代码 也

「:写入文件功能 减 暂时简化为打印:」
夫「写入文件」者受 文件名 内容 焉算法乃
  打印 (连接 『写入文件: 』 文件名);
  打印 内容;
  答 成功 『文件写入完成』 也

「:主编译函数:」
夫「编译」者受 配置 焉算法乃
  若 配置点详细输出
  则 打印 (连接 『开始编译: 』 配置点输入文件);

  观 生成你好世界程序 配置 之 性
  或 成功 丙代码 减大于
    观 写入文件 配置点输出文件 丙代码 之 性
    或 成功 消息 减大于
      若 配置点详细输出
      则 打印 消息;
      答 成功 『编译成功』
    或 失败 错误 减大于
      答 失败 (连接 『写入失败: 』 错误)
    观毕
  或 失败 错误 减大于
    答 失败 (连接 『代码生成失败: 』 错误)
  观毕也

「:简单的命令行参数解析:」
递归夫「解析参数」者受 参数列表 配置 焉算法乃
  观「参数列表」之性
  或 空空如也 减大于 答 成功 配置
  或 『减对象』 :: 输出文件 :: 剩余 减大于
    答 解析参数 剩余 「 配置 与 输出文件等于输出文件 」
  或 『减值』 :: 剩余 减大于
    答 解析参数 剩余 「 配置 与 详细输出等于真 」
  或 文件名 :: 剩余 减大于
    若 配置点输入文件等于『』
    则 答 解析参数 剩余 「 配置 与 输入文件等于文件名 」
    余者答 失败 『只能指定一个输入文件』
  观毕也

「:打印结果:」
夫「打印结果」者受 结果 焉算法乃
  观「结果」之性
  或 成功 消息 减大于
    打印 (连接 『✓ 』 消息);
    答 0
  或 失败 错误 减大于
    打印 (连接 『✗ 』 错误);
    答 1
  观毕也

「:主函数:」
夫「主函数」者受 参数列表 焉算法乃
  观 解析参数 参数列表 默认配置 之 性
  或 成功 配置 减大于
    让「结果」等于编译 配置 在
    答 打印结果 结果
  或 失败 错误 减大于
    打印 (连接 『参数错误: 』 错误);
    答 1
  观毕也

「:测试入口 减 模拟命令行参数:」
让「测试参数」等于(列开始 『减值』 其一 『减对象』 其二 『测试点丙』 其三 『你好点骆言』 其一 列结束)
主函数 测试参数
