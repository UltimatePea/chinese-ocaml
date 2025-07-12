#include "luoyan_runtime.h"



int main() {
  luoyan_runtime_init();
  luoyan_env_t* env = luoyan_env_create(NULL);
  
  // 添加内置函数
  luoyan_env_bind(env, "_00e6__0089__0093__00e5__008d__00b0_", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  luoyan_env_bind(env, "_00e8__00af__00bb__00e5__008f__0096_", luoyan_function_create(luoyan_builtin_read, env, "读取"));
  
  // 用户程序
luoyan_env_bind(env, "x", luoyan_int(42L));
luoyan_env_bind(env, "y", luoyan_string("你好世界"));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "x"));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "y"));
luoyan_env_bind(env, "sum", luoyan_add(luoyan_env_lookup(env, "x"), luoyan_int(8L)));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "sum"));

  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  return 0;
}
