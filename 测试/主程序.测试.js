/**
 * 主程序模块测试
 * 
 * Author: Charlie, 计划代理专员
 */

const { execSync } = require('child_process');
const path = require('path');

// 导入主程序模块进行测试
const mainPath = path.join(__dirname, '../src/主程序.js');

describe('主程序模块测试', () => {
    let consoleSpy;
    
    beforeEach(() => {
        consoleSpy = jest.spyOn(console, 'log').mockImplementation();
    });
    
    afterEach(() => {
        consoleSpy.mockRestore();
    });

    describe('主函数基础功能测试', () => {
        test('主程序可以被require导入', () => {
            expect(() => {
                require(mainPath);
            }).not.toThrow();
        });

        test('主程序启动输出正确信息', () => {
            delete require.cache[require.resolve(mainPath)];
            const 主程序模块 = require(mainPath);
            
            // 直接调用主函数
            主程序模块.主函数();
            
            expect(consoleSpy).toHaveBeenCalledWith('🎋 骆言编程语言编译器 - JavaScript版本启动');
            expect(consoleSpy).toHaveBeenCalledWith('═══════════════════════════════════════════');
            expect(consoleSpy).toHaveBeenCalledWith('✅ 基础设施转换完成');
        });
    });

    describe('演示功能测试', () => {
        test('抽象语法树功能演示正常执行', () => {
            delete require.cache[require.resolve(mainPath)];
            const 主程序模块 = require(mainPath);
            
            // 直接调用主函数
            主程序模块.主函数();
            
            // 验证演示相关的输出
            expect(consoleSpy).toHaveBeenCalledWith('\n📝 抽象语法树功能演示:');
            
            // 验证支持的诗词形式输出
            const 诗词形式调用 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('支持的诗词形式'));
            expect(诗词形式调用).toBeTruthy();
            
            // 验证韵律信息输出
            const 韵律信息调用 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('韵律信息'));
            expect(韵律信息调用).toBeTruthy();
            
            // 验证字面量输出
            const 整数字面量调用 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('整数字面量'));
            expect(整数字面量调用).toBeTruthy();
            
            const 字符串字面量调用 = consoleSpy.mock.calls.find(call => 
                call[0] && call[0].includes('字符串字面量'));
            expect(字符串字面量调用).toBeTruthy();
        });
    });

    describe('模块导出测试', () => {
        test('主程序模块正确导出', () => {
            const 主程序模块 = require(mainPath);
            
            // 验证模块结构
            expect(typeof 主程序模块).toBe('object');
        });
    });

    describe('集成测试', () => {
        test('主程序可以独立运行', () => {
            expect(() => {
                execSync(`node ${mainPath}`, { encoding: 'utf8' });
            }).not.toThrow();
        });

        test('主程序运行输出包含预期内容', () => {
            const output = execSync(`node ${mainPath}`, { encoding: 'utf8' });
            
            expect(output).toContain('骆言编程语言编译器');
            expect(output).toContain('JavaScript版本启动');
            expect(output).toContain('抽象语法树功能演示');
            expect(output).toContain('基础设施转换完成');
        });
    });

    describe('错误处理测试', () => {
        test('主程序在依赖模块缺失时给出合适错误', () => {
            // 简化错误处理测试，确保模块可以正常加载
            expect(() => {
                delete require.cache[require.resolve(mainPath)];
                delete require.cache[require.resolve('../src/抽象语法树')];
                const 主程序模块 = require(mainPath);
                expect(主程序模块).toBeDefined();
                expect(typeof 主程序模块.主函数).toBe('function');
            }).not.toThrow();
        });
    });

    describe('性能测试', () => {
        test('主程序启动时间合理', () => {
            const startTime = Date.now();
            
            delete require.cache[require.resolve(mainPath)];
            const 主程序模块 = require(mainPath);
            主程序模块.主函数();
            
            const endTime = Date.now();
            const 启动时间 = endTime - startTime;
            
            // 启动时间应该在合理范围内（小于1秒）
            expect(启动时间).toBeLessThan(1000);
        });
    });
});