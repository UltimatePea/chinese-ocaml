#include "c_backend/runtime/luoyan_runtime.h"
#include <stdio.h>

int main() {
  printf("Starting program...\n");
  luoyan_runtime_init();
  printf("Runtime initialized\n");
  
  luoyan_env_t* env = luoyan_env_create(NULL);
  printf("Environment created\n");
  
  // Test basic print function
  luoyan_env_bind(env, "_00e6__0089__0093__00e5__008d__00b0_", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  printf("Print function bound\n");
  
  // Test simple print call
  luoyan_value_t* print_func = luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_");
  if (print_func) {
    printf("Print function found\n");
    luoyan_value_t* test_str = luoyan_string("Hello World!");
    luoyan_value_t* result = luoyan_function_call(print_func, test_str);
    printf("Function call completed\n");
  } else {
    printf("Print function not found\n");
  }
  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  printf("Program completed\n");
  return 0;
}