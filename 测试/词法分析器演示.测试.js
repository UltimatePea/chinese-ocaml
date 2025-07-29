/**
 * 词法分析器演示模块测试
 * 
 * Author: Charlie, 计划代理专员
 */

const { execSync } = require('child_process');
const path = require('path');

const { 演示词法分析器 } = require('../src/词法分析器演示');

describe('词法分析器演示模块测试', () => {
    let consoleSpy;
    
    beforeEach(() => {
        consoleSpy = jest.spyOn(console, 'log').mockImplementation();
    });
    
    afterEach(() => {
        consoleSpy.mockRestore();
    });

    describe('演示函数基础功能测试', () => {
        test('演示函数可以正常调用', () => {
            expect(() => {
                演示词法分析器();
            }).not.toThrow();
        });

        test('演示函数输出包含预期标题', () => {
            演示词法分析器();
            
            expect(consoleSpy).toHaveBeenCalledWith('🔤 骆言词法分析器 - JavaScript版本演示');
            expect(consoleSpy).toHaveBeenCalledWith('═'.repeat(50));
        });

        test('演示函数包含完整的测试用例', () => {
            演示词法分析器();
            
            // 验证所有测试用例都被执行
            const expectedTestCases = [
                '基本关键字',
                '中文标点符号', 
                '字符串字面量',
                '引用标识符',
                '中文数字',
                '复合表达式',
                '多行代码'
            ];
            
            expectedTestCases.forEach(testCase => {
                const found = consoleSpy.mock.calls.some(call => 
                    call[0] && call[0].includes(testCase));
                expect(found).toBe(true);
            });
        });

        test('演示函数包含错误处理演示', () => {
            演示词法分析器();
            
            expect(consoleSpy).toHaveBeenCalledWith('\n🚨 错误处理演示:');
            expect(consoleSpy).toHaveBeenCalledWith('═'.repeat(30));
            
            // 验证错误用例
            const expectedErrorCases = [
                'ASCII字符禁用',
                '阿拉伯数字禁用',
                '未闭合字符串'
            ];
            
            expectedErrorCases.forEach(errorCase => {
                const found = consoleSpy.mock.calls.some(call => 
                    call[0] && call[0].includes(errorCase));
                expect(found).toBe(true);
            });
        });

        test('演示函数输出完成信息', () => {
            演示词法分析器();
            
            expect(consoleSpy).toHaveBeenCalledWith('\n✅ Phase 2 词法分析器转换完成!');
            expect(consoleSpy).toHaveBeenCalledWith('支持完整的中文编程语法词法分析');
            expect(consoleSpy).toHaveBeenCalledWith('🎯 准备开始 Phase 3: 语法分析器转换');
        });
    });

    describe('词法分析测试覆盖性验证', () => {
        test('基本关键字测试覆盖', () => {
            演示词法分析器();
            
            // 验证关键字测试输出
            const 关键字输出 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('让 如果 那么 否则'));
            expect(关键字输出).toBeTruthy();
        });

        test('中文标点符号测试覆盖', () => {
            演示词法分析器();
            
            // 验证标点符号测试输出
            const 标点输出 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('（）【】，；：｜→＝'));
            expect(标点输出).toBeTruthy();
        });

        test('字符串字面量测试覆盖', () => {
            演示词法分析器();
            
            // 验证字符串测试输出
            const 字符串输出 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('这是一个字符串'));
            expect(字符串输出).toBeTruthy();
        });

        test('引用标识符测试覆盖', () => {
            演示词法分析器();
            
            // 验证标识符测试输出
            const 标识符输出 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('变量名」「函数名'));
            expect(标识符输出).toBeTruthy();
        });

        test('中文数字测试覆盖', () => {
            演示词法分析器();
            
            // 验证数字测试输出
            const 数字输出 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('一二三 五六七'));
            expect(数字输出).toBeTruthy();
        });
    });

    describe('错误处理演示验证', () => {
        test('ASCII字符错误演示', () => {
            演示词法分析器();
            
            // 查找ASCII错误相关的输出
            const ascii错误输出 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('ASCII字符已禁用'));
            expect(ascii错误输出).toBeTruthy();
        });

        test('阿拉伯数字错误演示', () => {
            演示词法分析器();
            
            // 查找数字错误相关的输出
            const 数字错误输出 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('阿拉伯数字已禁用'));
            expect(数字错误输出).toBeTruthy();
        });

        test('未闭合字符串错误演示', () => {
            演示词法分析器();
            
            // 查找字符串错误相关的输出
            const 字符串错误输出 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('未闭合'));
            expect(字符串错误输出).toBeTruthy();
        });
    });

    describe('模块导出测试', () => {
        test('演示函数正确导出', () => {
            const 演示模块 = require('../src/词法分析器演示');
            
            expect(typeof 演示模块.演示词法分析器).toBe('function');
        });
    });

    describe('独立运行测试', () => {
        test('演示文件可以独立运行', () => {
            const demoPath = path.join(__dirname, '../src/词法分析器演示.js');
            
            expect(() => {
                execSync(`node ${demoPath}`, { encoding: 'utf8' });
            }).not.toThrow();
        });

        test('独立运行输出包含预期内容', () => {
            const demoPath = path.join(__dirname, '../src/词法分析器演示.js');
            const output = execSync(`node ${demoPath}`, { encoding: 'utf8' });
            
            expect(output).toContain('骆言词法分析器');
            expect(output).toContain('JavaScript版本演示');
            expect(output).toContain('词法分析器转换完成');
        });
    });

    describe('测试用例数据完整性验证', () => {
        test('所有测试用例都有名称和代码', () => {
            // 这个测试通过检查演示函数的执行来间接验证测试用例的完整性
            let 成功计数 = 0;
            
            // 重新实现一个简单的验证逻辑
            const 演示函数代码 = 演示词法分析器.toString();
            
            // 验证测试用例结构
            expect(演示函数代码).toContain('测试用例');
            expect(演示函数代码).toContain('名称');
            expect(演示函数代码).toContain('代码');
            expect(演示函数代码).toContain('错误用例');
            
            演示词法分析器();
            
            // 验证至少有一定数量的输出，表明测试用例被执行
            expect(consoleSpy.mock.calls.length).toBeGreaterThan(20);
        });
    });

    describe('输出格式验证', () => {
        test('词元输出格式正确', () => {
            演示词法分析器();
            
            // 查找词元列表输出
            const 词元列表输出 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('词元列表:'));
            expect(词元列表输出).toBeTruthy();
            
            // 查找位置信息格式 [行号:列号]
            const 位置格式输出 = consoleSpy.mock.calls.find(call => 
                call[0] && /\[\d+:\d+\]/.test(call[0]));
            expect(位置格式输出).toBeTruthy();
        });

        test('错误信息格式正确', () => {
            演示词法分析器();
            
            // 查找预期错误输出
            const 预期错误输出 = consoleSpy.mock.calls.filter(call => 
                call[0] && call[0].includes('✅ 预期错误:'));
            expect(预期错误输出.length).toBeGreaterThan(0);
        });
    });
});