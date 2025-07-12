#include "luoyan_runtime.h"

luoyan_value_t* luoyan_var_func_0_impl_名字(luoyan_env_t* env, luoyan_value_t* arg) {
  luoyan_env_bind(env, "_00e5__0090__008d__00e5__00ad__0097_", arg);
  return ({ luoyan_env_bind(env, "_00e6__00ad__00a5__00e9__00aa__00a4_1", luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_string("=== 骆言演示 ==="))); ({ luoyan_env_bind(env, "_00e6__00ad__00a5__00e9__00aa__00a4_2", luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e5__0090__008d__00e5__00ad__0097_"))); ({ luoyan_env_bind(env, "_00e6__00ad__00a5__00e9__00aa__00a4_3", luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_string("演示完成！"))); luoyan_string("成功"); }); }); });
}

int main() {
  luoyan_runtime_init();
  luoyan_env_t* env = luoyan_env_create(NULL);
  
  // 添加内置函数
  luoyan_env_bind(env, "_00e6__0089__0093__00e5__008d__00b0_", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  luoyan_env_bind(env, "_00e8__00af__00bb__00e5__008f__0096_", luoyan_function_create(luoyan_builtin_read, env, "读取"));
  luoyan_env_bind(env, "_00e5__00ad__0097__00e7__00ac__00a6__00e4__00b8__00b2__00e8__00bf__009e__00e6__008e__00a5_", luoyan_function_create(luoyan_builtin_string_concat, env, "字符串连接"));
  luoyan_env_bind(env, "_00e8__00af__00bb__00e5__008f__0096__00e6__0096__0087__00e4__00bb__00b6_", luoyan_function_create(luoyan_builtin_read_file, env, "读取文件"));
  luoyan_env_bind(env, "_00e5__0086__0099__00e5__0085__00a5__00e6__0096__0087__00e4__00bb__00b6_", luoyan_function_create(luoyan_builtin_write_file, env, "写入文件"));
  luoyan_env_bind(env, "_00e6__0096__0087__00e4__00bb__00b6__00e5__00ad__0098__00e5__009c__00a8_", luoyan_function_create(luoyan_builtin_file_exists, env, "文件存在"));
  
  // 用户程序
luoyan_env_bind(env, "_00e6__00bc__0094__00e7__00a4__00ba__00e5__0087__00bd__00e6__0095__00b0_", luoyan_function_create(luoyan_var_func_0_impl_名字, env, "luoyan_var_func_0"));
luoyan_env_bind(env, "_00e7__00bb__0093__00e6__009e__009c_", luoyan_function_call(luoyan_env_lookup(env, "_00e6__00bc__0094__00e7__00a4__00ba__00e5__0087__00bd__00e6__0095__00b0_"), luoyan_string("文件处理测试")));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e7__00bb__0093__00e6__009e__009c_"));

  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  return 0;
}
