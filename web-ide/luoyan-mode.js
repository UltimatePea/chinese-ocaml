/**
 * 骆言 (LuoYan) 语言 CodeMirror 语法高亮模式
 * 支持中文关键字、引用标识符、古雅体语法等特性
 */

(function(mod) {
    if (typeof exports == "object" && typeof module == "object") // CommonJS
        mod(require("../../lib/codemirror"));
    else if (typeof define == "function" && define.amd) // AMD
        define(["../../lib/codemirror"], mod);
    else // Plain browser env
        mod(CodeMirror);
})(function(CodeMirror) {
    "use strict";

    // 骆言语言关键字
    const keywords = [
        // 基础关键字
        '设', '为', '夫', '者', '受', '焉', '算法', '乃', '打印',
        '观', '之', '性', '若', '则', '答', '余者', '观毕', '也',
        
        // 条件和循环
        '如果', '否则', '当', '循环', '直到', '对于', '在',
        
        // 数据类型
        '整数', '浮点', '字符串', '布尔', '列表', '记录',
        
        // 模式匹配
        '匹配', '模式', '守卫',
        
        // 函数相关
        '函数', '返回', '递归', '尾递归',
        
        // 类型相关
        '类型', '变体', '构造子', '约束',
        
        // 模块相关
        '模块', '导入', '导出', '开放',
        
        // 异常处理
        '尝试', '捕获', '抛出', '最终',
        
        // 并发
        '并行', '等待', '异步',
        
        // OCaml风格关键字
        'let', 'in', 'if', 'then', 'else', 'match', 'with', 'when',
        'function', 'fun', 'rec', 'and', 'type', 'of', 'module',
        'open', 'include', 'val', 'external', 'mutable', 'ref',
        'try', 'exception', 'raise', 'failwith', 'assert',
        
        // 内置函数和常量
        'true', 'false', 'unit', 'Some', 'None', 'Ok', 'Error'
    ];

    // 操作符
    const operators = [
        '+', '-', '*', '/', 'mod', '=', '<>', '<', '>', '<=', '>=',
        '&&', '||', 'not', '&', '|', '^', '<<', '>>', 
        '::', '@', '^', '!', ':=', '->', '<-', ';;',
        '加', '减', '乘', '除', '等于', '不等于', '小于', '大于',
        '小于等于', '大于等于', '且', '或', '非'
    ];

    // 内置类型
    const builtinTypes = [
        'int', 'float', 'string', 'bool', 'char', 'unit',
        'list', 'array', 'option', 'result', 'ref',
        '整型', '浮点型', '字符串型', '布尔型', '字符型', '单元型',
        '列表型', '数组型', '选项型', '结果型', '引用型'
    ];

    // 标准库函数
    const builtinFunctions = [
        'print', 'print_endline', 'print_int', 'print_float',
        'read_line', 'read_int', 'read_float',
        'List.map', 'List.fold_left', 'List.fold_right', 'List.iter',
        'String.length', 'String.concat', 'String.sub',
        'Array.length', 'Array.get', 'Array.set', 'Array.make',
        'Printf.printf', 'Printf.sprintf',
        '打印', '打印行', '打印整数', '打印浮点',
        '读取行', '读取整数', '读取浮点',
        '映射', '左折叠', '右折叠', '迭代',
        '长度', '连接', '子串', '获取', '设置', '创建'
    ];

    // 创建关键字正则表达式
    function makeKeywordRegex(words) {
        return new RegExp("^(?:" + words.map(word => 
            word.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
        ).join("|") + ")$");
    }

    const keywordRegex = makeKeywordRegex(keywords);
    const operatorRegex = makeKeywordRegex(operators);
    const builtinTypeRegex = makeKeywordRegex(builtinTypes);
    const builtinFunctionRegex = makeKeywordRegex(builtinFunctions);

    // 定义语法高亮模式
    CodeMirror.defineMode("luoyan", function(config, parserConfig) {
        return {
            startState: function() {
                return {
                    inComment: false,
                    inString: false,
                    inQuotedIdentifier: false,
                    stringDelimiter: null,
                    commentDepth: 0
                };
            },

            token: function(stream, state) {
                // 处理空白字符
                if (stream.eatSpace()) return null;

                // 处理注释 「：...：」
                if (stream.match(/「：/)) {
                    state.inComment = true;
                    state.commentDepth = 1;
                    return "comment";
                }

                if (state.inComment) {
                    if (stream.match(/「：/)) {
                        state.commentDepth++;
                        return "comment";
                    }
                    if (stream.match(/：」/)) {
                        state.commentDepth--;
                        if (state.commentDepth === 0) {
                            state.inComment = false;
                        }
                        return "comment";
                    }
                    stream.next();
                    return "comment";
                }

                // 处理字符串 『...』
                if (stream.match(/『/)) {
                    state.inString = true;
                    state.stringDelimiter = '』';
                    return "string";
                }

                // 处理传统字符串 "..."
                if (stream.match(/"/)) {
                    state.inString = true;
                    state.stringDelimiter = '"';
                    return "string";
                }

                if (state.inString) {
                    if (stream.match(new RegExp(state.stringDelimiter))) {
                        state.inString = false;
                        state.stringDelimiter = null;
                        return "string";
                    }
                    if (stream.match(/\\./)) {
                        return "string";
                    }
                    stream.next();
                    return "string";
                }

                // 处理引用标识符 「...」
                if (stream.match(/「/)) {
                    state.inQuotedIdentifier = true;
                    return "variable-2";
                }

                if (state.inQuotedIdentifier) {
                    if (stream.match(/」/)) {
                        state.inQuotedIdentifier = false;
                        return "variable-2";
                    }
                    stream.next();
                    return "variable-2";
                }

                // 处理数字
                if (stream.match(/^[0-9]+\.?[0-9]*([eE][+-]?[0-9]+)?/)) {
                    return "number";
                }

                // 处理字符字面量
                if (stream.match(/^'([^'\\]|\\.)*'/)) {
                    return "string";
                }

                // 处理标识符和关键字
                if (stream.match(/^[a-zA-Z_\u4e00-\u9fff][a-zA-Z0-9_\u4e00-\u9fff]*/)) {
                    const word = stream.current();
                    
                    if (keywordRegex.test(word)) {
                        return "keyword";
                    }
                    if (builtinTypeRegex.test(word)) {
                        return "type";
                    }
                    if (builtinFunctionRegex.test(word)) {
                        return "builtin";
                    }
                    
                    // 检查是否是构造子（首字母大写）
                    if (/^[A-Z\u4e00-\u9fff]/.test(word)) {
                        return "atom";
                    }
                    
                    return "variable";
                }

                // 处理操作符
                if (stream.match(/^(<->|->|<-|<=|>=|<>|::|;;|:=)/)) {
                    return "operator";
                }

                // 处理单字符操作符
                if (stream.match(/^[+\-*/%=<>!&|^~@]/)) {
                    return "operator";
                }

                // 处理中文操作符
                if (stream.match(/^(加|减|乘|除|等于|不等于|小于|大于|小于等于|大于等于|且|或|非)/)) {
                    return "operator";
                }

                // 处理标点符号
                if (stream.match(/^[()[\]{},.;:|]/)) {
                    return "punctuation";
                }

                // 处理中文标点
                if (stream.match(/^[，。；：！？（）【】〈〉「」『』]/)) {
                    return "punctuation";
                }

                // 默认情况
                stream.next();
                return null;
            },

            indent: function(state, textAfter) {
                return CodeMirror.Pass;
            },

            electricChars: "}",
            blockCommentStart: "「：",
            blockCommentEnd: "：」",
            lineComment: null,
            fold: "brace"
        };
    });

    // 注册语言模式
    CodeMirror.defineMIME("text/x-luoyan", "luoyan");
    
    // 为 .ly 文件扩展名注册模式
    CodeMirror.modeURL = CodeMirror.modeURL || {};
    CodeMirror.modeURL["ly"] = "luoyan";

    // 添加语法高亮的辅助函数
    CodeMirror.registerHelper("wordChars", "luoyan", /[\w\u4e00-\u9fff]/);
    
    // 添加括号匹配
    CodeMirror.registerHelper("bracket", "luoyan", function(stream) {
        const brackets = {
            '(': ')',
            '[': ']',
            '{': '}',
            '「': '」',
            '『': '』',
            '（': '）',
            '【': '】',
            '〈': '〉'
        };
        
        return brackets;
    });

    // 添加代码折叠支持
    CodeMirror.registerHelper("fold", "luoyan", function(cm, start) {
        function findOpening(cm, where, pattern, end) {
            for (let line = where.line, ch = where.ch, first = cm.firstLine(); line >= first; --line, ch = -1) {
                let text = cm.getLine(line);
                let pos = ch < 0 ? text.search(pattern) : text.lastIndexOf(pattern, ch);
                if (pos >= 0) return CodeMirror.Pos(line, pos);
            }
        }

        function findClosing(cm, where, openText, closeText) {
            for (let line = where.line, ch = where.ch, last = cm.lastLine(); line <= last; ++line, ch = 0) {
                let text = cm.getLine(line);
                let closePos = text.indexOf(closeText, ch);
                if (closePos >= 0) {
                    return CodeMirror.Pos(line, closePos + closeText.length);
                }
            }
        }

        let line = cm.getLine(start.line);
        let openPatterns = [
            { open: '算法乃', close: '也' },
            { open: '观.*性', close: '观毕' },
            { open: '函数', close: 'end' },
            { open: '{', close: '}' },
            { open: '(', close: ')' },
            { open: '[', close: ']' }
        ];

        for (let pattern of openPatterns) {
            let openPos = line.indexOf(pattern.open);
            if (openPos >= 0 && openPos <= start.ch) {
                let closePos = findClosing(cm, start, pattern.open, pattern.close);
                if (closePos) {
                    return {
                        from: CodeMirror.Pos(start.line, openPos + pattern.open.length),
                        to: closePos
                    };
                }
            }
        }
    });

    // 导出模式
    if (typeof module !== 'undefined' && module.exports) {
        module.exports = CodeMirror;
    }
});

// 如果在浏览器环境中，自动注册模式
if (typeof window !== 'undefined' && window.CodeMirror) {
    // 模式已经通过IIFE注册
    console.log('骆言语法高亮模式已加载');
}