#include "luoyan_runtime.h"

luoyan_value_t* luoyan_var_func_0_impl_x(luoyan_env_t* env, luoyan_value_t* arg) {
  luoyan_env_bind(env, "x", arg);
  return luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_string("你好，骆言自举编译器！"));
}

int main() {
  luoyan_runtime_init();
  luoyan_env_t* env = luoyan_env_create(NULL);
  
  // 添加内置函数
  luoyan_env_bind(env, "_00e6__0089__0093__00e5__008d__00b0_", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  luoyan_env_bind(env, "_00e8__00af__00bb__00e5__008f__0096_", luoyan_function_create(luoyan_builtin_read, env, "读取"));
  
  // 用户程序
luoyan_env_bind(env, "_00e4__00b8__00bb__00e5__0087__00bd__00e6__0095__00b0_", luoyan_function_create(luoyan_var_func_0_impl_x, env, "luoyan_var_func_0"));
luoyan_function_call(luoyan_env_lookup(env, "_00e4__00b8__00bb__00e5__0087__00bd__00e6__0095__00b0_"), luoyan_int(0L));

  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  return 0;
}
