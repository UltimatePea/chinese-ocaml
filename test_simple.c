#include "luoyan_runtime.h"

luoyan_value_t* luoyan_var_func_0_impl_n(luoyan_env_t* env, luoyan_value_t* arg) {
  luoyan_env_bind(env, "n", arg);
  return ({ luoyan_value_t* luoyan_var_cond_1 = luoyan_less_equal(luoyan_env_lookup(env, "n"), luoyan_int(0L)); ((luoyan_var_cond_1->type == LUOYAN_BOOL && luoyan_var_cond_1->data.bool_val)) ? (luoyan_int(0L)) : (luoyan_add(luoyan_env_lookup(env, "n"), luoyan_function_call(luoyan_env_lookup(env, "_00e7__00b4__00af__00e5__008a__00a0_"), luoyan_subtract(luoyan_env_lookup(env, "n"), luoyan_int(1L))))); });
}

luoyan_value_t* luoyan_var_func_2_impl_n(luoyan_env_t* env, luoyan_value_t* arg) {
  luoyan_env_bind(env, "n", arg);
  return ({ luoyan_value_t* luoyan_var_cond_3 = luoyan_less_equal(luoyan_env_lookup(env, "n"), luoyan_int(1L)); ((luoyan_var_cond_3->type == LUOYAN_BOOL && luoyan_var_cond_3->data.bool_val)) ? (luoyan_int(1L)) : (luoyan_multiply(luoyan_env_lookup(env, "n"), luoyan_function_call(luoyan_env_lookup(env, "_00e7__00b4__00af__00e4__00b9__0098_"), luoyan_subtract(luoyan_env_lookup(env, "n"), luoyan_int(1L))))); });
}

int main() {
  luoyan_runtime_init();
  luoyan_env_t* env = luoyan_env_create(NULL);
  
  // 添加内置函数
  luoyan_env_bind(env, "打印", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  luoyan_env_bind(env, "读取", luoyan_function_create(luoyan_builtin_read, env, "读取"));
  
  // 用户程序
luoyan_env_bind(env, "_00e7__00b4__00af__00e5__008a__00a0_", luoyan_unit()); luoyan_env_bind(env, "_00e7__00b4__00af__00e5__008a__00a0_", luoyan_function_create(luoyan_var_func_0_impl_n, env, "luoyan_var_func_0"));
luoyan_env_bind(env, "_00e7__00b4__00af__00e4__00b9__0098_", luoyan_unit()); luoyan_env_bind(env, "_00e7__00b4__00af__00e4__00b9__0098_", luoyan_function_create(luoyan_var_func_2_impl_n, env, "luoyan_var_func_2"));
luoyan_env_bind(env, "_00e6__00b5__008b__00e8__00af__0095__00e8__00a7__0084__00e6__00a8__00a1_", luoyan_int(20L));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_string("\229\188\128\229\167\139\229\159\186\229\135\134\230\181\139\232\175\149"));
luoyan_env_bind(env, "_00e7__00bb__0093__00e6__009e__009c_1", luoyan_function_call(luoyan_env_lookup(env, "_00e7__00b4__00af__00e5__008a__00a0_"), luoyan_env_lookup(env, "_00e6__00b5__008b__00e8__00af__0095__00e8__00a7__0084__00e6__00a8__00a1_")));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_string("\231\180\175\229\138\160\231\187\147\230\158\156:"));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e7__00bb__0093__00e6__009e__009c_1"));
luoyan_env_bind(env, "_00e7__00bb__0093__00e6__009e__009c_2", luoyan_function_call(luoyan_env_lookup(env, "_00e7__00b4__00af__00e4__00b9__0098_"), luoyan_int(8L)));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_string("\231\180\175\228\185\152\231\187\147\230\158\156:"));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e7__00bb__0093__00e6__009e__009c_2"));
luoyan_env_bind(env, "_00e6__0080__00bb__00e7__00bb__0093__00e6__009e__009c_", luoyan_add(luoyan_env_lookup(env, "_00e7__00bb__0093__00e6__009e__009c_1"), luoyan_env_lookup(env, "_00e7__00bb__0093__00e6__009e__009c_2")));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_string("\230\128\187\231\187\147\230\158\156:"));
luoyan_function_call(luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_"), luoyan_env_lookup(env, "_00e6__0080__00bb__00e7__00bb__0093__00e6__009e__009c_"));

  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  return 0;
}
