#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * 骆言在线IDE文件清单生成器
 * 自动扫描项目中的所有测试文件和示例代码，生成可在浏览器中使用的文件清单
 */

// 目标文件扩展名
const TARGET_EXTENSIONS = ['.ly', '.ml', '.expected', '.expected_error', '.c'];

// 要扫描的目录（相对于项目根目录）
const SCAN_DIRECTORIES = [
    '示例',
    '标准库', 
    'test',
    '自举',
    '骆言编译器',
    '性能测试',
    '.',  // 根目录的.ly文件
    'vscode-luoyan'
];

// 忽略的目录
const IGNORE_DIRS = [
    '.git', '_opam', 'node_modules', 'debug', '.claude',
    'scripts', 'manager.py', 'github_auth.py', 'claude_manager_only.sh',
    'doc', '临时', '可执行文件', 'C后端'
];

/**
 * 递归扫描目录，查找目标文件
 */
function scanDirectory(dirPath, basePath = '.') {
    const files = [];
    
    try {
        const items = fs.readdirSync(dirPath);
        
        for (const item of items) {
            const fullPath = path.join(dirPath, item);
            const relativePath = path.join(basePath, item);
            
            // 跳过隐藏文件和忽略的目录
            if (item.startsWith('.') && item !== '.') continue;
            if (IGNORE_DIRS.includes(item)) continue;
            
            const stat = fs.statSync(fullPath);
            
            if (stat.isDirectory()) {
                // 递归扫描子目录
                files.push(...scanDirectory(fullPath, relativePath));
            } else if (stat.isFile()) {
                const ext = path.extname(item);
                if (TARGET_EXTENSIONS.includes(ext)) {
                    files.push({
                        path: relativePath.replace(/\\/g, '/'),
                        name: item,
                        directory: basePath.replace(/\\/g, '/'),
                        extension: ext,
                        size: stat.size,
                        modified: stat.mtime.toISOString()
                    });
                }
            }
        }
    } catch (error) {
        console.warn(`警告: 无法读取目录 ${dirPath}: ${error.message}`);
    }
    
    return files;
}

/**
 * 分类文件
 */
function categorizeFiles(files) {
    const categories = {
        '示例程序': [],
        '测试文件': [],
        '测试输出': [],
        '性能测试': [],
        '标准库': [],
        '自举编译器': [],
        '骆言编译器': [],
        'VSCode扩展': [],
        '其他': []
    };
    
    for (const file of files) {
        const dir = file.directory.toLowerCase();
        const name = file.name.toLowerCase();
        
        if (dir.includes('示例') || dir === '.' && file.extension === '.ly') {
            categories['示例程序'].push(file);
        } else if (dir.includes('test') && file.extension === '.ly') {
            categories['测试文件'].push(file);
        } else if (file.extension === '.expected' || file.extension === '.expected_error') {
            categories['测试输出'].push(file);
        } else if (dir.includes('性能测试')) {
            categories['性能测试'].push(file);
        } else if (dir.includes('标准库')) {
            categories['标准库'].push(file);
        } else if (dir.includes('自举')) {
            categories['自举编译器'].push(file);
        } else if (dir.includes('骆言编译器')) {
            categories['骆言编译器'].push(file);
        } else if (dir.includes('vscode')) {
            categories['VSCode扩展'].push(file);
        } else if (dir.includes('test') && file.extension === '.ml') {
            categories['测试文件'].push(file);
        } else {
            categories['其他'].push(file);
        }
    }
    
    return categories;
}

/**
 * 生成统计信息
 */
function generateStats(files) {
    const stats = {
        totalFiles: files.length,
        byExtension: {},
        byCategory: {},
        totalSize: 0
    };
    
    for (const file of files) {
        // 按扩展名统计
        stats.byExtension[file.extension] = (stats.byExtension[file.extension] || 0) + 1;
        stats.totalSize += file.size;
    }
    
    return stats;
}

/**
 * 主函数
 */
function main() {
    console.log('🔍 骆言在线IDE文件清单生成器');
    console.log('正在扫描项目文件...\n');
    
    const projectRoot = path.join(__dirname, '..');
    const allFiles = [];
    
    // 扫描所有目标目录
    for (const dir of SCAN_DIRECTORIES) {
        const dirPath = path.join(projectRoot, dir);
        if (fs.existsSync(dirPath)) {
            console.log(`📁 扫描目录: ${dir}`);
            const files = scanDirectory(dirPath, dir === '.' ? '' : dir);
            allFiles.push(...files);
            console.log(`   发现 ${files.length} 个文件`);
        }
    }
    
    // 分类文件
    const categories = categorizeFiles(allFiles);
    const stats = generateStats(allFiles);
    
    // 生成清单
    const manifest = {
        metadata: {
            generatedAt: new Date().toISOString(),
            projectName: '骆言 (LuoYan) 编程语言',
            version: '1.0.0',
            totalFiles: stats.totalFiles,
            totalSize: stats.totalSize
        },
        stats,
        categories,
        files: allFiles.sort((a, b) => a.path.localeCompare(b.path))
    };
    
    // 写入JavaScript文件
    const jsContent = `// 骆言在线IDE文件清单
// 自动生成于: ${manifest.metadata.generatedAt}
// 总文件数: ${manifest.metadata.totalFiles}

const FILE_MANIFEST = ${JSON.stringify(manifest, null, 2)};

// 导出供浏览器使用
if (typeof module !== 'undefined' && module.exports) {
    module.exports = FILE_MANIFEST;
}`;
    
    const outputPath = path.join(__dirname, 'file-manifest.js');
    fs.writeFileSync(outputPath, jsContent, 'utf8');
    
    // 输出统计信息
    console.log('\n📊 扫描完成统计:');
    console.log(`总文件数: ${stats.totalFiles}`);
    console.log(`总大小: ${(stats.totalSize / 1024).toFixed(2)} KB`);
    console.log('\n按扩展名分布:');
    for (const [ext, count] of Object.entries(stats.byExtension)) {
        console.log(`  ${ext}: ${count} 个`);
    }
    
    console.log('\n按分类分布:');
    for (const [category, files] of Object.entries(categories)) {
        if (files.length > 0) {
            console.log(`  ${category}: ${files.length} 个`);
        }
    }
    
    console.log(`\n✅ 文件清单已生成: ${outputPath}`);
}

// 运行脚本
if (require.main === module) {
    main();
}