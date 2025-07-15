/**
 * 骆言编译器 - 浏览器端实现
 * 将骆言代码编译为C语言
 */

class LuoyanCompiler {
    constructor() {
        this.context = {
            nextVarId: 0,
            nextLabelId: 0,
            includes: ['luoyan_runtime.h'],
            globalVars: [],
            functions: []
        };
    }

    /**
     * 编译骆言代码到C语言
     */
    compileToC(luoyanCode) {
        try {
            // 简化的编译过程
            const ast = this.parseCode(luoyanCode);
            const cCode = this.generateCCode(ast);
            return cCode;
        } catch (error) {
            throw new Error(`编译错误: ${error.message}`);
        }
    }

    /**
     * 解析骆言代码（简化版）
     */
    parseCode(code) {
        // 简化的解析器，识别基本的骆言语法
        const lines = code.split('\n').map(line => line.trim()).filter(line => line);
        const ast = [];

        for (const line of lines) {
            if (line.startsWith('设「') && line.includes('」为')) {
                // 变量声明: 设「变量名」为 值
                const match = line.match(/设「([^」]+)」为\s*(.+)/);
                if (match) {
                    ast.push({
                        type: 'var_declaration',
                        name: match[1],
                        value: match[2]
                    });
                }
            } else if (line.startsWith('打印')) {
                // 打印语句: 打印 值
                const match = line.match(/打印\s*(.+)/);
                if (match) {
                    ast.push({
                        type: 'print',
                        value: match[1]
                    });
                }
            } else if (line.startsWith('夫「') && line.includes('」者受')) {
                // 函数定义: 夫「函数名」者受 参数 焉算法乃
                const match = line.match(/夫「([^」]+)」者受\s*([^焉]+)焉算法乃\s*(.*)/);
                if (match) {
                    ast.push({
                        type: 'function_definition',
                        name: match[1],
                        params: match[2].trim().split(/\s+/),
                        body: match[3] || ''
                    });
                }
            } else if (line.includes('答')) {
                // 返回语句: 答 值
                const match = line.match(/答\s*(.+)/);
                if (match) {
                    ast.push({
                        type: 'return',
                        value: match[1]
                    });
                }
            } else if (line.match(/\d+/)) {
                // 数字字面量
                ast.push({
                    type: 'literal',
                    value: line
                });
            } else if (line.startsWith('『') && line.endsWith('』')) {
                // 字符串字面量
                ast.push({
                    type: 'string_literal',
                    value: line.slice(1, -1)
                });
            }
        }

        return ast;
    }

    /**
     * 生成C代码
     */
    generateCCode(ast) {
        let cCode = this.generateHeaders();
        cCode += this.generateGlobalDeclarations();
        cCode += this.generateFunctions(ast);
        cCode += this.generateMain(ast);
        return cCode;
    }

    /**
     * 生成C代码头文件
     */
    generateHeaders() {
        return `#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 骆言运行时类型定义
typedef struct {
    enum { LUOYAN_INT, LUOYAN_STRING, LUOYAN_UNIT } type;
    union {
        int int_val;
        char* string_val;
    } value;
} luoyan_value_t;

// 骆言运行时函数声明
void luoyan_print(luoyan_value_t val);
luoyan_value_t luoyan_make_int(int val);
luoyan_value_t luoyan_make_string(const char* val);
luoyan_value_t luoyan_make_unit(void);

`;
    }

    /**
     * 生成全局声明
     */
    generateGlobalDeclarations() {
        return `// 全局变量声明
${this.context.globalVars.map(var => `luoyan_value_t ${var};`).join('\n')}

`;
    }

    /**
     * 生成函数定义
     */
    generateFunctions(ast) {
        let functionsCode = '';
        
        for (const node of ast) {
            if (node.type === 'function_definition') {
                functionsCode += this.generateFunction(node);
            }
        }

        return functionsCode;
    }

