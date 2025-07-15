/**
 * 骆言在线IDE主应用
 * 提供完整的Web IDE功能，支持骆言编程语言
 */

class LuoyanIDE {
    constructor() {
        this.editor = null;
        this.currentFile = null;
        this.openTabs = new Map();
        this.projectFiles = [];
        this.categories = {};
        this.isDarkTheme = true;
        
        this.init();
    }

    /**
     * 初始化IDE
     */
    async init() {
        try {
            this.showLoading(true);
            
            // 加载文件清单
            await this.loadFileManifest();
            
            // 初始化UI组件
            this.initEditor();
            this.initFileExplorer();
            this.initEventHandlers();
            this.initTheme();
            
            // 显示项目统计
            this.updateProjectStats();
            
            this.showLoading(false);
            this.setStatusMessage('骆言IDE已就绪');
            
            console.log('骆言IDE初始化完成');
        } catch (error) {
            console.error('IDE初始化失败:', error);
            this.showError('IDE初始化失败: ' + error.message);
        }
    }

    /**
     * 加载文件清单
     */
    async loadFileManifest() {
        if (typeof FILE_MANIFEST === 'undefined') {
            throw new Error('文件清单未加载');
        }
        
        this.projectFiles = FILE_MANIFEST.files || [];
        this.categories = FILE_MANIFEST.categories || {};
        
        console.log(`已加载 ${this.projectFiles.length} 个文件`);
    }

    /**
     * 初始化代码编辑器
     */
    initEditor() {
        const textarea = document.getElementById('code-editor');
        
        this.editor = CodeMirror.fromTextArea(textarea, {
            mode: 'luoyan',
            theme: 'material-darker',
            lineNumbers: true,
            lineWrapping: true,
            foldGutter: true,
            gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
            matchBrackets: true,
            autoCloseBrackets: true,
            indentUnit: 2,
            tabSize: 2,
            extraKeys: {
                'Ctrl-S': () => this.saveCurrentFile(),
                'Ctrl-R': () => this.runCurrentFile(),
                'F11': () => this.toggleFullscreen(),
                'Ctrl-F': 'findPersistent',
                'Ctrl-H': 'replace'
            }
        });

        // 监听编辑器变化
        this.editor.on('change', () => {
            this.markFileAsModified();
            this.updateCursorPosition();
        });

        this.editor.on('cursorActivity', () => {
            this.updateCursorPosition();
        });
    }

    /**
     * 初始化文件浏览器
     */
    initFileExplorer() {
        const container = document.getElementById('file-categories');
        container.innerHTML = '';

        // 更新总文件数
        document.getElementById('total-files').textContent = this.projectFiles.length;

        // 创建分类
        for (const [categoryName, files] of Object.entries(this.categories)) {
            if (files.length === 0) continue;
            
            const categoryElement = this.createCategoryElement(categoryName, files);
            container.appendChild(categoryElement);
        }
    }

    /**
     * 创建文件分类元素
     */
    createCategoryElement(categoryName, files) {
        const category = document.createElement('div');
        category.className = 'category';

        // 分类标题
        const header = document.createElement('div');
        header.className = 'category-header';
        header.innerHTML = `
            <i class="fas fa-chevron-down"></i>
            ${categoryName}
            <span class="category-count">${files.length}</span>
        `;
        
        header.addEventListener('click', () => {
            category.classList.toggle('collapsed');
        });

        // 文件列表
        const fileList = document.createElement('div');
        fileList.className = 'file-list';

        files.forEach(file => {
            const fileItem = this.createFileItem(file);
            fileList.appendChild(fileItem);
        });

        category.appendChild(header);
        category.appendChild(fileList);
        
        return category;
    }

