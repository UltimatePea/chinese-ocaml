#include "luoyan_runtime.h"

luoyan_value_t* luoyan_var_func_0_impl_列表(luoyan_env_t* env, luoyan_value_t* arg) {
  luoyan_env_bind(env, "_00e5__0088__0097__00e8__00a1__00a8_", arg);
  return ({ luoyan_value_t* luoyan_var_match_expr_1 = luoyan_env_lookup(env, "_00e5__0088__0097__00e8__00a1__00a8_"); (luoyan_list_is_empty(luoyan_var_match_expr_1)->data.bool_val) ? (luoyan_string("空列表")) : (((luoyan_env_bind(env, "_00e5__0085__00b6__00e4__00bb__0096_", luoyan_var_match_expr_1), true)) ? (luoyan_string("非空列表")) : (luoyan_unit())); });
}

int main() {
  luoyan_runtime_init();
  luoyan_env_t* env = luoyan_env_create(NULL);
  
  // 添加内置函数
  luoyan_env_bind(env, "_00e6__0089__0093__00e5__008d__00b0_", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  luoyan_env_bind(env, "_00e8__00af__00bb__00e5__008f__0096_", luoyan_function_create(luoyan_builtin_read, env, "读取"));
  
  // 用户程序
luoyan_env_bind(env, "_00e6__00b5__008b__00e8__00af__0095__00e5__0088__0097__00e8__00a1__00a8_", luoyan_function_create(luoyan_var_func_0_impl_列表, env, "luoyan_var_func_0"));
luoyan_env_bind(env, "_00e7__00bb__0093__00e6__009e__009c_1", luoyan_env_lookup(env, "_00e6__00b5__008b__00e8__00af__0095__00e5__0088__0097__00e8__00a1__00a8_"));
luoyan_list_empty();
luoyan_env_bind(env, "_00e7__00bb__0093__00e6__009e__009c_2", luoyan_env_lookup(env, "_00e6__00b5__008b__00e8__00af__0095__00e5__0088__0097__00e8__00a1__00a8_"));
luoyan_list_cons(luoyan_string("hello"), luoyan_list_empty());
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e7__00bb__0093__00e6__009e__009c_1"));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e7__00bb__0093__00e6__009e__009c_2"));

  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  return 0;
}
