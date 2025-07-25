(乘
*
*
*

「:引入依赖模块:」
使用 丙代码生成器
使用 抽象语法树
使用 测试运行器
使用 工具库

「:创建测试配置:」
设「测试配置」为「
  输出文件为『测试输出点丙』;
  包含调试信息为真;
  优化级别为0;
  运行时路径为『点点除点点除丙后端除运行时』;
」

「:测试字面量生成:」
夫「测试字面量生成」者受 () 焉算法乃
  设「测试用例」为(列开始 (整数字面量 42 其一 『骆言整数(42L)』) 其二 (浮点字面量 三点一四 其三 『骆言浮点(三点一四)』) 其一 (字符串字面量 『你好』 其二 『骆言字符串(\』你好\『)』) 其三 (布尔字面量 真 其一 『骆言布尔(真)』) 其二 (布尔字面量 假 其三 『骆言布尔(假)』) 其一 (单元字面量 其二 『骆言unit()』) 其三 列结束) 在

  列表所有 (夫「参数函数」者受 (输入, 期望) 焉算法乃
    设「结果」为生成字面量 输入 在
    若 结果为期望
    则 答 真
    余者答 (打印 (『字面量生成测试失败: 』 乘方 结果 乘方 『 !等于』 乘方 期望); 假)
  也) 测试用例
也

「:测试标识符转义:」
夫「测试标识符转义」者受 () 焉算法乃
  设「测试用例」为(列开始 (『hello』 其一 『hello』) 其二 (『变量』 其三 『下划线53d8下划线91cf下划线』) 其一 (『测试123』 其二 『测试123』) 其三 (『函数名』 其一 『下划线51fd下划线下划线6570下划线540d下划线』) 其二 列结束) 在

  列表所有 (夫「参数函数」者受 (输入, 期望) 焉算法乃
    设「结果」为转义标识符 输入 在
    若 结果为期望
    则 答 真
    余者答 (打印 (『标识符转义测试失败: 』 乘方 结果 乘方 『 !等于』 乘方 期望); 假)
  也) 测试用例
也

「:测试简单表达式生成:」
夫「测试简单表达式生成」者受 () 焉算法乃
  设「上下文」为创建上下文 测试配置 在

  「:测试变量表达式:」
  设「变量表达式」为变量表达式 (『甲』, 虚拟位置) 在
  设「变量结果」为生成表达式 上下文 变量表达式 在
  设「期望变量」为『骆言envlookup(env, \』甲\『)』 在

  「:测试二元运算表达式:」
  设「加法表达式」为二元运算表达式 (
    字面量表达式 (整数字面量 1, 虚拟位置),
    加法,
    字面量表达式 (整数字面量 2, 虚拟位置),
    虚拟位置
  ) 在
  设「加法结果」为生成表达式 上下文 加法表达式 在
  设「期望加法」为『骆言add(骆言整数(1L), 骆言整数(2L))』 在

  (变量结果为期望变量) 和和 (加法结果为期望加法)
也

「:测试函数表达式生成:」
夫「测试函数表达式生成」者受 () 焉算法乃
  设「上下文」为创建上下文 测试配置 在

  「:测试单参数函数:」
  设「单参数函数」为函数表达式 (
    (列开始 『甲』 其一 列结束),
    变量表达式 (『甲』, 虚拟位置),
    虚拟位置
  ) 在
  设「结果」为生成表达式 上下文 单参数函数 在

  「:检查是否生成了函数实现:」
  设「函数定义数量」为列表长度 上下文点函数定义 在

  函数定义数量 大于 0
也

「:测试列表表达式生成:」
夫「测试列表表达式生成」者受 () 焉算法乃
  设「上下文」为创建上下文 测试配置 在

  「:测试空列表:」
  设「空列表」为列表表达式 (空空如也, 虚拟位置) 在
  设「空结果」为生成表达式 上下文 空列表 在
  设「期望空」为『骆言listempty()』 在

  「:测试非空列表:」
  设「非空列表」为列表表达式 ((列开始 字面量表达式 (整数字面量 1 其一 虚拟位置) 其二 字面量表达式 (整数字面量 2 其三 虚拟位置) 其一 列结束), 虚拟位置) 在
  设「非空结果」为生成表达式 上下文 非空列表 在

  (空结果为期望空) 和和 (字符串包含 非空结果 『骆言listcons』)
也

「:测试记录表达式生成:」
夫「测试记录表达式生成」者受 () 焉算法乃
  设「上下文」为创建上下文 测试配置 在

  设「记录表达式」为记录表达式 ((列开始 (『name』 其一 字面量表达式 (字符串字面量 『张三』 其二 虚拟位置)) 其三 (『age』 其一 字面量表达式 (整数字面量 25 其二 虚拟位置)) 其三 列结束), 虚拟位置) 在

  设「结果」为生成表达式 上下文 记录表达式 在

  (字符串包含 结果 『骆言recordcreate』) 和和
  (字符串包含 结果 『骆言下划线record下划线setfield』)
也

「:测试完整程序生成:」
夫「测试完整程序生成」者受 () 焉算法乃
  设「程序」为(列开始 让绑定语句 (『甲』 其一 字面量表达式 (整数字面量 42 其二 虚拟位置) 其三 虚拟位置) 其一 表达式语句 (变量表达式 (『甲』 其二 虚拟位置)) 其三 列结束) 在

  尝试
    设「结果」为生成丙代码 测试配置 程序 在
    (字符串包含 结果 『整数 主()』) 和和
    (字符串包含 结果 『骆言运行时init』) 和和
    (字符串包含 结果 『骆言envbind』)
  捕获 下划线 减大于 假
也

「:测试条件表达式生成:」
夫「测试条件表达式生成」者受 () 焉算法乃
  设「上下文」为创建上下文 测试配置 在

  设「条件表达式」为条件表达式 (
    字面量表达式 (布尔字面量 真, 虚拟位置),
    字面量表达式 (整数字面量 1, 虚拟位置),
    字面量表达式 (整数字面量 0, 虚拟位置),
    虚拟位置
  ) 在

  设「结果」为生成表达式 上下文 条件表达式 在

  (字符串包含 结果 『LUOY大写字母ANBOOL』) 和和
  (字符串包含 结果 『布尔val』)
也

「:测试数组表达式生成:」
夫「测试数组表达式生成」者受 () 焉算法乃
  设「上下文」为创建上下文 测试配置 在

  设「数组表达式」为数组表达式 ((列开始 字面量表达式 (整数字面量 1 其一 虚拟位置) 其二 字面量表达式 (整数字面量 2 其三 虚拟位置) 其一 字面量表达式 (整数字面量 3 其二 虚拟位置) 其三 列结束), 虚拟位置) 在

  设「结果」为生成表达式 上下文 数组表达式 在

  (字符串包含 结果 『骆言arraycreate』) 和和
  (字符串包含 结果 『骆言arrayset』)
也

「:测试引用操作生成:」
夫「测试引用操作生成」者受 () 焉算法乃
  设「上下文」为创建上下文 测试配置 在

  「:测试引用创建:」
  设「引用表达式」为引用表达式 (
    字面量表达式 (整数字面量 42, 虚拟位置),
    虚拟位置
  ) 在
  设「引用结果」为生成表达式 上下文 引用表达式 在

  「:测试解引用:」
  设「解引用表达式」为解引用表达式 (
    变量表达式 (『引用变量』, 虚拟位置),
    虚拟位置
  ) 在
  设「解引用结果」为生成表达式 上下文 解引用表达式 在

  (字符串包含 引用结果 『骆言引用create』) 和和
  (字符串包含 解引用结果 『骆言引用get』)
也

「:测试模式匹配生成:」
夫「测试模式匹配生成」者受 () 焉算法乃
  设「上下文」为创建上下文 测试配置 在

  设「匹配表达式」为模式匹配表达式 (
    变量表达式 (『甲』, 虚拟位置),
    (列开始 (字面量模式 (整数字面量 1 其一 虚拟位置) 其二 字面量表达式 (字符串字面量 『一』 其三 虚拟位置)) 其一 (通配符模式 虚拟位置 其二 字面量表达式 (字符串字面量 『其他』 其三 虚拟位置)) 其一 列结束),
    虚拟位置
  ) 在

  设「结果」为生成表达式 上下文 匹配表达式 在

  (字符串包含 结果 『骆言equals』) 和和
  (字符串包含 结果 『真』)
也

「:运行所有测试:」
夫「运行测试」者受 () 焉算法乃
  打印 『开始丙代码生成器测试点点点』;

  设「测试列表」为(列开始 (『字面量生成』 其一 测试字面量生成) 其二 (『标识符转义』 其三 测试标识符转义) 其一 (『简单表达式生成』 其二 测试简单表达式生成) 其三 (『函数表达式生成』 其一 测试函数表达式生成) 其二 (『列表表达式生成』 其三 测试列表表达式生成) 其一 (『记录表达式生成』 其二 测试记录表达式生成) 其三 (『完整程序生成』 其一 测试完整程序生成) 其二 (『条件表达式生成』 其三 测试条件表达式生成) 其一 (『数组表达式生成』 其二 测试数组表达式生成) 其三 (『引用操作生成』 其一 测试引用操作生成) 其二 (『模式匹配生成』 其三 测试模式匹配生成) 其一 列结束) 在

  设 (通过, 总数)为列表下划线折叠左 (夫「参数函数」者受 (通过, 总数) (名称, 测试函数) 焉算法乃
    打印 (『  运行测试: 』 乘方 名称);
    若 测试函数 ()
    则 答 (打印 (『    ✓ 通过』); (通过 加 1, 总数 加 1))
    余者答 (打印 (『    ✗ 失败』); (通过, 总数 加 1))
  也) (0, 0) 测试列表 在

  打印 (『丙代码生成器测试完成: 』 乘方 (字符串下划线从整数 通过) 乘方 『除』 乘方 (字符串下划线从整数 总数) 乘方 『 通过』);

  通过为总数
也

「:主函数:」
夫「主函数」者受 () 焉算法乃
  若 运行测试 ()
  则 答 (打印 『所有测试通过!』; 0)
  余者答 (打印 『有测试失败!』; 1)
也