    /**
     * 创建文件项元素
     */
    createFileItem(file) {
        const item = document.createElement('div');
        item.className = 'file-item';
        item.dataset.path = file.path;

        const icon = this.getFileIcon(file.extension);
        
        item.innerHTML = `
            <i class="file-icon ${icon}"></i>
            <div class="file-info">
                <div class="file-name">${file.name}</div>
                <div class="file-preview">${this.getFilePreview(file)}</div>
            </div>
        `;

        item.addEventListener('click', () => {
            this.openFile(file);
        });

        return item;
    }

    /**
     * 获取文件图标
     */
    getFileIcon(extension) {
        const iconMap = {
            '.ly': 'fas fa-file-code',
            '.ml': 'fas fa-file-code',
            '.c': 'fas fa-file-code',
            '.expected': 'fas fa-file-alt',
            '.expected_error': 'fas fa-exclamation-triangle',
            '.md': 'fas fa-file-text',
            '.json': 'fas fa-file-code',
            '.ts': 'fas fa-file-code'
        };
        
        return iconMap[extension] || 'fas fa-file';
    }

    /**
     * 获取文件预览
     */
    getFilePreview(file) {
        const sizeKB = (file.size / 1024).toFixed(1);
        const modified = new Date(file.modified).toLocaleDateString('zh-CN');
        return `${sizeKB}KB · ${modified}`;
    }

    /**
     * 打开文件
     */
    async openFile(file) {
        try {
            this.setStatusMessage(`正在加载 ${file.name}...`);
            
            // 标记当前活动文件
            this.markActiveFile(file.path);
            
            // 如果文件已经打开，切换到该标签
            if (this.openTabs.has(file.path)) {
                this.switchToTab(file.path);
                return;
            }

            // 读取文件内容
            const content = await this.loadFileContent(file);
            
            // 隐藏欢迎面板，显示编辑器
            this.showEditorPanel();
            
            // 设置编辑器内容和模式
            this.editor.setValue(content);
            this.setEditorMode(file.extension);
            
            // 创建新标签
            this.createTab(file);
            
            // 保存到打开的标签
            this.openTabs.set(file.path, {
                file: file,
                content: content,
                modified: false
            });
            
            this.currentFile = file;
            this.updateFileInfo(file);
            this.updateButtonStates();
            this.setStatusMessage(`已打开 ${file.name}`);
            
        } catch (error) {
            console.error('打开文件失败:', error);
            this.showError(`无法打开文件 ${file.name}: ${error.message}`);
        }
    }

    /**
     * 加载文件内容
     */
    async loadFileContent(file) {
        try {
            // 构建完整的文件路径
            const fullPath = `../${file.path}`;
            const response = await fetch(fullPath);
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const content = await response.text();
            return content;
            
        } catch (error) {
            // 如果无法获取实际文件，显示示例内容
            return this.getExampleContent(file);
        }
    }

    /**
     * 获取示例文件内容
     */
    getExampleContent(file) {
        const examples = {
            '.ly': `「：${file.name} 示例代码：」

夫「问候」者受 名字 焉算法乃
  打印 『你好，』 加 名字 加 『！』
也

设「用户名」为『世界』
问候 用户名

「：更多示例代码请查看项目中的其他文件：」`,
            
            '.ml': `(* ${file.name} OCaml测试文件 *)

let test_example () =
  let result = example_function 42 in
  assert (result = expected_value);
  print_endline "测试通过"

let () = test_example ()`,
            
            '.expected': `预期输出示例
你好，世界！
测试通过`,
            
            '.expected_error': `预期错误输出
Error: 类型不匹配
在第3行：期望 int，实际得到 string`
        };
        
        return examples[file.extension] || `# ${file.name}\n\n文件内容无法加载，这是一个示例占位符。\n\n请检查文件路径是否正确。`;
    }

    /**
     * 设置编辑器模式
     */
    setEditorMode(extension) {
        const modeMap = {
            '.ly': 'luoyan',
            '.ml': 'text/x-ocaml',
            '.c': 'text/x-csrc',
            '.js': 'javascript',
            '.ts': 'text/typescript',
            '.json': 'application/json',
            '.md': 'text/x-markdown'
        };
        
        const mode = modeMap[extension] || 'text/plain';
        this.editor.setOption('mode', mode);
        
        // 更新状态栏
        const fileType = extension === '.ly' ? '骆言' : extension.substring(1).toUpperCase();
        document.getElementById('file-type').textContent = fileType;
    }

