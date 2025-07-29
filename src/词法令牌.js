/**
 * 骆言词法分析器 - 令牌类型定义 (JavaScript版本)
 * 
 * Author: Alpha, 主要工作代理专员
 */

// 导入抽象语法树模块
const { 验证标识符 } = require('./抽象语法树');

/**
 * 位置信息类
 */
class 位置 {
    constructor(行号, 列号, 文件名) {
        if (typeof 行号 !== 'number' || 行号 < 1) {
            throw new Error('行号必须是大于0的数字');
        }
        if (typeof 列号 !== 'number' || 列号 < 1) {
            throw new Error('列号必须是大于0的数字');
        }
        
        this.行号 = 行号;
        this.列号 = 列号;
        this.文件名 = 文件名 || '';
        Object.freeze(this);
    }

    toString() {
        return `位置{行号: ${this.行号}, 列号: ${this.列号}, 文件名: "${this.文件名}"}`;
    }

    equals(other) {
        return other instanceof 位置 &&
               this.行号 === other.行号 &&
               this.列号 === other.列号 &&
               this.文件名 === other.文件名;
    }
}

/**
 * 词法分析错误类
 */
class 词法错误 extends Error {
    constructor(消息, 位置) {
        super(消息);
        this.name = '词法错误';
        this.位置 = 位置;
    }

    toString() {
        return `${this.name}: ${this.message} at ${this.位置}`;
    }
}

/**
 * 词元类型枚举 - 所有令牌类型
 */
const 词元类型 = Object.freeze({
    // ========== 字面量类型 ==========
    整数令牌: 'IntToken',
    浮点令牌: 'FloatToken', 
    中文数字令牌: 'ChineseNumberToken',
    字符串令牌: 'StringToken',
    布尔令牌: 'BoolToken',

    // ========== 标识符类型 ==========
    引用标识符令牌: 'QuotedIdentifierToken',
    特殊标识符令牌: 'IdentifierTokenSpecial',

    // ========== 核心语言关键字 ==========
    让关键字: 'LetKeyword',     // 让 - let
    递归关键字: 'RecKeyword',   // 递归 - rec
    在关键字: 'InKeyword',      // 在 - in
    函数关键字: 'FunKeyword',   // 函数 - fun
    参数关键字: 'ParamKeyword', // 参数 - param

    // ========== 控制流关键字 ==========
    如果关键字: 'IfKeyword',     // 如果 - if
    那么关键字: 'ThenKeyword',   // 那么 - then
    否则关键字: 'ElseKeyword',   // 否则 - else
    匹配关键字: 'MatchKeyword',  // 匹配 - match
    与关键字: 'WithKeyword',     // 与 - with
    其他关键字: 'OtherKeyword',  // 其他 - other/wildcard

    // ========== 类型系统关键字 ==========
    类型关键字: 'TypeKeyword',    // 类型 - type
    私有关键字: 'PrivateKeyword', // 私有 - private
    真关键字: 'TrueKeyword',      // 真 - true
    假关键字: 'FalseKeyword',     // 假 - false
    并且关键字: 'AndKeyword',     // 并且 - and
    或者关键字: 'OrKeyword',      // 或者 - or
    非关键字: 'NotKeyword',       // 非 - not

    // ========== 语义类型系统关键字 ==========
    作为关键字: 'AsKeyword',           // 作为 - as
    组合关键字: 'CombineKeyword',      // 组合 - combine
    以及关键字: 'WithOpKeyword',       // 以及 - with_op
    当关键字: 'WhenKeyword',           // 当 - when

    // ========== 错误恢复关键字 ==========
    否则返回关键字: 'OrElseKeyword',      // 否则返回 - or_else
    默认为关键字: 'WithDefaultKeyword',   // 默认为 - with_default

    // ========== 异常处理关键字 ==========
    异常关键字: 'ExceptionKeyword',  // 异常 - exception
    抛出关键字: 'RaiseKeyword',      // 抛出 - raise
    尝试关键字: 'TryKeyword',        // 尝试 - try
    捕获关键字: 'CatchKeyword',      // 捕获 - catch/with
    最终关键字: 'FinallyKeyword',    // 最终 - finally

    // ========== 标点符号 ==========
    左括号: 'LeftParen',        // （
    右括号: 'RightParen',       // ）
    左方括号: 'LeftBracket',    // 【
    右方括号: 'RightBracket',   // 】
    左大括号: 'LeftBrace',      // 『
    右大括号: 'RightBrace',     // 』
    逗号: 'Comma',              // ，
    分号: 'Semicolon',          // ；
    冒号: 'Colon',              // ：
    管道符: 'Pipe',             // ｜
    箭头: 'Arrow',              // →
    等号: 'Equal',              // ＝
    
    // ========== 特殊令牌 ==========
    换行符: 'Newline',
    文件结束: 'EOF'  
});

