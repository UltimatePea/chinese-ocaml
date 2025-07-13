import * as vscode from 'vscode';
import * as path from 'path';

// 扩展激活时调用
export function activate(context: vscode.ExtensionContext) {
    console.log('骆言语言扩展已激活');

    // 注册编译命令
    const compileCommand = vscode.commands.registerCommand('luoyan.compile', (uri: vscode.Uri) => {
        compileFile(uri);
    });

    // 注册运行命令  
    const runCommand = vscode.commands.registerCommand('luoyan.run', (uri: vscode.Uri) => {
        runFile(uri);
    });

    // 注册文档提供器
    const documentFormattingProvider = vscode.languages.registerDocumentFormattingEditProvider('luoyan', {
        provideDocumentFormattingEdits(document: vscode.TextDocument): vscode.TextEdit[] {
            return formatDocument(document);
        }
    });

    // 注册悬停提供器（基础版本）
    const hoverProvider = vscode.languages.registerHoverProvider('luoyan', {
        provideHover(document: vscode.TextDocument, position: vscode.Position): vscode.Hover | undefined {
            return provideHover(document, position);
        }
    });

    context.subscriptions.push(
        compileCommand,
        runCommand,
        documentFormattingProvider,
        hoverProvider
    );

    // 创建状态栏项
    const statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left);
    statusBarItem.text = "$(file-code) 骆言";
    statusBarItem.tooltip = "骆言语言扩展已激活";
    statusBarItem.show();
    context.subscriptions.push(statusBarItem);

    // 监听活动编辑器变化
    vscode.window.onDidChangeActiveTextEditor((editor) => {
        if (editor && editor.document.languageId === 'luoyan') {
            statusBarItem.text = "$(file-code) 骆言 - 活跃";
        } else {
            statusBarItem.text = "$(file-code) 骆言";
        }
    });
}

// 编译文件
function compileFile(uri: vscode.Uri) {
    const filePath = uri.fsPath;
    const fileName = path.basename(filePath);
    
    vscode.window.showInformationMessage(`正在编译 ${fileName}...`);
    
    // 创建终端并运行编译命令
    const terminal = vscode.window.createTerminal('骆言编译器');
    terminal.show();
    
    // 假设编译器在PATH中可用
    terminal.sendText(`yyocamlc "${filePath}"`);
}

// 运行文件
function runFile(uri: vscode.Uri) {
    const filePath = uri.fsPath;
    const fileName = path.basename(filePath);
    
    vscode.window.showInformationMessage(`正在运行 ${fileName}...`);
    
    // 创建终端并运行
    const terminal = vscode.window.createTerminal('骆言运行器');
    terminal.show();
    
    // 先编译后运行
    const baseName = path.basename(filePath, '.ly');
    const dirName = path.dirname(filePath);
    terminal.sendText(`cd "${dirName}" && yyocamlc "${filePath}" && ./${baseName}`);
}

// 基础文档格式化
function formatDocument(document: vscode.TextDocument): vscode.TextEdit[] {
    const edits: vscode.TextEdit[] = [];
    
    for (let i = 0; i < document.lineCount; i++) {
        const line = document.lineAt(i);
        const text = line.text;
        
        // 简单的格式化：移除行尾空格
        const trimmed = text.trimEnd();
        if (trimmed !== text) {
            const range = new vscode.Range(
                line.range.start,
                line.range.end
            );
            edits.push(vscode.TextEdit.replace(range, trimmed));
        }
    }
    
    return edits;
}

// 提供悬停信息
function provideHover(document: vscode.TextDocument, position: vscode.Position): vscode.Hover | undefined {
    const range = document.getWordRangeAtPosition(position);
    if (!range) return undefined;
    
    const word = document.getText(range);
    
    // 基础关键字说明
    const keywordHelp: { [key: string]: string } = {
        '设': '变量声明关键字 - 用于定义新变量',
        '让': '变量绑定关键字 - let绑定',
        '函数': '函数定义关键字 - 定义函数',
        '夫': '古雅体函数定义 - 古文风格的函数定义',
        '是谓': '古雅体结束标记 - 古文风格的结束标记',
        '若': '条件判断关键字 - if条件',
        '则': '条件分支关键字 - then分支',
        '余者': '其他情况关键字 - else分支',
        '答': '返回关键字 - 返回值',
        '观': '模式匹配关键字 - match表达式',
        '性': '属性关键字 - 用于模式匹配',
        '打印': '输出函数 - 打印到控制台'
    };
    
    if (keywordHelp[word]) {
        const contents = new vscode.MarkdownString();
        contents.appendMarkdown(`**${word}**\n\n${keywordHelp[word]}`);
        return new vscode.Hover(contents, range);
    }
    
    return undefined;
}

// 扩展停用时调用
export function deactivate() {
    console.log('骆言语言扩展已停用');
}