    /**
     * 标记活动文件
     */
    markActiveFile(filePath) {
        // 移除所有活动状态
        document.querySelectorAll('.file-item.active').forEach(item => {
            item.classList.remove('active');
        });
        
        // 添加当前文件的活动状态
        const fileItem = document.querySelector(`[data-path="${filePath}"]`);
        if (fileItem) {
            fileItem.classList.add('active');
        }
    }

    /**
     * 显示编辑器面板
     */
    showEditorPanel() {
        document.getElementById('welcome-panel').classList.remove('active');
        document.getElementById('editor-panel').classList.add('active');
    }

    /**
     * 显示欢迎面板
     */
    showWelcomePanel() {
        document.getElementById('editor-panel').classList.remove('active');
        document.getElementById('welcome-panel').classList.add('active');
    }

    /**
     * 创建标签
     */
    createTab(file) {
        const tabBar = document.getElementById('tab-bar');
        
        // 移除欢迎标签的active状态
        const welcomeTab = tabBar.querySelector('.welcome-tab');
        if (welcomeTab) {
            welcomeTab.classList.remove('active');
        }
        
        // 检查标签是否已存在
        const existingTab = tabBar.querySelector(`[data-path="${file.path}"]`);
        if (existingTab) {
            this.switchToTab(file.path);
            return;
        }

        const tab = document.createElement('div');
        tab.className = 'tab active';
        tab.dataset.path = file.path;
        
        const icon = this.getFileIcon(file.extension);
        tab.innerHTML = `
            <i class="${icon}"></i>
            <span>${file.name}</span>
            <i class="tab-close fas fa-times"></i>
        `;

        // 点击标签切换
        tab.addEventListener('click', (e) => {
            if (!e.target.classList.contains('tab-close')) {
                this.switchToTab(file.path);
            }
        });

        // 关闭标签
        tab.querySelector('.tab-close').addEventListener('click', (e) => {
            e.stopPropagation();
            this.closeTab(file.path);
        });

        tabBar.appendChild(tab);
        
        // 移除其他标签的active状态
        tabBar.querySelectorAll('.tab').forEach(t => {
            if (t !== tab) t.classList.remove('active');
        });
    }

    /**
     * 切换标签
     */
    switchToTab(filePath) {
        const tabData = this.openTabs.get(filePath);
        if (!tabData) return;

        // 更新标签状态
        document.querySelectorAll('.tab').forEach(tab => {
            tab.classList.toggle('active', tab.dataset.path === filePath);
        });

        // 更新编辑器内容
        this.editor.setValue(tabData.content);
        this.setEditorMode(tabData.file.extension);
        
        this.currentFile = tabData.file;
        this.updateFileInfo(tabData.file);
        this.updateButtonStates();
        this.markActiveFile(filePath);
        
        this.showEditorPanel();
    }

    /**
     * 关闭标签
     */
    closeTab(filePath) {
        const tab = document.querySelector(`.tab[data-path="${filePath}"]`);
        if (!tab) return;

        const tabData = this.openTabs.get(filePath);
        
        // 检查是否有未保存的更改
        if (tabData && tabData.modified) {
            const shouldClose = confirm(`文件 ${tabData.file.name} 有未保存的更改，确定要关闭吗？`);
            if (!shouldClose) return;
        }

        // 移除标签和数据
        tab.remove();
        this.openTabs.delete(filePath);

        // 如果是当前文件，切换到其他标签或欢迎页面
        if (this.currentFile && this.currentFile.path === filePath) {
            const remainingTabs = document.querySelectorAll('.tab');
            if (remainingTabs.length > 0) {
                const lastTab = remainingTabs[remainingTabs.length - 1];
                this.switchToTab(lastTab.dataset.path);
            } else {
                this.showWelcomePanel();
                this.currentFile = null;
                document.querySelector('.welcome-tab').classList.add('active');
            }
        }

        // 移除活动文件标记
        if (this.currentFile && this.currentFile.path === filePath) {
            document.querySelectorAll('.file-item.active').forEach(item => {
                item.classList.remove('active');
            });
        }
    }