    /**
     * 生成单个函数
     */
    generateFunction(node) {
        const funcName = this.escapeIdentifier(node.name);
        const params = node.params.map(param => `luoyan_value_t ${this.escapeIdentifier(param)}`).join(', ');
        
        let funcCode = `luoyan_value_t ${funcName}(${params}) {\n`;
        
        // 简化的函数体处理
        if (node.body.includes('答')) {
            const returnValue = node.body.replace(/答\s*/, '');
            if (returnValue.match(/^\d+$/)) {
                funcCode += `    return luoyan_make_int(${returnValue});\n`;
            } else {
                funcCode += `    return luoyan_make_string("${returnValue}");\n`;
            }
        } else {
            funcCode += `    return luoyan_make_unit();\n`;
        }
        
        funcCode += `}\n\n`;
        return funcCode;
    }

    /**
     * 生成主函数
     */
    generateMain(ast) {
        let mainCode = `int main() {\n`;
        
        for (const node of ast) {
            switch (node.type) {
                case 'var_declaration':
                    mainCode += this.generateVarDeclaration(node);
                    break;
                case 'print':
                    mainCode += this.generatePrint(node);
                    break;
                case 'literal':
                    // 如果是独立的字面量，可能是表达式求值
                    if (node.value.match(/^\d+$/)) {
                        mainCode += `    luoyan_print(luoyan_make_int(${node.value}));\n`;
                    }
                    break;
                case 'string_literal':
                    mainCode += `    luoyan_print(luoyan_make_string("${node.value}"));\n`;
                    break;
            }
        }
        
        mainCode += `    return 0;\n`;
        mainCode += `}\n\n`;
        
        // 添加运行时函数实现
        mainCode += this.generateRuntimeFunctions();
        
        return mainCode;
    }

    /**
     * 生成变量声明
     */
    generateVarDeclaration(node) {
        const varName = this.escapeIdentifier(node.name);
        let initValue;
        
        if (node.value.match(/^\d+$/)) {
            initValue = `luoyan_make_int(${node.value})`;
        } else if (node.value.startsWith('『') && node.value.endsWith('』')) {
            const stringValue = node.value.slice(1, -1);
            initValue = `luoyan_make_string("${stringValue}")`;
        } else {
            initValue = `luoyan_make_string("${node.value}")`;
        }
        
        return `    luoyan_value_t ${varName} = ${initValue};\n`;
    }

    /**
     * 生成打印语句
     */
    generatePrint(node) {
        let printValue;
        
        if (node.value.match(/^\d+$/)) {
            printValue = `luoyan_make_int(${node.value})`;
        } else if (node.value.startsWith('『') && node.value.endsWith('』')) {
            const stringValue = node.value.slice(1, -1);
            printValue = `luoyan_make_string("${stringValue}")`;
        } else if (node.value.startsWith('「') && node.value.endsWith('」')) {
            // 变量引用
            const varName = this.escapeIdentifier(node.value.slice(1, -1));
            printValue = varName;
        } else {
            printValue = `luoyan_make_string("${node.value}")`;
        }
        
        return `    luoyan_print(${printValue});\n`;
    }

    /**
     * 生成运行时函数实现
     */
    generateRuntimeFunctions() {
        return `// 骆言运行时函数实现
void luoyan_print(luoyan_value_t val) {
    switch (val.type) {
        case LUOYAN_INT:
            printf("%d\\n", val.value.int_val);
            break;
        case LUOYAN_STRING:
            printf("%s\\n", val.value.string_val);
            break;
        case LUOYAN_UNIT:
            printf("()\\n");
            break;
    }
}

luoyan_value_t luoyan_make_int(int val) {
    luoyan_value_t result;
    result.type = LUOYAN_INT;
    result.value.int_val = val;
    return result;
}

luoyan_value_t luoyan_make_string(const char* val) {
    luoyan_value_t result;
    result.type = LUOYAN_STRING;
    result.value.string_val = strdup(val);
    return result;
}

luoyan_value_t luoyan_make_unit(void) {
    luoyan_value_t result;
    result.type = LUOYAN_UNIT;
    return result;
}
`;
    }

    /**
     * 转义标识符
     */
    escapeIdentifier(name) {
        // 将中文字符转换为安全的C标识符
        return 'luoyan_' + name.replace(/[^a-zA-Z0-9_]/g, '_');
    }

    /**
     * 生成唯一变量名
     */
    genVarName(prefix) {
        const id = this.context.nextVarId++;
        return `luoyan_var_${prefix}_${id}`;
    }
}

// 将类暴露给全局作用域
window.LuoyanCompiler = LuoyanCompiler;