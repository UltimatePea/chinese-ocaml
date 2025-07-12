#include "luoyan_runtime.h"

luoyan_value_t* luoyan_var_func_0_impl_s1(luoyan_env_t* env, luoyan_value_t* arg) {
  luoyan_env_bind(env, "s1", arg);
  return luoyan_function_create(luoyan_var_func_1_impl_s2, env, "luoyan_var_func_1");
}

luoyan_value_t* luoyan_var_func_2_impl_程序名(luoyan_env_t* env, luoyan_value_t* arg) {
  luoyan_env_bind(env, "_00e7__00a8__008b__00e5__00ba__008f__00e5__0090__008d_", arg);
  return ({ luoyan_env_bind(env, "_00e5__00a4__00b4__00e9__0083__00a8_", luoyan_string("#include <stdio.h>\n")); ({ luoyan_env_bind(env, "_00e4__00b8__00bb__00e5__0087__00bd__00e6__0095__00b0__00e5__00bc__0080__00e5__00a7__008b_", luoyan_string("int main() {\n")); ({ luoyan_env_bind(env, "_00e6__0089__0093__00e5__008d__00b0__00e8__00af__00ad__00e5__008f__00a5_", luoyan_string("    printf(\"你好，来自骆言自举编译器！\\n\");\n")); ({ luoyan_env_bind(env, "_00e8__00bf__0094__00e5__009b__009e__00e8__00af__00ad__00e5__008f__00a5_", luoyan_string("    return 0;\n")); ({ luoyan_env_bind(env, "_00e4__00b8__00bb__00e5__0087__00bd__00e6__0095__00b0__00e7__00bb__0093__00e6__009d__009f_", luoyan_string("}\n")); luoyan_function_call(luoyan_env_lookup(env, "_00e8__00bf__009e__00e6__008e__00a5_"), luoyan_function_call(luoyan_env_lookup(env, "_00e5__00a4__00b4__00e9__0083__00a8_"), luoyan_function_call(luoyan_env_lookup(env, "_00e8__00bf__009e__00e6__008e__00a5_"), luoyan_function_call(luoyan_env_lookup(env, "_00e4__00b8__00bb__00e5__0087__00bd__00e6__0095__00b0__00e5__00bc__0080__00e5__00a7__008b_"), luoyan_function_call(luoyan_env_lookup(env, "_00e8__00bf__009e__00e6__008e__00a5_"), luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0__00e8__00af__00ad__00e5__008f__00a5_"), luoyan_function_call(luoyan_env_lookup(env, "_00e8__00bf__009e__00e6__008e__00a5_"), luoyan_function_call(luoyan_env_lookup(env, "_00e8__00bf__0094__00e5__009b__009e__00e8__00af__00ad__00e5__008f__00a5_"), luoyan_env_lookup(env, "_00e4__00b8__00bb__00e5__0087__00bd__00e6__0095__00b0__00e7__00bb__0093__00e6__009d__009f_"))))))))); }); }); }); }); });
}

luoyan_value_t* luoyan_var_func_3_impl_输入文件(luoyan_env_t* env, luoyan_value_t* arg) {
  luoyan_env_bind(env, "_00e8__00be__0093__00e5__0085__00a5__00e6__0096__0087__00e4__00bb__00b6_", arg);
  return luoyan_function_create(luoyan_var_func_4_impl_输出文件, env, "luoyan_var_func_4");
}

luoyan_value_t* luoyan_var_func_5_impl_参数列表(luoyan_env_t* env, luoyan_value_t* arg) {
  luoyan_env_bind(env, "_00e5__008f__0082__00e6__0095__00b0__00e5__0088__0097__00e8__00a1__00a8_", arg);
  return ({ luoyan_value_t* luoyan_var_match_expr_6 = luoyan_env_lookup(env, "_00e5__008f__0082__00e6__0095__00b0__00e5__0088__0097__00e8__00a1__00a8_"); (luoyan_list_is_empty(luoyan_var_match_expr_6)->data.bool_val) ? (luoyan_string("用法: 编译器 输入文件 [输出文件]")) : (((luoyan_env_bind(env, "_00e5__0085__00b6__00e4__00bb__0096_", luoyan_var_match_expr_6), true)) ? (luoyan_function_call(luoyan_function_call(luoyan_env_lookup(env, "_00e7__00bc__0096__00e8__00af__0091__00e6__0096__0087__00e4__00bb__00b6_"), luoyan_string("hello.luoyan")), luoyan_string("output.c"))) : (luoyan_unit())); });
}

int main() {
  luoyan_runtime_init();
  luoyan_env_t* env = luoyan_env_create(NULL);
  
  // 添加内置函数
  luoyan_env_bind(env, "_00e6__0089__0093__00e5__008d__00b0_", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  luoyan_env_bind(env, "_00e8__00af__00bb__00e5__008f__0096_", luoyan_function_create(luoyan_builtin_read, env, "读取"));
  
  // 用户程序
luoyan_env_bind(env, "_00e8__00bf__009e__00e6__008e__00a5_", luoyan_function_create(luoyan_var_func_0_impl_s1, env, "luoyan_var_func_0"));
luoyan_env_bind(env, "_00e7__0094__009f__00e6__0088__0090_C_00e4__00bb__00a3__00e7__00a0__0081_", luoyan_function_create(luoyan_var_func_2_impl_程序名, env, "luoyan_var_func_2"));
luoyan_env_bind(env, "_00e7__00bc__0096__00e8__00af__0091__00e6__0096__0087__00e4__00bb__00b6_", luoyan_function_create(luoyan_var_func_3_impl_输入文件, env, "luoyan_var_func_3"));
luoyan_env_bind(env, "_00e5__00a4__0084__00e7__0090__0086__00e5__0091__00bd__00e4__00bb__00a4__00e8__00a1__008c_", luoyan_function_create(luoyan_var_func_5_impl_参数列表, env, "luoyan_var_func_5"));
luoyan_env_bind(env, "_00e7__00bb__0093__00e6__009e__009c_", luoyan_env_lookup(env, "_00e5__00a4__0084__00e7__0090__0086__00e5__0091__00bd__00e4__00bb__00a4__00e8__00a1__008c_"));
luoyan_list_cons(luoyan_string("hello.luoyan"), luoyan_list_empty());
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e7__00bb__0093__00e6__009e__009c_"));

  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  return 0;
}
