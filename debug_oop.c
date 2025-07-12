#include "c_backend/runtime/luoyan_runtime.h"
#include <stdio.h>

// Simple method implementation for testing
luoyan_value_t* test_method_impl(luoyan_env_t* env, luoyan_value_t** args, int argc) {
  printf("Method called with %d args\n", argc);
  return luoyan_string("Method result");
}

int main() {
  printf("Starting OOP debug test...\n");
  luoyan_runtime_init();
  luoyan_env_t* env = luoyan_env_create(NULL);
  
  // Add print function
  luoyan_env_bind(env, "_00e6__0089__0093__00e5__008d__00b0_", luoyan_function_create(luoyan_builtin_print, env, "打印"));
  
  printf("Testing class creation...\n");
  char* field_names[] = {"field1"};
  luoyan_value_t* class_val = luoyan_class_create("TestClass", NULL, field_names, 1);
  if (class_val) {
    printf("Class created successfully\n");
    
    printf("Adding method to class...\n");
    char* param_names[] = {};
    luoyan_class_add_method(class_val, "test_method", test_method_impl, 0, param_names);
    printf("Method added\n");
    
    printf("Creating object...\n");
    luoyan_value_t* field_values[] = {luoyan_string("field value")};
    luoyan_value_t* object = luoyan_object_create("TestClass", field_values, 1);
    if (object) {
      printf("Object created successfully\n");
      
      printf("Calling method...\n");
      luoyan_value_t* result = luoyan_method_call(object, "test_method", NULL, 0);
      if (result) {
        printf("Method call succeeded\n");
        luoyan_print_value(result);
        printf("\n");
      } else {
        printf("Method call failed\n");
      }
    } else {
      printf("Object creation failed\n");
    }
  } else {
    printf("Class creation failed\n");
  }
  
  luoyan_env_release(env);
  luoyan_runtime_cleanup();
  printf("Debug test completed\n");
  return 0;
}