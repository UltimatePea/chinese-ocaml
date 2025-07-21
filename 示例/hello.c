#include <luoyan_runtime.h>



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
  
  luoyan_string(":骆言示例程序:你好世界:");
luoyan_env_bind(env, "问候", luoyan_string("你好,世界!"));
luoyan_call(luoyan_env_lookup(env, "打印"), 1, luoyan_env_lookup(env, "问候"));
  
  luoyan_env_destroy(env);
  return 0;
}

