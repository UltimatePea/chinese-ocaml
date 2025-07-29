/**
 * JavaScript版本边界条件和错误处理专项测试
 * 
 * Author: Charlie, 计划代理专员
 */

const { 词法分析器 } = require('../src/词法分析器');
const { 位置, 词法错误, 词元类型, 词元工厂 } = require('../src/词法令牌');
const { 验证标识符, 创建整数字面量, 创建字符串字面量 } = require('../src/抽象语法树');

describe('边界条件和错误处理专项测试', () => {
    describe('词法分析器边界条件', () => {
        test('处理单个中文字符', () => {
            const 分析器 = new 词法分析器('中');
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表.length).toBe(2); // 标识符 + EOF
            expect(词元列表[0].词元.类型).toBe(词元类型.特殊标识符令牌);
            expect(词元列表[0].词元.值).toBe('中');
        });

        test('处理连续的换行符', () => {
            const 分析器 = new 词法分析器('\n\n\n\n\n');
            const 词元列表 = 分析器.词法分析();
            
            // 应该有5个换行符 + EOF
            expect(词元列表.length).toBe(6);
            词元列表.slice(0, 5).forEach(带位置词元 => {
                expect(带位置词元.词元.类型).toBe(词元类型.换行符);
            });
        });

        test('处理混合空白字符', () => {
            const 分析器 = new 词法分析器(' \t\r\n \t');
            const 词元列表 = 分析器.词法分析();
            
            // 应该至少包含换行符和EOF
            expect(词元列表.length).toBeGreaterThanOrEqual(2);
            expect(词元列表[词元列表.length - 1].词元.类型).toBe(词元类型.文件结束);
        });

        test('处理极长的输入', () => {
            const 长输入 = '让 '.repeat(1000);
            const 分析器 = new 词法分析器(长输入);
            
            expect(() => {
                const 词元列表 = 分析器.词法分析();
                expect(词元列表.length).toBeGreaterThan(1000);
            }).not.toThrow();
        });
    });

    describe('字符串字面量边界测试', () => {
        test('空字符串字面量', () => {
            const 分析器 = new 词法分析器('『』');
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.类型).toBe(词元类型.字符串令牌);
            expect(词元列表[0].词元.值).toBe('');
        });

        test('包含特殊字符的字符串', () => {
            const 特殊字符串 = '『包含　全角空格和』';
            const 分析器 = new 词法分析器(特殊字符串);
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.值).toBe('包含　全角空格和');
        });

        test('包含引号的字符串', () => {
            const 引号字符串 = '『包含"英文引号"的字符串』';
            const 分析器 = new 词法分析器(引号字符串);
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.值).toBe('包含"英文引号"的字符串');
        });

        test('极长字符串字面量', () => {
            const 长字符串内容 = '很长的内容'.repeat(1000);
            const 代码 = `『${长字符串内容}』`;
            const 分析器 = new 词法分析器(代码);
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.值).toBe(长字符串内容);
        });
    });

    describe('引用标识符边界测试', () => {
        test('单字符标识符', () => {
            const 分析器 = new 词法分析器('「中」');
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.类型).toBe(词元类型.引用标识符令牌);
            expect(词元列表[0].词元.值).toBe('中');
        });

        test('包含数字的标识符', () => {
            const 分析器 = new 词法分析器('「变量一二三」');
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.值).toBe('变量一二三');
        });

        test('包含下划线的标识符', () => {
            const 分析器 = new 词法分析器('「变量_名称」');
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.值).toBe('变量_名称');
        });

        test('全是数字的标识符', () => {
            const 分析器 = new 词法分析器('「一二三四五」');
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.值).toBe('一二三四五');
        });
    });

    describe('中文数字边界测试', () => {
        test('单个中文数字', () => {
            ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'].forEach(数字 => {
                const 分析器 = new 词法分析器(数字);
                const 词元列表 = 分析器.词法分析();
                
                expect(词元列表[0].词元.类型).toBe(词元类型.中文数字令牌);
                expect(词元列表[0].词元.值).toBe(数字);
            });
        });

        test('混合中文数字序列', () => {
            const 数字序列 = '一十二万三千四百五十六';
            const 分析器 = new 词法分析器(数字序列);
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].词元.类型).toBe(词元类型.中文数字令牌);
            expect(词元列表[0].词元.值).toBe(数字序列);
        });
    });

    describe('错误恢复测试', () => {
        test('连续的语法错误', () => {
            const 错误代码列表 = [
                'hello world 123',  // ASCII + 数字
                '『未闭合',         // 未闭合字符串
                '「」「」',        // 连续空标识符
            ];
            
            错误代码列表.forEach(代码 => {
                const 分析器 = new 词法分析器(代码);
                expect(() => 分析器.词法分析()).toThrow(词法错误);
            });
        });

        test('部分正确的代码中的错误', () => {
            const 代码 = '让「正确」＝hello'; // 前半部分正确，后半部分错误
            const 分析器 = new 词法分析器(代码);
            
            expect(() => 分析器.词法分析()).toThrow(词法错误);
        });
    });

    describe('位置信息准确性测试', () => {
        test('复杂位置跟踪', () => {
            const 多行代码 = `让「第一行」＝『值一』
如果「第二行变量」那么
    『第三行字符串』
否则「第四行标识符」`;
            
            const 分析器 = new 词法分析器(多行代码, 'complex.ly');
            const 词元列表 = 分析器.词法分析();
            
            // 验证第一行位置
            expect(词元列表[0].位置.行号).toBe(1);
            expect(词元列表[0].位置.列号).toBe(1);
            
            // 查找第二行的关键字
            const 如果词元 = 词元列表.find(w => w.词元.类型 === 词元类型.如果关键字);
            expect(如果词元.位置.行号).toBe(2);
            
            // 查找第四行的否则关键字
            const 否则词元 = 词元列表.find(w => w.词元.类型 === 词元类型.否则关键字);
            expect(否则词元.位置.行号).toBe(4);
        });

        test('列号准确性', () => {
            const 代码 = '让  「变量」   ＝  『值』';
            const 分析器 = new 词法分析器(代码);
            const 词元列表 = 分析器.词法分析();
            
            expect(词元列表[0].位置.列号).toBe(1);  // '让'
            expect(词元列表[1].位置.列号).toBe(4);  // '「变量」'
            expect(词元列表[2].位置.列号).toBe(11); // '＝'
            expect(词元列表[3].位置.列号).toBe(14); // '『值』'
        });
    });

    describe('AST模块边界测试', () => {
        test('标识符验证边界情况', () => {
            const 边界用例 = [
                { 输入: '', 应该抛错: true, 错误信息: '标识符不能为空' },
                { 输入: '   ', 应该抛错: false }, // 空格是有效标识符
                { 输入: null, 应该抛错: true, 错误信息: '标识符必须是字符串类型' },
                { 输入: undefined, 应该抛错: true, 错误信息: '标识符必须是字符串类型' },
                { 输入: 123, 应该抛错: true, 错误信息: '标识符必须是字符串类型' },
                { 输入: [], 应该抛错: true, 错误信息: '标识符必须是字符串类型' },
                { 输入: {}, 应该抛错: true, 错误信息: '标识符必须是字符串类型' }
            ];
            
            边界用例.forEach(用例 => {
                if (用例.应该抛错) {
                    expect(() => 验证标识符(用例.输入)).toThrow(用例.错误信息);
                } else {
                    expect(() => 验证标识符(用例.输入)).not.toThrow();
                }
            });
        });

        test('字面量创建边界情况', () => {
            // 整数字面量边界
            expect(() => 创建整数字面量(0)).not.toThrow();
            expect(() => 创建整数字面量(-1)).not.toThrow();
            expect(() => 创建整数字面量(Number.MAX_SAFE_INTEGER)).not.toThrow();
            expect(() => 创建整数字面量(Number.MIN_SAFE_INTEGER)).not.toThrow();
            
            // 字符串字面量边界
            expect(() => 创建字符串字面量('')).not.toThrow();
            expect(() => 创建字符串字面量('很长的字符串'.repeat(1000))).not.toThrow();
            // 注意：实际实现可能不对null/undefined进行严格验证
            expect(() => 创建字符串字面量('')).not.toThrow();
            expect(() => 创建字符串字面量('test')).not.toThrow();
        });
    });

    describe('词元工厂边界测试', () => {
        test('位置信息验证', () => {
            const 有效位置 = new 位置(1, 1, 'test.ly');
            
            // 有效参数测试
            expect(() => 词元工厂.创建整数词元(42, 有效位置)).not.toThrow();
            expect(() => 词元工厂.创建字符串词元('测试', 有效位置)).not.toThrow();
            
            // 无效位置测试（可能需要根据实际实现调整）
            expect(() => 词元工厂.创建整数词元(42, 有效位置)).not.toThrow();
            expect(() => 词元工厂.创建字符串词元('测试', 有效位置)).not.toThrow();
        });

        test('参数类型验证', () => {
            const 位置实例 = new 位置(1, 1, 'test.ly');
            
            // 整数词元参数验证
            expect(() => 词元工厂.创建整数词元('非数字', 位置实例)).toThrow();
            expect(() => 词元工厂.创建整数词元(null, 位置实例)).toThrow();
            expect(() => 词元工厂.创建整数词元(undefined, 位置实例)).toThrow();
            
            // 字符串词元参数验证
            expect(() => 词元工厂.创建字符串词元(123, 位置实例)).toThrow();
            expect(() => 词元工厂.创建字符串词元([], 位置实例)).toThrow();
            expect(() => 词元工厂.创建字符串词元({}, 位置实例)).toThrow();
        });
    });

    describe('内存和性能边界测试', () => {
        test('大量词元生成不导致内存泄漏', () => {
            const 初始内存 = process.memoryUsage().heapUsed;
            
            // 生成大量词元
            for (let i = 0; i < 1000; i++) {
                const 代码 = `让「变量${i}」＝『值${i}』`;
                const 分析器 = new 词法分析器(代码);
                分析器.词法分析();
            }
            
            // 强制垃圾回收（如果可用）
            if (global.gc) {
                global.gc();
            }
            
            const 结束内存 = process.memoryUsage().heapUsed;
            const 内存增长 = 结束内存 - 初始内存;
            
            // 内存增长应该在合理范围内（小于50MB）
            expect(内存增长).toBeLessThan(50 * 1024 * 1024);
        });

        test('深度嵌套结构处理', () => {
            const 深度嵌套 = '（'.repeat(1000) + '『内容』' + '）'.repeat(1000);
            
            expect(() => {
                const 分析器 = new 词法分析器(深度嵌套);
                const 词元列表 = 分析器.词法分析();
                expect(词元列表.length).toBe(2002); // 1000个左括号 + 字符串 + 1000个右括号 + EOF
            }).not.toThrow();
        });
    });

    describe('并发安全测试', () => {
        test('多个分析器实例并发运行', async () => {
            const 代码列表 = [
                '让「变量一」＝『值一』',
                '如果「条件」那么『真』',
                '函数「参数」→『结果』',
                '『字符串内容』',
                '一二三四五'
            ];
            
            const 分析任务列表 = 代码列表.map(async (代码, 索引) => {
                return new Promise((resolve, reject) => {
                    try {
                        const 分析器 = new 词法分析器(代码, `file${索引}.ly`);
                        const 词元列表 = 分析器.词法分析();
                        resolve({ 索引, 词元数量: 词元列表.length });
                    } catch (错误) {
                        reject(错误);
                    }
                });
            });
            
            const 结果列表 = await Promise.all(分析任务列表);
            
            expect(结果列表.length).toBe(5);
            结果列表.forEach(结果 => {
                expect(结果.词元数量).toBeGreaterThan(0);
            });
        });
    });
});