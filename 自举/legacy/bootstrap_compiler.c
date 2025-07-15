#include "luoyan_runtime.h"

luoyan_value_t* luoyan_var_func_0_impl_程序名(luoyan_env_t* env, luoyan_value_t* arg) {
  luoyan_env_bind(env, "_00e7__00a8__008b__00e5__00ba__008f__00e5__0090__008d_", arg);
  return ({ luoyan_env_bind(env, "_00e6__00b6__0088__00e6__0081__00af_1", luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_string("开始编译..."))); ({ luoyan_env_bind(env, "_00e6__00b6__0088__00e6__0081__00af_2", luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_string("生成C代码:"))); ({ luoyan_env_bind(env, "_00e6__00b6__0088__00e6__0081__00af_3", luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e7__0094__009f__00e6__0088__0090_C_00e5__00a4__00b4__00e9__0083__00a8_"))); luoyan_string("编译完成"); }); }); });
}

int main() {
  luoyan_runtime_init();
  luoyan_env_t* env = luoyan_env_create(NULL);

  // 添加内置函数
  luoyan_env_bind(env, "_00e6__0089__0093__00e5__008d__00b0_", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  luoyan_env_bind(env, "_00e8__00af__00bb__00e5__008f__0096_", luoyan_function_create(luoyan_builtin_read, env, "读取"));
  luoyan_env_bind(env, "_00e5__00ad__0097__00e7__00ac__00a6__00e4__00b8__00b2__00e8__00bf__009e__00e6__008e__00a5_", luoyan_function_create(luoyan_builtin_string_concat, env, "字符串连接"));

  // 用户程序
luoyan_env_bind(env, "_00e7__0094__009f__00e6__0088__0090_C_00e5__00a4__00b4__00e9__0083__00a8_", luoyan_string("#include <stdio.h>\nint main() {\n    printf(\"你好，来自骆言自举编译器！\\n\");\n    return 0;\n}\n"));
luoyan_env_bind(env, "_00e7__00bc__0096__00e8__00af__0091__00e7__00a8__008b__00e5__00ba__008f_", luoyan_function_create(luoyan_var_func_0_impl_程序名, env, "luoyan_var_func_0"));
luoyan_env_bind(env, "_00e7__00bb__0093__00e6__009e__009c_", luoyan_function_call(luoyan_env_lookup(env, "_00e7__00bc__0096__00e8__00af__0091__00e7__00a8__008b__00e5__00ba__008f_"), luoyan_string("hello.luoyan")));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e7__00bb__0093__00e6__009e__009c_"));


  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  return 0;
}
