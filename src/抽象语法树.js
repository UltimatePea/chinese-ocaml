/**
 * 骆言抽象语法树 - Chinese Programming Language AST
 * 从OCaml转换为中文JavaScript
 * Author: Alpha, 主要工作代理专员
 */

/**
 * 古典诗词相关类型
 */

// 诗词形式枚举
const 诗词形式 = Object.freeze({
  四言诗: 'FourCharPoetry',
  五言诗: 'FiveCharPoetry', 
  七言诗: 'SevenCharPoetry',
  骈体文: 'ParallelProse',
  律诗: 'RegulatedVerse',
  绝句: 'Quatrain',
  对联: 'Couplet'
});

// 声调类型枚举
const 声调类型 = Object.freeze({
  平声: 'LevelTone',
  仄声: 'FallingTone', 
  上声: 'RisingTone',
  去声: 'DepartingTone',
  入声: 'EnteringTone'
});

// 声调约束枚举
const 声调约束 = Object.freeze({
  平仄交替: 'AlternatingTones',
  平仄对仗: 'ParallelTones',
  特定平仄模式: 'SpecificPattern'
});

/**
 * 韵律信息类
 */
class 韵律信息 {
  constructor(韵部, 韵脚位置, 韵式) {
    this.韵部 = 韵部;
    this.韵脚位置 = 韵脚位置;
    this.韵式 = 韵式;
  }

  toString() {
    return `韵律信息{韵部: ${this.韵部}, 韵脚位置: ${this.韵脚位置}, 韵式: ${this.韵式}}`;
  }

  equals(other) {
    return other instanceof 韵律信息 &&
           this.韵部 === other.韵部 &&
           this.韵脚位置 === other.韵脚位置 &&
           this.韵式 === other.韵式;
  }
}

/**
 * 平仄模式类
 */
class 平仄模式 {
  constructor(平仄序列, 平仄约束列表) {
    this.平仄序列 = 平仄序列 || [];
    this.平仄约束列表 = 平仄约束列表 || [];
  }

  toString() {
    return `平仄模式{平仄序列: [${this.平仄序列.join(', ')}], 约束: [${this.平仄约束列表.join(', ')}]}`;
  }

  equals(other) {
    return other instanceof 平仄模式 &&
           JSON.stringify(this.平仄序列) === JSON.stringify(other.平仄序列) &&
           JSON.stringify(this.平仄约束列表) === JSON.stringify(other.平仄约束列表);
  }
}

/**
 * 声调约束类
 */
class 特定平仄模式约束 {
  constructor(平仄模式列表) {
    this.类型 = 声调约束.特定平仄模式;
    this.平仄模式列表 = 平仄模式列表;
  }
}

/**
 * 韵律约束类
 */
class 韵律约束 {
  constructor(字符数, 音节模式 = null, 停顿位置 = null) {
    this.字符数 = 字符数;
    this.音节模式 = 音节模式;
    this.停顿位置 = 停顿位置;
  }

  toString() {
    return `韵律约束{字符数: ${this.字符数}, 音节模式: ${this.音节模式}, 停顿位置: ${this.停顿位置}}`;
  }
}

/**
 * 创建韵律信息的工厂函数
 */
function 创建韵律信息(韵部, 韵脚位置, 韵式) {
  return new 韵律信息(韵部, 韵脚位置, 韵式);
}

/**
 * 创建平仄模式的工厂函数  
 */
function 创建平仄模式(平仄序列, 平仄约束列表) {
  return new 平仄模式(平仄序列, 平仄约束列表);
}

/**
 * 创建韵律约束的工厂函数
 */
function 创建韵律约束(字符数, 音节模式, 停顿位置) {
  return new 韵律约束(字符数, 音节模式, 停顿位置);
}

/**
 * 基础类型枚举
 */
const 基础类型 = Object.freeze({
  整数: 'IntType',
  浮点数: 'FloatType',
  字符串: 'StringType',
  布尔值: 'BoolType',
  单元类型: 'UnitType'
});

/**
 * 二元运算符枚举
 */
const 二元运算符 = Object.freeze({
  加法: 'Add',
  减法: 'Sub', 
  乘法: 'Mul',
  除法: 'Div',
  取模: 'Mod',
  字符串连接: 'Concat',
  等于: 'Eq',
  不等于: 'Neq',
  小于: 'Lt',
  小于等于: 'Le',
  大于: 'Gt',
  大于等于: 'Ge',
  逻辑与: 'And',
  逻辑或: 'Or'
});

/**
 * 一元运算符枚举
 */
const 一元运算符 = Object.freeze({
  负号: 'Neg',
  逻辑非: 'Not'
});

/**
 * 字面量类
 */
class 字面量 {
  constructor(类型, 值) {
    this.类型 = 类型;
    this.值 = 值;
  }

  static 整数字面量(值) {
    return new 字面量('IntLit', 值);
  }

  static 浮点数字面量(值) {
    return new 字面量('FloatLit', 值);
  }

  static 字符串字面量(值) {
    return new 字面量('StringLit', 值);
  }

  static 布尔字面量(值) {
    return new 字面量('BoolLit', 值);
  }

  static 单元字面量() {
    return new 字面量('UnitLit', null);
  }

  toString() {
    return `${this.类型}(${this.值})`;
  }

  equals(other) {
    return other instanceof 字面量 &&
           this.类型 === other.类型 &&
           this.值 === other.值;
  }
}

/**
 * 模式匹配类
 */
class 模式 {
  constructor(类型, 内容) {
    this.类型 = 类型;
    this.内容 = 内容;
  }

  static 通配符模式() {
    return new 模式('WildcardPattern', null);
  }

  static 标识符模式(标识符) {
    return new 模式('IdentifierPattern', 标识符);
  }

  static 字面量模式(字面量) {
    return new 模式('LiteralPattern', 字面量);
  }

  toString() {
    if (this.内容 === null) {
      return this.类型;
    }
    return `${this.类型}(${this.内容})`;
  }
}

/**
 * 标识符验证函数
 */
function 验证标识符(标识符) {
  if (typeof 标识符 !== 'string') {
    throw new Error('标识符必须是字符串类型');
  }
  if (标识符.length === 0) {
    throw new Error('标识符不能为空');
  }
  return 标识符;
}

/**
 * 创建字面量的工厂函数
 */
function 创建整数字面量(值) {
  return 字面量.整数字面量(值);
}

function 创建浮点数字面量(值) {
  return 字面量.浮点数字面量(值);
}

function 创建字符串字面量(值) {
  return 字面量.字符串字面量(值);
}

function 创建布尔字面量(值) {
  return 字面量.布尔字面量(值);
}

function 创建单元字面量() {
  return 字面量.单元字面量();
}

// 导出所有类型和函数
module.exports = {
  // 诗词相关
  诗词形式,
  声调类型,
  声调约束,
  韵律信息,
  平仄模式,
  特定平仄模式约束,
  韵律约束,
  创建韵律信息,
  创建平仄模式,
  创建韵律约束,
  
  // 基础类型
  基础类型,
  二元运算符,
  一元运算符,
  字面量,
  模式,
  
  // 工具函数
  验证标识符,
  创建整数字面量,
  创建浮点数字面量,
  创建字符串字面量,
  创建布尔字面量,
  创建单元字面量
};