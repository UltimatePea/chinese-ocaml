#include "c_backend/runtime/luoyan_runtime.h"
#include <stdio.h>

// Method that accesses a field
luoyan_value_t* field_access_method(luoyan_env_t* env, luoyan_value_t** args, int argc) {
  printf("Method called, looking for field...\n");
  
  // Look for the field in the environment
  luoyan_value_t* field_val = luoyan_env_lookup(env, "_00e9__0097__00ae__00e5__0080__0099__00e8__00af__00ad_");
  if (field_val) {
    printf("Field found: ");
    luoyan_print_value(field_val);
    printf("\n");
    
    // Try to call print function
    luoyan_value_t* print_func = luoyan_env_lookup(env, "_00e6__0089__0093__00e5__008d__00b0_");
    if (print_func) {
      printf("Print function found, calling...\n");
      return luoyan_function_call(print_func, field_val);
    } else {
      printf("Print function not found\n");
      return luoyan_unit();
    }
  } else {
    printf("Field not found in environment\n");
    return luoyan_unit();
  }
}

int main() {
  printf("Starting field access debug test...\n");
  luoyan_runtime_init();
  luoyan_env_t* env = luoyan_env_create(NULL);
  
  // Add print function to global environment
  luoyan_env_bind(env, "_00e6__0089__0093__00e5__008d__00b0_", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  
  // Create class with field name matching our test
  char* field_names[] = {"_00e9__0097__00ae__00e5__0080__0099__00e8__00af__00ad_"};
  luoyan_value_t* class_val = luoyan_class_create("_00e9__0097__00ae__00e5__0080__0099__00e5__0099__00a8_", NULL, field_names, 1);
  printf("Class created\n");
  
  // Add method to class
  luoyan_class_add_method(class_val, "_00e9__0097__00ae__00e5__0080__0099_", field_access_method, 0, NULL);
  printf("Method added\n");
  
  // Create object with field value
  luoyan_value_t* field_values[] = {luoyan_string("你好，世界！")};
  luoyan_value_t* object = luoyan_object_create("_00e9__0097__00ae__00e5__0080__0099__00e5__0099__00a8_", field_values, 1);
  printf("Object created\n");
  
  // Call method
  printf("Calling method...\n");
  luoyan_value_t* result = luoyan_method_call(object, "_00e9__0097__00ae__00e5__0080__0099_", NULL, 0);
  printf("Method call completed\n");
  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  printf("Test completed\n");
  return 0;
}