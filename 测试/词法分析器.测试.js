/**
 * 词法分析器测试套件
 * 
 * Author: Alpha, 主要工作代理专员
 */

const { 词法分析器, 中文关键字映射, 中文标点符号映射 } = require('../src/词法分析器');
const { 位置, 词法错误, 词元类型, 词元, 带位置词元, 词元工厂 } = require('../src/词法令牌');

describe('词法分析器模块测试', () => {
    describe('位置信息测试', () => {
        test('位置类创建和比较', () => {
            const 位置1 = new 位置(1, 1, 'test.ly');
            const 位置2 = new 位置(1, 1, 'test.ly');
            const 位置3 = new 位置(2, 1, 'test.ly');

            expect(位置1.equals(位置2)).toBe(true);
            expect(位置1.equals(位置3)).toBe(false);
            expect(位置1.toString()).toBe('位置{行号: 1, 列号: 1, 文件名: "test.ly"}');
        });

        test('位置类参数验证', () => {
            expect(() => new 位置(0, 1, 'test.ly')).toThrow('行号必须是大于0的数字');
            expect(() => new 位置(1, 0, 'test.ly')).toThrow('列号必须是大于0的数字');
            expect(() => new 位置('1', 1, 'test.ly')).toThrow('行号必须是大于0的数字');
        });
    });

    describe('词法错误测试', () => {
        test('词法错误创建和格式化', () => {
            const 位置实例 = new 位置(1, 5, 'test.ly');
            const 错误 = new 词法错误('测试错误', 位置实例);

            expect(错误.name).toBe('词法错误');
            expect(错误.message).toBe('测试错误');
            expect(错误.位置).toBe(位置实例);
            expect(错误.toString()).toContain('词法错误: 测试错误');
        });
    });

    describe('词元类型和工厂测试', () => {
        test('词元类型枚举完整性', () => {
            expect(词元类型.整数令牌).toBe('IntToken');
            expect(词元类型.让关键字).toBe('LetKeyword');
            expect(词元类型.左括号).toBe('LeftParen');
            expect(词元类型.文件结束).toBe('EOF');
        });

        test('词元工厂 - 整数词元', () => {
            const 位置实例 = new 位置(1, 1, 'test.ly');
            const 词元实例 = 词元工厂.创建整数词元(42, 位置实例);

            expect(词元实例.类型).toBe(词元类型.整数令牌);
            expect(词元实例.值).toBe(42);
            expect(词元实例.toString()).toBe('IntToken(42)');
        });

        test('词元工厂 - 字符串词元', () => {
            const 位置实例 = new 位置(1, 1, 'test.ly');
            const 词元实例 = 词元工厂.创建字符串词元('测试', 位置实例);

            expect(词元实例.类型).toBe(词元类型.字符串令牌);
            expect(词元实例.值).toBe('测试');
            expect(词元实例.toString()).toBe('StringToken(测试)');
        });

        test('词元工厂 - 关键字词元', () => {
            const 位置实例 = new 位置(1, 1, 'test.ly');
            const 词元实例 = 词元工厂.创建关键字词元(词元类型.让关键字, 位置实例);

            expect(词元实例.类型).toBe(词元类型.让关键字);
            expect(词元实例.值).toBe(null);
            expect(词元实例.toString()).toBe('LetKeyword');
        });

        test('词元工厂参数验证', () => {
            const 位置实例 = new 位置(1, 1, 'test.ly');
            expect(() => 词元工厂.创建整数词元('not a number', 位置实例)).toThrow();
            expect(() => 词元工厂.创建字符串词元(123, 位置实例)).toThrow();
        });
    });

    describe('词法分析器核心功能测试', () => {
        test('基本字符识别', () => {
            const 分析器 = new 词法分析器('');
            
            expect(分析器.是否为中文字符('中')).toBe(true);
            expect(分析器.是否为中文字符('a')).toBe(false);
            expect(分析器.是否为阿拉伯数字('5')).toBe(true);
            expect(分析器.是否为阿拉伯数字('中')).toBe(false);
            expect(分析器.是否为中文数字('五')).toBe(true);
            expect(分析器.是否为中文数字('a')).toBe(false);
        });

        test('空输入处理', () => {
            const 分析器 = new 词法分析器('');
            const 词元列表 = 分析器.词法分析();

            expect(词元列表).toHaveLength(1);
            expect(词元列表[0].词元.类型).toBe(词元类型.文件结束);
        });

        test('单个换行符', () => {
            const 分析器 = new 词法分析器('\n');
            const 词元列表 = 分析器.词法分析();

            expect(词元列表).toHaveLength(2);
            expect(词元列表[0].词元.类型).toBe(词元类型.换行符);
            expect(词元列表[1].词元.类型).toBe(词元类型.文件结束);
        });

        test('中文关键字识别', () => {
            const 分析器 = new 词法分析器('让 如果 那么');
            const 词元列表 = 分析器.词法分析();

            expect(词元列表).toHaveLength(4); // 三个关键字 + EOF
            expect(词元列表[0].词元.类型).toBe(词元类型.让关键字);
            expect(词元列表[1].词元.类型).toBe(词元类型.如果关键字);
            expect(词元列表[2].词元.类型).toBe(词元类型.那么关键字);
            expect(词元列表[3].词元.类型).toBe(词元类型.文件结束);
        });

        test('中文标点符号识别', () => {
            const 分析器 = new 词法分析器('（）【】，；');
            const 词元列表 = 分析器.词法分析();

            expect(词元列表).toHaveLength(7); // 六个标点 + EOF
            expect(词元列表[0].词元.类型).toBe(词元类型.左括号);
            expect(词元列表[1].词元.类型).toBe(词元类型.右括号);
            expect(词元列表[2].词元.类型).toBe(词元类型.左方括号);
            expect(词元列表[3].词元.类型).toBe(词元类型.右方括号);
            expect(词元列表[4].词元.类型).toBe(词元类型.逗号);
            expect(词元列表[5].词元.类型).toBe(词元类型.分号);
        });

        test('字符串字面量识别', () => {
            const 分析器 = new 词法分析器('『测试字符串』');
            const 词元列表 = 分析器.词法分析();

            expect(词元列表).toHaveLength(2); // 字符串 + EOF
            expect(词元列表[0].词元.类型).toBe(词元类型.字符串令牌);
            expect(词元列表[0].词元.值).toBe('测试字符串');
        });

        test('引用标识符识别', () => {
            const 分析器 = new 词法分析器('「变量名」');
            const 词元列表 = 分析器.词法分析();

            expect(词元列表).toHaveLength(2); // 标识符 + EOF
            expect(词元列表[0].词元.类型).toBe(词元类型.引用标识符令牌);
            expect(词元列表[0].词元.值).toBe('变量名');
        });

        test('中文数字识别', () => {
            const 分析器 = new 词法分析器('一二三');
            const 词元列表 = 分析器.词法分析();

            expect(词元列表).toHaveLength(2); // 中文数字 + EOF
            expect(词元列表[0].词元.类型).toBe(词元类型.中文数字令牌);
            expect(词元列表[0].词元.值).toBe('一二三');
        });

        test('复合表达式识别', () => {
            const 分析器 = new 词法分析器('让「变量」＝『值』');
            const 词元列表 = 分析器.词法分析();

            expect(词元列表).toHaveLength(5); // 让 + 标识符 + 等号 + 字符串 + EOF
            expect(词元列表[0].词元.类型).toBe(词元类型.让关键字);
            expect(词元列表[1].词元.类型).toBe(词元类型.引用标识符令牌);
            expect(词元列表[1].词元.值).toBe('变量');
            expect(词元列表[2].词元.类型).toBe(词元类型.等号);
            expect(词元列表[3].词元.类型).toBe(词元类型.字符串令牌);
            expect(词元列表[3].词元.值).toBe('值');
        });
    });

    describe('错误处理测试', () => {
        test('阿拉伯数字禁用', () => {
            const 分析器 = new 词法分析器('123');
            expect(() => 分析器.词法分析()).toThrow(词法错误);
            expect(() => 分析器.词法分析()).toThrow('阿拉伯数字已禁用');
        });

        test('ASCII字符禁用', () => {
            const 分析器 = new 词法分析器('hello');
            expect(() => 分析器.词法分析()).toThrow(词法错误);
            expect(() => 分析器.词法分析()).toThrow('ASCII字符已禁用');
        });

        test('ASCII标点符号禁用', () => {
            const 分析器 = new 词法分析器('()[]{}');
            expect(() => 分析器.词法分析()).toThrow(词法错误);
            expect(() => 分析器.词法分析()).toThrow('ASCII字符已禁用');
        });

        test('未闭合的字符串字面量', () => {
            expect(() => new 词法分析器('『未闭合的字符串').词法分析()).toThrow(词法错误);
            expect(() => new 词法分析器('『未闭合的字符串').词法分析()).toThrow('未闭合的字符串字面量');
        });

        test('未闭合的引用标识符', () => {
            expect(() => new 词法分析器('「未闭合的标识符').词法分析()).toThrow(词法错误);
            expect(() => new 词法分析器('「未闭合的标识符').词法分析()).toThrow('未闭合的引用标识符');
        });

        test('空的引用标识符', () => {
            expect(() => new 词法分析器('「」').词法分析()).toThrow(词法错误);
            expect(() => new 词法分析器('「」').词法分析()).toThrow('引用标识符不能为空');
        });

        test('字符串包含换行符', () => {
            expect(() => new 词法分析器('『包含\n换行的字符串』').词法分析()).toThrow(词法错误);
            expect(() => new 词法分析器('『包含\n换行的字符串』').词法分析()).toThrow('字符串字面量不能包含换行符');
        });
    });

    describe('静态方法测试', () => {
        test('查找关键字功能', () => {
            expect(词法分析器.查找关键字('让')).toBe(词元类型.让关键字);
            expect(词法分析器.查找关键字('如果')).toBe(词元类型.如果关键字);
            expect(词法分析器.查找关键字('不是关键字')).toBe(null);
        });
    });

    describe('映射表测试', () => {
        test('中文关键字映射完整性', () => {
            expect(中文关键字映射.get('让')).toBe(词元类型.让关键字);
            expect(中文关键字映射.get('函数')).toBe(词元类型.函数关键字);
            expect(中文关键字映射.get('如果')).toBe(词元类型.如果关键字);
            expect(中文关键字映射.has('不存在的关键字')).toBe(false);
        });

        test('中文标点符号映射完整性', () => {
            expect(中文标点符号映射.get('（')).toBe(词元类型.左括号);
            expect(中文标点符号映射.get('）')).toBe(词元类型.右括号);
            expect(中文标点符号映射.get('，')).toBe(词元类型.逗号);
            expect(中文标点符号映射.has('.')).toBe(false);
        });
    });

    describe('位置跟踪测试', () => {
        test('多行位置跟踪', () => {
            const 分析器 = new 词法分析器('让\n如果\n那么');
            const 词元列表 = 分析器.词法分析();

            // 检查位置信息
            expect(词元列表[0].位置.行号).toBe(1); // '让'
            expect(词元列表[0].位置.列号).toBe(1);
            
            expect(词元列表[1].位置.行号).toBe(1); // 第一个换行符
            expect(词元列表[1].位置.列号).toBe(2);
            
            expect(词元列表[2].位置.行号).toBe(2); // '如果'
            expect(词元列表[2].位置.列号).toBe(1);
        });

        test('列位置跟踪', () => {
            const 分析器 = new 词法分析器('让 如果 那么');
            const 词元列表 = 分析器.词法分析();

            expect(词元列表[0].位置.列号).toBe(1); // '让'
            expect(词元列表[1].位置.列号).toBe(3); // '如果'
            expect(词元列表[2].位置.列号).toBe(6); // '那么'
        });
    });
});