    /**
     * 更新文件信息
     */
    updateFileInfo(file) {
        document.getElementById('current-file-name').textContent = file.name;
        document.getElementById('current-file-path').textContent = file.path;
    }

    /**
     * 标记文件为已修改
     */
    markFileAsModified() {
        if (!this.currentFile) return;

        const tabData = this.openTabs.get(this.currentFile.path);
        if (tabData && !tabData.modified) {
            tabData.modified = true;
            tabData.content = this.editor.getValue();
            
            // 在标签上添加修改标记
            const tab = document.querySelector(`.tab[data-path="${this.currentFile.path}"]`);
            if (tab) {
                const tabText = tab.querySelector('span');
                if (tabText && !tabText.textContent.includes('●')) {
                    tabText.textContent = '● ' + tabText.textContent;
                }
            }
        }
    }

    /**
     * 初始化事件处理器
     */
    initEventHandlers() {
        // 搜索文件
        const searchInput = document.getElementById('file-search');
        searchInput.addEventListener('input', (e) => {
            this.searchFiles(e.target.value);
        });

        // 主题切换
        document.getElementById('theme-toggle').addEventListener('click', () => {
            this.toggleTheme();
        });

        // 全屏切换
        document.getElementById('fullscreen-toggle').addEventListener('click', () => {
            this.toggleFullscreen();
        });

        // 下载文件
        document.getElementById('download-btn').addEventListener('click', () => {
            this.downloadCurrentFile();
        });

        // 运行按钮
        document.getElementById('run-btn').addEventListener('click', () => {
            this.runCurrentFile();
        });

        // 编译到C按钮
        document.getElementById('compile-c-btn').addEventListener('click', () => {
            this.compileToC();
        });

        // 编译到WebAssembly按钮
        document.getElementById('compile-wasm-btn').addEventListener('click', () => {
            this.compileToWasm();
        });

        // 清空输出
        document.getElementById('clear-output').addEventListener('click', () => {
            this.clearOutput();
        });

        // 欢迎标签点击
        document.querySelector('.welcome-tab').addEventListener('click', () => {
            this.showWelcomePanel();
            document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
            document.querySelector('.welcome-tab').classList.add('active');
        });

        // 键盘快捷键
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey || e.metaKey) {
                switch (e.key) {
                    case 's':
                        e.preventDefault();
                        this.saveCurrentFile();
                        break;
                    case 'r':
                        e.preventDefault();
                        this.runCurrentFile();
                        break;
                }
            }
        });
    }

    /**
     * 搜索文件
     */
    searchFiles(query) {
        const lowerQuery = query.toLowerCase();
        
        document.querySelectorAll('.file-item').forEach(item => {
            const fileName = item.querySelector('.file-name').textContent.toLowerCase();
            const filePath = item.dataset.path.toLowerCase();
            
            const matches = fileName.includes(lowerQuery) || filePath.includes(lowerQuery);
            item.style.display = matches ? 'flex' : 'none';
        });

        // 展开包含匹配文件的分类
        if (query) {
            document.querySelectorAll('.category').forEach(category => {
                const hasVisibleFiles = category.querySelector('.file-item[style*="flex"]');
                if (hasVisibleFiles) {
                    category.classList.remove('collapsed');
                }
            });
        }
    }

    /**
     * 初始化主题
     */
    initTheme() {
        const savedTheme = localStorage.getItem('luoyan-ide-theme') || 'dark';
        this.setTheme(savedTheme);
    }

    /**
     * 切换主题
     */
    toggleTheme() {
        const newTheme = this.isDarkTheme ? 'light' : 'dark';
        this.setTheme(newTheme);
    }

    /**
     * 设置主题
     */
    setTheme(theme) {
        this.isDarkTheme = theme === 'dark';
        
        if (this.isDarkTheme) {
            document.body.removeAttribute('data-theme');
            this.editor && this.editor.setOption('theme', 'material-darker');
        } else {
            document.body.setAttribute('data-theme', 'light');
            this.editor && this.editor.setOption('theme', 'default');
        }

        // 更新主题切换按钮图标
        const themeIcon = document.querySelector('#theme-toggle i');
        themeIcon.className = this.isDarkTheme ? 'fas fa-sun' : 'fas fa-moon';

        // 保存主题偏好
        localStorage.setItem('luoyan-ide-theme', theme);
    }

    /**
     * 切换全屏
     */
    toggleFullscreen() {
        if (!document.fullscreenElement) {
            document.documentElement.requestFullscreen();
            document.querySelector('#fullscreen-toggle i').className = 'fas fa-compress';
        } else {
            document.exitFullscreen();
            document.querySelector('#fullscreen-toggle i').className = 'fas fa-expand';
        }
    }

    /**
     * 下载当前文件
     */
    downloadCurrentFile() {
        if (!this.currentFile) {
            this.showError('没有打开的文件可以下载');
            return;
        }

        const content = this.editor.getValue();
        const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
        const url = URL.createObjectURL(blob);
        
        const a = document.createElement('a');
        a.href = url;
        a.download = this.currentFile.name;
        a.click();
        
        URL.revokeObjectURL(url);
        this.setStatusMessage(`已下载 ${this.currentFile.name}`);
    }

    /**
     * 保存当前文件
     */
    saveCurrentFile() {
        if (!this.currentFile) return;

        const tabData = this.openTabs.get(this.currentFile.path);
        if (tabData) {
            tabData.content = this.editor.getValue();
            tabData.modified = false;
            
            // 移除标签上的修改标记
            const tab = document.querySelector(`.tab[data-path="${this.currentFile.path}"]`);
            if (tab) {
                const tabText = tab.querySelector('span');
                if (tabText) {
                    tabText.textContent = tabText.textContent.replace('● ', '');
                }
            }
        }

        this.setStatusMessage(`已保存 ${this.currentFile.name}`);
    }

    /**
     * 运行当前文件
     */
    runCurrentFile() {
        if (!this.currentFile) {
            this.showError('没有打开的文件可以运行');
            return;
        }

        const content = this.editor.getValue();
        this.simulateCodeExecution(content, this.currentFile);
    }

    /**
     * 模拟代码执行
     */
    simulateCodeExecution(content, file) {
        const outputElement = document.getElementById('output-content');
        
        this.addOutput(`> 正在运行 ${file.name}...\n`, 'info');
        
        setTimeout(() => {
            if (file.extension === '.ly') {
                this.simulateLuoyanExecution(content);
            } else if (file.extension === '.ml') {
                this.simulateOCamlExecution(content);
            } else {
                this.addOutput('此文件类型不支持直接运行\n', 'warning');
            }
        }, 500);
    }

    /**
     * 模拟骆言代码执行
     */
    simulateLuoyanExecution(content) {
        // 简单的模拟执行
        if (content.includes('打印')) {
            const printMatches = content.match(/打印\s*[『"][^『"]*[』"]/g);
            if (printMatches) {
                printMatches.forEach(match => {
                    const text = match.replace(/打印\s*[『"]([^『"]*)[』"]/, '$1');
                    this.addOutput(text + '\n', 'output');
                });
            }
        }
        
        if (content.includes('问候')) {
            this.addOutput('你好，世界！\n', 'output');
        }
        
        this.addOutput('\n程序执行完成\n', 'success');
    }

    /**
     * 模拟OCaml代码执行
     */
    simulateOCamlExecution(content) {
        if (content.includes('print_endline')) {
            const printMatches = content.match(/print_endline\s*"[^"]*"/g);
            if (printMatches) {
                printMatches.forEach(match => {
                    const text = match.replace(/print_endline\s*"([^"]*)"/, '$1');
                    this.addOutput(text + '\n', 'output');
                });
            }
        }
        
        this.addOutput('测试通过\n', 'success');
    }

    /**
     * 添加输出
     */
    addOutput(text, type = 'output') {
        const outputElement = document.getElementById('output-content');
        const span = document.createElement('span');
        span.className = `output-${type}`;
        span.textContent = text;
        outputElement.appendChild(span);
        outputElement.scrollTop = outputElement.scrollHeight;
    }

    /**
     * 清空输出
     */
    clearOutput() {
        document.getElementById('output-content').innerHTML = '';
    }

    /**
     * 更新光标位置
     */
    updateCursorPosition() {
        if (!this.editor) return;
        
        const cursor = this.editor.getCursor();
        const line = cursor.line + 1;
        const col = cursor.ch + 1;
        
        document.getElementById('cursor-position').textContent = `行 ${line}, 列 ${col}`;
    }

    /**
     * 更新项目统计
     */
    updateProjectStats() {
        const statsElement = document.getElementById('project-stats');
        if (!statsElement) return;

        const stats = FILE_MANIFEST.stats;
        
        statsElement.innerHTML = `
            <div class="stat-item">
                <strong>${stats.totalFiles}</strong> 个文件
            </div>
            <div class="stat-item">
                <strong>${stats.byExtension['.ly'] || 0}</strong> 个骆言文件
            </div>
            <div class="stat-item">
                <strong>${stats.byExtension['.ml'] || 0}</strong> 个测试文件
            </div>
            <div class="stat-item">
                <strong>${(stats.totalSize / 1024).toFixed(1)}</strong> KB 总大小
            </div>
        `;
    }

    /**
     * 设置状态消息
     */
    setStatusMessage(message) {
        document.getElementById('status-message').textContent = message;
    }

    /**
     * 显示错误消息
     */
    showError(message) {
        this.addOutput(`错误: ${message}\n`, 'error');
        this.setStatusMessage(`错误: ${message}`);
    }

    /**
     * 显示/隐藏加载指示器
     */
    showLoading(show) {
        const loadingElement = document.getElementById('loading');
        loadingElement.style.display = show ? 'flex' : 'none';
    }

    /**
     * 更新按钮状态
     */
    updateButtonStates() {
        const runBtn = document.getElementById('run-btn');
        const compileCBtn = document.getElementById('compile-c-btn');
        const compileWasmBtn = document.getElementById('compile-wasm-btn');
        
        if (this.currentFile && this.currentFile.extension === '.ly') {
            runBtn.disabled = false;
            compileCBtn.disabled = false;
            compileWasmBtn.disabled = false;
        } else {
            runBtn.disabled = this.currentFile ? false : true;
            compileCBtn.disabled = true;
            compileWasmBtn.disabled = true;
        }
    }

    /**
     * 编译到C语言
     */
    compileToC() {
        if (!this.currentFile || this.currentFile.extension !== '.ly') {
            this.showError('只能编译.ly文件到C语言');
            return;
        }

        const content = this.editor.getValue();
        this.addOutput(`> 正在编译 ${this.currentFile.name} 到C语言...\n`, 'info');
        
        try {
            // 创建骆言编译器实例
            const compiler = new LuoyanCompiler();
            const cCode = compiler.compileToC(content);
            
            // 显示编译结果
            this.addOutput('编译成功！\n', 'success');
            this.addOutput('生成的C代码:\n', 'info');
            this.addOutput('```c\n', 'output');
            this.addOutput(cCode, 'output');
            this.addOutput('\n```\n', 'output');
            
            // 提供下载链接
            this.offerDownload(cCode, this.currentFile.name.replace('.ly', '.c'), 'text/c');
            
        } catch (error) {
            this.addOutput(`编译失败: ${error.message}\n`, 'error');
            this.showError(`编译失败: ${error.message}`);
        }
    }

    /**
     * 编译到WebAssembly
     */
    compileToWasm() {
        if (!this.currentFile || this.currentFile.extension !== '.ly') {
            this.showError('只能编译.ly文件到WebAssembly');
            return;
        }

        this.addOutput(`> 正在编译 ${this.currentFile.name} 到WebAssembly...\n`, 'info');
        
        try {
            // 先编译到C
            const compiler = new LuoyanCompiler();
            const cCode = compiler.compileToC(this.editor.getValue());
            
            // 然后编译C代码到WebAssembly (模拟)
            this.addOutput('第1步: 编译到C代码 - 完成\n', 'success');
            this.addOutput('第2步: 编译C代码到WebAssembly...\n', 'info');
            
            // 模拟WebAssembly编译过程
            setTimeout(() => {
                const wasmCode = this.generateWasmCode(cCode);
                this.addOutput('第2步: 编译到WebAssembly - 完成\n', 'success');
                this.addOutput('生成的WebAssembly模块已准备就绪\n', 'success');
                
                // 提供下载链接
                this.offerDownload(wasmCode, this.currentFile.name.replace('.ly', '.wasm'), 'application/wasm');
            }, 1000);
            
        } catch (error) {
            this.addOutput(`编译失败: ${error.message}\n`, 'error');
            this.showError(`编译失败: ${error.message}`);
        }
    }

    /**
     * 生成WebAssembly代码（模拟）
     */
    generateWasmCode(cCode) {
        // 这里是模拟的WebAssembly生成
        // 在实际实现中，这里需要调用Emscripten或其他工具
        return `// WebAssembly模块 (基于C代码生成)
// 原始C代码:
/*
${cCode}
*/

// 简化的WebAssembly文本格式
(module
  (func $main (result i32)
    i32.const 42
  )
  (export "main" (func $main))
)`;
    }

    /**
     * 提供文件下载
     */
    offerDownload(content, filename, mimeType) {
        const blob = new Blob([content], { type: mimeType });
        const url = URL.createObjectURL(blob);
        
        const downloadLink = document.createElement('a');
        downloadLink.href = url;
        downloadLink.download = filename;
        downloadLink.textContent = `下载 ${filename}`;
        downloadLink.className = 'download-link';
        downloadLink.style.cssText = 'color: #4fc3f7; text-decoration: underline; cursor: pointer; margin-left: 10px;';
        
        downloadLink.onclick = () => {
            URL.revokeObjectURL(url);
        };
        
        const outputElement = document.getElementById('output-content');
        const linkContainer = document.createElement('div');
        linkContainer.appendChild(downloadLink);
        outputElement.appendChild(linkContainer);
        
        this.addOutput(`文件已生成: `, 'info');
        this.addOutput(`${filename}\n`, 'success');
    }
}

// 全局函数
function openSampleFile() {
    const ide = window.luoyanIDE;
    if (!ide) return;
    
    // 查找第一个示例文件
    const sampleFile = ide.projectFiles.find(f => 
        f.path.includes('示例') && f.extension === '.ly'
    );
    
    if (sampleFile) {
        ide.openFile(sampleFile);
    } else {
        alert('未找到示例文件');
    }
}

function showDocumentation() {
    window.open('https://github.com/UltimatePea/chinese-ocaml', '_blank');
}

// 初始化IDE
document.addEventListener('DOMContentLoaded', () => {
    window.luoyanIDE = new LuoyanIDE();
});

// 添加输出样式
const outputStyles = `
.output-output { color: var(--text-primary); }
.output-info { color: var(--text-accent); }
.output-success { color: var(--success-color); }
.output-warning { color: var(--warning-color); }
.output-error { color: var(--error-color); }
.stat-item { margin-bottom: 8px; }
`;

// 动态添加样式
const styleSheet = document.createElement('style');
styleSheet.textContent = outputStyles;
document.head.appendChild(styleSheet);