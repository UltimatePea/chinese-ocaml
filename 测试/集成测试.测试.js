/**
 * JavaScript版本集成测试
 * 验证各模块间协作功能
 * 
 * Author: Charlie, 计划代理专员
 */

const { 词法分析器 } = require('../src/词法分析器');
const { 位置, 词法错误, 词元类型 } = require('../src/词法令牌');
const { 
    诗词形式, 
    创建韵律信息, 
    创建整数字面量,
    创建字符串字面量,
    验证标识符 
} = require('../src/抽象语法树');

describe('JavaScript版本集成测试', () => {
    describe('词法分析器与AST模块集成', () => {
        test('词法分析结果可以构建AST节点', () => {
            const 代码 = '让「数值」＝『测试』';
            const 分析器 = new 词法分析器(代码);
            const 词元列表 = 分析器.词法分析();
            
            // 提取词元信息构建AST节点
            expect(词元列表.length).toBeGreaterThan(3);
            
            const 让词元 = 词元列表[0];
            const 标识符词元 = 词元列表[1];
            const 字符串词元 = 词元列表[3];
            
            expect(让词元.词元.类型).toBe(词元类型.让关键字);
            expect(标识符词元.词元.类型).toBe(词元类型.引用标识符令牌);
            expect(字符串词元.词元.类型).toBe(词元类型.字符串令牌);
            
            // 使用AST工厂函数创建对应节点
            const 字符串字面量 = 创建字符串字面量(字符串词元.词元.值);
            expect(字符串字面量.值).toBe('测试');
            expect(字符串字面量.类型).toBe('StringLit');
        });

        test('错误位置信息在模块间传递', () => {
            const 代码 = '「」'; // 空的引用标识符
            const 分析器 = new 词法分析器(代码, 'test.ly');
            
            expect(() => {
                分析器.词法分析();
            }).toThrow(词法错误);
            
            try {
                分析器.词法分析();
            } catch (错误) {
                expect(错误.位置).toBeDefined();
                expect(错误.位置.文件名).toBe('test.ly');
                expect(错误.位置.行号).toBe(1);
                expect(错误.位置.列号).toBe(1);
            }
        });
    });

    describe('完整程序分析流程', () => {
        test('简单赋值语句完整分析', () => {
            const 代码 = '让「姓名」＝『李白』';
            const 分析器 = new 词法分析器(代码, '诗人.ly');
            const 词元列表 = 分析器.词法分析();
            
            // 验证完整的词法分析流程
            expect(词元列表.length).toBe(5); // 让 + 标识符 + 等号 + 字符串 + EOF
            
            const 词元类型列表 = 词元列表.map(带位置词元 => 带位置词元.词元.类型);
            expect(词元类型列表).toEqual([
                词元类型.让关键字,
                词元类型.引用标识符令牌,
                词元类型.等号,
                词元类型.字符串令牌,
                词元类型.文件结束
            ]);
            
            // 验证标识符值
            expect(词元列表[1].词元.值).toBe('姓名');
            expect(词元列表[3].词元.值).toBe('李白');
        });

        test('条件语句完整分析', () => {
            const 代码 = '如果「条件」那么『真』否则『假』';
            const 分析器 = new 词法分析器(代码);
            const 词元列表 = 分析器.词法分析();
            
            // 验证条件语句的词法分析
            const 关键字列表 = 词元列表
                .filter(带位置词元 => 
                    带位置词元.词元.类型.includes('关键字') || 
                    带位置词元.词元.类型.includes('Keyword'))
                .map(带位置词元 => 带位置词元.词元.类型);
                
            expect(关键字列表).toContain(词元类型.如果关键字);
            expect(关键字列表).toContain(词元类型.那么关键字);
            expect(关键字列表).toContain(词元类型.否则关键字);
        });

        test('函数定义完整分析', () => {
            // 使用词法分析器支持的符号
            const 代码 = '让「加法」＝函数「甲」→函数「乙」→「甲」';
            const 分析器 = new 词法分析器(代码);
            const 词元列表 = 分析器.词法分析();
            
            // 验证函数定义的词法结构
            expect(词元列表.length).toBeGreaterThan(8);
            
            const 函数词元 = 词元列表.find(带位置词元 => 
                带位置词元.词元.类型 === 词元类型.函数关键字);
            expect(函数词元).toBeDefined();
            
            const 箭头词元 = 词元列表.filter(带位置词元 => 
                带位置词元.词元.类型 === 词元类型.箭头);
            expect(箭头词元.length).toBe(2); // 两个箭头
        });
    });

    describe('韵律编程特性集成测试', () => {
        test('诗词形式与词法分析集成', () => {
            // 测试支持的诗词形式
            expect(诗词形式.四言诗).toBe('FourCharPoetry');
            expect(诗词形式.五言诗).toBe('FiveCharPoetry');
            expect(诗词形式.七言诗).toBe('SevenCharPoetry');
            
            // 创建韵律信息
            const 韵律 = 创建韵律信息('平水韵', 2, 'AABA');
            expect(韵律.韵部).toBe('平水韵');
            
            // 验证韵律信息可以与词法分析结合使用
            const 代码 = '『平水韵』';
            const 分析器 = new 词法分析器(代码);
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.值).toBe('平水韵');
        });

        test('中文数字与数值字面量集成', () => {
            const 代码 = '一二三';
            const 分析器 = new 词法分析器(代码);
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.类型).toBe(词元类型.中文数字令牌);
            expect(词元列表[0].词元.值).toBe('一二三');
            
            // 验证可以创建对应的AST节点
            const 整数字面量 = 创建整数字面量(123);
            expect(整数字面量.值).toBe(123);
        });
    });

    describe('错误处理集成测试', () => {
        test('词法错误与位置信息集成', () => {
            const 代码 = 'hello\nworld';
            const 分析器 = new 词法分析器(代码, 'error.ly');
            
            try {
                分析器.词法分析();
                fail('应该抛出词法错误');
            } catch (错误) {
                expect(错误).toBeInstanceOf(词法错误);
                expect(错误.位置).toBeInstanceOf(位置);
                expect(错误.位置.文件名).toBe('error.ly');
                expect(错误.message).toContain('ASCII字符已禁用');
            }
        });

        test('标识符验证与词法分析集成', () => {
            // 测试AST模块的标识符验证
            expect(() => 验证标识符('')).toThrow('标识符不能为空');
            expect(() => 验证标识符(null)).toThrow('标识符必须是字符串类型');
            
            // 测试与词法分析的集成
            const 代码 = '「有效标识符」';
            const 分析器 = new 词法分析器(代码);
            const 词元列表 = 分析器.词法分析();
            
            const 标识符值 = 词元列表[0].词元.值;
            expect(() => 验证标识符(标识符值)).not.toThrow();
            expect(验证标识符(标识符值)).toBe('有效标识符');
        });
    });

    describe('性能集成测试', () => {
        test('大量词元处理性能', () => {
            // 生成包含多种词元类型的较大输入
            const 重复代码 = '让「变量」＝『值』\n'.repeat(100);
            const 开始时间 = Date.now();
            
            const 分析器 = new 词法分析器(重复代码);
            const 词元列表 = 分析器.词法分析();
            
            const 结束时间 = Date.now();
            const 处理时间 = 结束时间 - 开始时间;
            
            // 验证处理了正确数量的词元
            expect(词元列表.length).toBe(501); // (4词元+换行) * 100 + EOF
            
            // 性能应该在合理范围内
            expect(处理时间).toBeLessThan(1000); // 少于1秒
        });
    });

    describe('模块依赖关系测试', () => {
        test('所有模块可以正常互相导入', () => {
            expect(() => {
                const 词法模块 = require('../src/词法分析器');
                const 令牌模块 = require('../src/词法令牌');
                const AST模块 = require('../src/抽象语法树');
                const 演示模块 = require('../src/词法分析器演示');
                const 主程序模块 = require('../src/主程序');
                
                expect(词法模块).toBeDefined();
                expect(令牌模块).toBeDefined();
                expect(AST模块).toBeDefined();
                expect(演示模块).toBeDefined();
                expect(主程序模块).toBeDefined();
            }).not.toThrow();
        });

        test('循环依赖检测', () => {
            // 验证模块间没有循环依赖问题
            expect(() => {
                // 清除模块缓存后重新加载
                const moduleKeys = Object.keys(require.cache).filter(key => 
                    key.includes('src/'));
                moduleKeys.forEach(key => delete require.cache[key]);
                
                require('../src/词法分析器');
                require('../src/词法令牌');
                require('../src/抽象语法树');
            }).not.toThrow();
        });
    });

    describe('边界条件集成测试', () => {
        test('空文件处理', () => {
            const 分析器 = new 词法分析器('');
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表.length).toBe(1);
            expect(词元列表[0].词元.类型).toBe(词元类型.文件结束);
        });

        test('只包含空白字符的文件', () => {
            const 分析器 = new 词法分析器('   \n\n   \t  ');
            const 词元列表 = 分析器.词法分析();
            
            // 应该包含换行符和EOF
            expect(词元列表.length).toBeGreaterThan(1);
            expect(词元列表[词元列表.length - 1].词元.类型).toBe(词元类型.文件结束);
        });

        test('极长的标识符处理', () => {
            const 长标识符 = '变量' + '名'.repeat(1000);
            const 代码 = `「${长标识符}」`;
            const 分析器 = new 词法分析器(代码);
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.值).toBe(长标识符);
            expect(词元列表[0].词元.类型).toBe(词元类型.引用标识符令牌);
        });
    });

    describe('Unicode支持集成测试', () => {
        test('各种中文字符支持', () => {
            const 代码 = '让「测试_变量」＝『包含繁體字的字符串』';
            const 分析器 = new 词法分析器(代码);
            
            expect(() => {
                const 词元列表 = 分析器.词法分析();
                expect(词元列表.length).toBeGreaterThan(3);
            }).not.toThrow();
        });

        test('中文标点符号完整支持', () => {
            const 中文标点 = '（）【】，；：｜→＝';
            const 分析器 = new 词法分析器(中文标点);
            
            expect(() => {
                const 词元列表 = 分析器.词法分析();
                expect(词元列表.length).toBeGreaterThan(8);
            }).not.toThrow();
        });
    });
});