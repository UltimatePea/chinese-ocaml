#include "luoyan_runtime.h"

luoyan_value_t* luoyan_var_func_1_impl_问候(luoyan_env_t* env, luoyan_value_t** args, int argc) {
  
  return luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e9__0097__00ae__00e5__0080__0099__00e8__00af__00ad_"));
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
  
  // 设置全局环境供方法调用使用
  luoyan_set_global_env(env);
  
  // 用户程序
luoyan_env_bind(env, "_00e9__0097__00ae__00e5__0080__0099__00e5__0099__00a8_", ({ luoyan_value_t* luoyan_var_class_0 = luoyan_class_create("_00e9__0097__00ae__00e5__0080__0099__00e5__0099__00a8_", NULL, ((char*[]){"_00e9__0097__00ae__00e5__0080__0099__00e8__00af__00ad_"}), 1); luoyan_class_add_method(luoyan_var_class_0, "_00e9__0097__00ae__00e5__0080__0099_", luoyan_var_func_1_impl_问候, 0, NULL); luoyan_var_class_0; }));
luoyan_env_bind(env, "_00e4__00b8__00ad__00e6__0096__0087__00e9__0097__00ae__00e5__0080__0099__00e5__0099__00a8_", ({ luoyan_value_t** luoyan_var_field_values_2 = malloc(sizeof(luoyan_value_t*) * 1); luoyan_var_field_values_2[0] = luoyan_string("你好，世界！"); luoyan_object_create("_00e9__0097__00ae__00e5__0080__0099__00e5__0099__00a8_", luoyan_var_field_values_2, 1); }));
luoyan_method_call(luoyan_env_lookup(env, "_00e4__00b8__00ad__00e6__0096__0087__00e9__0097__00ae__00e5__0080__0099__00e5__0099__00a8_"), "_00e9__0097__00ae__00e5__0080__0099_", NULL, 0);

  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  return 0;
}
