/**
 * 骆言编程语言编译器主程序
 * 从OCaml转换为中文JavaScript版本
 * Author: Alpha, 主要工作代理专员
 */

const { 
  诗词形式, 
  创建韵律信息, 
  创建整数字面量,
  创建字符串字面量 
} = require('./抽象语法树');

/**
 * 主程序入口函数
 */
function 主函数() {
  console.log('🎋 骆言编程语言编译器 - JavaScript版本启动');
  console.log('═══════════════════════════════════════════');
  
  // 演示基本功能
  演示抽象语法树功能();
  
  console.log('═══════════════════════════════════════════');
  console.log('✅ 基础设施转换完成');
}

/**
 * 演示抽象语法树功能
 */
function 演示抽象语法树功能() {
  console.log('\n📝 抽象语法树功能演示:');
  
  // 诗词形式演示
  console.log(`支持的诗词形式: ${Object.keys(诗词形式).join(', ')}`);
  
  // 韵律信息演示
  const 韵律 = 创建韵律信息('平水韵', 2, 'AABA');
  console.log(`韵律信息: ${韵律.toString()}`);
  
  // 字面量演示
  const 整数 = 创建整数字面量(108);
  const 字符串 = 创建字符串字面量('水浒传');
  console.log(`整数字面量: ${整数.toString()}`);
  console.log(`字符串字面量: ${字符串.toString()}`);
}

/**
 * 错误处理
 */
process.on('uncaughtException', (错误) => {
  console.error('❌ 程序发生未捕获异常:', 错误.message);
  console.error(错误.stack);
  process.exit(1);
});

process.on('unhandledRejection', (原因) => {
  console.error('❌ 程序发生未处理Promise拒绝:', 原因);
  process.exit(1);
});

// 如果是直接运行该文件，则启动主函数
if (require.main === module) {
  主函数();
}

module.exports = {
  主函数,
  演示抽象语法树功能
};