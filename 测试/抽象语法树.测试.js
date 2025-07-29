/**
 * 抽象语法树模块测试
 * 验证OCaml到中文JavaScript转换的正确性
 */

const {
  诗词形式,
  声调类型,
  韵律信息,
  平仄模式,
  基础类型,
  二元运算符,
  一元运算符,
  字面量,
  模式,
  创建韵律信息,
  创建整数字面量,
  创建字符串字面量,
  验证标识符
} = require('../src/抽象语法树');

describe('抽象语法树模块测试', () => {
  
  describe('诗词相关类型测试', () => {
    test('诗词形式枚举值正确', () => {
      expect(诗词形式.四言诗).toBe('FourCharPoetry');
      expect(诗词形式.五言诗).toBe('FiveCharPoetry');
      expect(诗词形式.七言诗).toBe('SevenCharPoetry');
      expect(诗词形式.对联).toBe('Couplet');
    });

    test('声调类型枚举值正确', () => {
      expect(声调类型.平声).toBe('LevelTone');
      expect(声调类型.仄声).toBe('FallingTone');
      expect(声调类型.上声).toBe('RisingTone');
      expect(声调类型.去声).toBe('DepartingTone');
      expect(声调类型.入声).toBe('EnteringTone');
    });

    test('韵律信息类创建和比较', () => {
      const 韵律1 = 创建韵律信息('平水韵', 2, 'AABA');
      const 韵律2 = 创建韵律信息('平水韵', 2, 'AABA');
      const 韵律3 = 创建韵律信息('词林正韵', 4, 'ABAB');

      expect(韵律1.韵部).toBe('平水韵');
      expect(韵律1.韵脚位置).toBe(2);
      expect(韵律1.韵式).toBe('AABA');
      
      expect(韵律1.equals(韵律2)).toBe(true);
      expect(韵律1.equals(韵律3)).toBe(false);
    });

    test('平仄模式类创建', () => {
      const 模式 = new 平仄模式([声调类型.平声, 声调类型.仄声], []);
      expect(模式.平仄序列).toEqual([声调类型.平声, 声调类型.仄声]);
      expect(模式.平仄约束列表).toEqual([]);
    });
  });

  describe('基础类型测试', () => {
    test('基础类型枚举值正确', () => {
      expect(基础类型.整数).toBe('IntType');
      expect(基础类型.浮点数).toBe('FloatType');
      expect(基础类型.字符串).toBe('StringType');
      expect(基础类型.布尔值).toBe('BoolType');
      expect(基础类型.单元类型).toBe('UnitType');
    });

    test('二元运算符枚举值正确', () => {
      expect(二元运算符.加法).toBe('Add');
      expect(二元运算符.减法).toBe('Sub');
      expect(二元运算符.乘法).toBe('Mul');
      expect(二元运算符.除法).toBe('Div');
      expect(二元运算符.等于).toBe('Eq');
      expect(二元运算符.逻辑与).toBe('And');
    });

    test('一元运算符枚举值正确', () => {
      expect(一元运算符.负号).toBe('Neg');
      expect(一元运算符.逻辑非).toBe('Not');
    });
  });

  describe('字面量类测试', () => {
    test('整数字面量创建', () => {
      const 整数字面量 = 创建整数字面量(42);
      expect(整数字面量.类型).toBe('IntLit');
      expect(整数字面量.值).toBe(42);
      expect(整数字面量.toString()).toBe('IntLit(42)');
    });

    test('字符串字面量创建', () => {
      const 字符串字面量 = 创建字符串字面量('骆言');
      expect(字符串字面量.类型).toBe('StringLit');
      expect(字符串字面量.值).toBe('骆言');
      expect(字符串字面量.toString()).toBe('StringLit(骆言)');
    });

    test('字面量相等比较', () => {
      const 字面量1 = 创建整数字面量(100);
      const 字面量2 = 创建整数字面量(100);
      const 字面量3 = 创建整数字面量(200);

      expect(字面量1.equals(字面量2)).toBe(true);
      expect(字面量1.equals(字面量3)).toBe(false);
    });

    test('布尔字面量创建', () => {
      const 真值 = 字面量.布尔字面量(true);
      const 假值 = 字面量.布尔字面量(false);
      
      expect(真值.值).toBe(true);
      expect(假值.值).toBe(false);
    });

    test('单元字面量创建', () => {
      const 单元 = 字面量.单元字面量();
      expect(单元.类型).toBe('UnitLit');
      expect(单元.值).toBe(null);
    });
  });

  describe('模式匹配测试', () => {
    test('通配符模式创建', () => {
      const 通配符 = 模式.通配符模式();
      expect(通配符.类型).toBe('WildcardPattern');
      expect(通配符.内容).toBe(null);
      expect(通配符.toString()).toBe('WildcardPattern');
    });

    test('标识符模式创建', () => {
      const 标识符模式 = 模式.标识符模式('变量名');
      expect(标识符模式.类型).toBe('IdentifierPattern');
      expect(标识符模式.内容).toBe('变量名');
      expect(标识符模式.toString()).toBe('IdentifierPattern(变量名)');
    });

    test('字面量模式创建', () => {
      const 整数 = 创建整数字面量(42);
      const 字面量模式 = 模式.字面量模式(整数);
      expect(字面量模式.类型).toBe('LiteralPattern');
      expect(字面量模式.内容).toBe(整数);
    });
  });

  describe('工具函数测试', () => {
    test('标识符验证 - 正常情况', () => {
      expect(验证标识符('有效标识符')).toBe('有效标识符');
      expect(验证标识符('variable_name')).toBe('variable_name');
    });

    test('标识符验证 - 异常情况', () => {
      expect(() => 验证标识符('')).toThrow('标识符不能为空');
      expect(() => 验证标识符(123)).toThrow('标识符必须是字符串类型');
      expect(() => 验证标识符(null)).toThrow('标识符必须是字符串类型');
    });
  });

  describe('枚举不变性测试', () => {
    test('诗词形式枚举不可修改', () => {
      expect(() => {
        诗词形式.新增类型 = 'NewType';
      }).toThrow();
    });

    test('基础类型枚举不可修改', () => {
      expect(() => {
        基础类型.新类型 = 'NewType';
      }).toThrow();
    });
  });
});