/**
 * 词元基类
 */  
class 词元 {
    constructor(类型, 值, 位置) {
        if (!Object.values(词元类型).includes(类型)) {
            throw new Error(`无效的词元类型: ${类型}`);
        }
        
        this.类型 = 类型;
        this.值 = 值;
        this.位置 = 位置;
        Object.freeze(this);
    }

    toString() {
        if (this.值 !== undefined && this.值 !== null) {
            return `${this.类型}(${this.值})`;
        }
        return this.类型;
    }

    equals(other) {
        return other instanceof 词元 &&
               this.类型 === other.类型 &&
               this.值 === other.值;
    }
}

/**
 * 带位置的词元类
 */
class 带位置词元 {
    constructor(词元实例, 位置实例) {
        if (!(词元实例 instanceof 词元)) {
            throw new Error('第一个参数必须是词元实例');
        }
        if (!(位置实例 instanceof 位置)) {
            throw new Error('第二个参数必须是位置实例');
        }

        this.词元 = 词元实例;
        this.位置 = 位置实例;
        Object.freeze(this);
    }

    toString() {
        return `${this.词元} @ ${this.位置}`;
    }

    equals(other) {
        return other instanceof 带位置词元 &&
               this.词元.equals(other.词元) &&
               this.位置.equals(other.位置);
    }
}

/**
 * 词元工厂函数
 */
const 词元工厂 = {
    /**
     * 创建整数词元
     */
    创建整数词元(值, 位置) {
        if (typeof 值 !== 'number' || !Number.isInteger(值)) {
            throw new Error('整数词元的值必须是整数');
        }
        return new 词元(词元类型.整数令牌, 值, 位置);
    },

    /**
     * 创建浮点词元
     */
    创建浮点词元(值, 位置) {
        if (typeof 值 !== 'number') {
            throw new Error('浮点词元的值必须是数字');
        }
        return new 词元(词元类型.浮点令牌, 值, 位置);
    },

    /**
     * 创建中文数字词元
     */
    创建中文数字词元(值, 位置) {
        if (typeof 值 !== 'string' || 值.trim() === '') {
            throw new Error('中文数字词元的值必须是非空字符串');
        }
        return new 词元(词元类型.中文数字令牌, 值, 位置);
    },

    /**
     * 创建字符串词元
     */
    创建字符串词元(值, 位置) {
        if (typeof 值 !== 'string') {
            throw new Error('字符串词元的值必须是字符串');
        }
        return new 词元(词元类型.字符串令牌, 值, 位置);
    },

    /**
     * 创建布尔词元
     */
    创建布尔词元(值, 位置) {
        if (typeof 值 !== 'boolean') {
            throw new Error('布尔词元的值必须是布尔值');
        }
        return new 词元(词元类型.布尔令牌, 值, 位置);
    },

    /**
     * 创建引用标识符词元
     */
    创建引用标识符词元(值, 位置) {
        if (typeof 值 !== 'string' || 值.trim() === '') {
            throw new Error('引用标识符的值必须是非空字符串');
        }
        // 使用抽象语法树的验证函数
        验证标识符(值);
        return new 词元(词元类型.引用标识符令牌, 值, 位置);
    },

    /**
     * 创建关键字词元
     */
    创建关键字词元(类型, 位置) {
        if (!Object.values(词元类型).includes(类型)) {
            throw new Error(`无效的关键字类型: ${类型}`);
        }
        return new 词元(类型, null, 位置);
    },

    /**
     * 创建标点符号词元
     */
    创建标点符号词元(类型, 位置) {
        const 标点符号类型 = [
            词元类型.左括号, 词元类型.右括号, 词元类型.左方括号, 词元类型.右方括号,
            词元类型.左大括号, 词元类型.右大括号, 词元类型.逗号, 词元类型.分号,
            词元类型.冒号, 词元类型.管道符, 词元类型.箭头, 词元类型.等号
        ];
        
        if (!标点符号类型.includes(类型)) {
            throw new Error(`无效的标点符号类型: ${类型}`);
        }
        return new 词元(类型, null, 位置);
    },

    /**
     * 创建特殊词元
     */
    创建特殊词元(类型, 位置) {
        const 特殊类型 = [词元类型.换行符, 词元类型.文件结束];
        if (!特殊类型.includes(类型)) {
            throw new Error(`无效的特殊词元类型: ${类型}`);
        }
        return new 词元(类型, null, 位置);
    }
};

// 导出所有类和工厂函数
module.exports = {
    位置,
    词法错误,
    词元类型,
    词元,
    带位置词元,
    词元工厂
};