#include "luoyan_runtime.h"

luoyan_value_t* luoyan_var_func_1_impl_介绍(luoyan_env_t* env, luoyan_value_t** args, int argc) {
  
  return luoyan_function_call(luoyan_env_lookup(env, "打印"), luoyan_string("我是一个人"));
}

luoyan_value_t* luoyan_var_func_2_impl_说年龄(luoyan_env_t* env, luoyan_value_t** args, int argc) {
  
  return luoyan_function_call(luoyan_env_lookup(env, "打印"), luoyan_env_lookup(env, "年龄"));
}

int main() {
  luoyan_runtime_init();
  luoyan_env_t* env = luoyan_env_create(NULL);
  
  // 添加内置函数
  luoyan_env_bind(env, "打印", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  luoyan_env_bind(env, "读取", luoyan_function_create(luoyan_builtin_read, env, "读取"));
  luoyan_env_bind(env, "字符串连接", luoyan_function_create(luoyan_builtin_string_concat, env, "字符串连接"));
  luoyan_env_bind(env, "读取文件", luoyan_function_create(luoyan_builtin_read_file, env, "读取文件"));
  luoyan_env_bind(env, "写入文件", luoyan_function_create(luoyan_builtin_write_file, env, "写入文件"));
  luoyan_env_bind(env, "文件存在", luoyan_function_create(luoyan_builtin_file_exists, env, "文件存在"));
  
  // 设置全局环境供方法调用使用
  luoyan_set_global_env(env);
  
  // 用户程序
luoyan_env_bind(env, "人", ({ luoyan_value_t* luoyan_var_class_0 = luoyan_class_create("人", NULL, ((char*[]){"姓名", "年龄"}), 2); luoyan_class_add_method(luoyan_var_class_0, "介绍", luoyan_var_func_1_impl_介绍, 0, NULL); luoyan_class_add_method(luoyan_var_class_0, "说年龄", luoyan_var_func_2_impl_说年龄, 0, NULL); luoyan_var_class_0; }));
luoyan_env_bind(env, "张三", ({ luoyan_value_t** luoyan_var_field_values_3 = malloc(sizeof(luoyan_value_t*) * 2); luoyan_var_field_values_3[0] = luoyan_string("张三"); luoyan_var_field_values_3[1] = luoyan_int(25L); luoyan_object_create("人", luoyan_var_field_values_3, 2); }));
luoyan_method_call(luoyan_env_lookup(env, "张三"), "介绍", NULL, 0);
luoyan_method_call(luoyan_env_lookup(env, "张三"), "说年龄", NULL, 0);

  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  return 0;
}
