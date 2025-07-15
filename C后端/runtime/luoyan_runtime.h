/**
 * 骆言编程语言运行时系统头文件
 * Luoyan Programming Language Runtime System Header
 */

#ifndef LUOYAN_RUNTIME_H
#define LUOYAN_RUNTIME_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

/* 基础类型定义 */
typedef int64_t luoyan_int_t;
typedef double luoyan_float_t;
typedef bool luoyan_bool_t;

/* 运行时值类型枚举 */
typedef enum {
    LUOYAN_INT,
    LUOYAN_FLOAT,
    LUOYAN_STRING,
    LUOYAN_BOOL,
    LUOYAN_LIST,
    LUOYAN_FUNCTION,
    LUOYAN_UNIT,
    LUOYAN_RECORD,
    LUOYAN_ARRAY,
    LUOYAN_REF,
    LUOYAN_CONSTRUCTOR,
    LUOYAN_OBJECT,
    LUOYAN_CLASS
} luoyan_value_type_t;

/* 前向声明 */
typedef struct luoyan_value luoyan_value_t;
typedef struct luoyan_string luoyan_string_t;
typedef struct luoyan_list luoyan_list_t;
typedef struct luoyan_function luoyan_function_t;
typedef struct luoyan_env luoyan_env_t;
typedef struct luoyan_record luoyan_record_t;
typedef struct luoyan_array luoyan_array_t;
typedef struct luoyan_ref luoyan_ref_t;
typedef struct luoyan_constructor luoyan_constructor_t;
typedef struct luoyan_object luoyan_object_t;
typedef struct luoyan_class luoyan_class_t;
typedef struct luoyan_method luoyan_method_t;

/* 字符串结构 */
struct luoyan_string {
    char* data;
    size_t length;
    size_t capacity;
    int ref_count;
};

/* 列表节点结构 */
typedef struct luoyan_list_node {
    luoyan_value_t* value;
    struct luoyan_list_node* next;
} luoyan_list_node_t;

/* 列表结构 */
struct luoyan_list {
    luoyan_list_node_t* head;
    luoyan_list_node_t* tail;
    size_t length;
    int ref_count;
};

/* 记录字段结构 */
typedef struct luoyan_record_field {
    char* name;
    luoyan_value_t* value;
    struct luoyan_record_field* next;
} luoyan_record_field_t;

/* 记录结构 */
struct luoyan_record {
    luoyan_record_field_t* fields;
    size_t field_count;
    int ref_count;
};

/* 数组结构 */
struct luoyan_array {
    luoyan_value_t** elements;
    size_t length;
    size_t capacity;
    int ref_count;
};

/* 引用结构 */
struct luoyan_ref {
    luoyan_value_t* value;
    int ref_count;
};

/* 构造器结构 */
struct luoyan_constructor {
    char* name;
    luoyan_value_t* args;
    int ref_count;
};

/* 方法结构 */
struct luoyan_method {
    char* name;
    luoyan_value_t* (*impl)(luoyan_env_t* env, luoyan_value_t** args, int argc);
    int param_count;
    char** param_names;
    int ref_count;
};

/* 类结构 */
struct luoyan_class {
    char* name;
    char* superclass_name;
    char** field_names;
    int field_count;
    luoyan_method_t** methods;
    int method_count;
    int ref_count;
};

/* 对象结构 */
struct luoyan_object {
    char* class_name;
    luoyan_value_t** fields;        /* 字段值数组 */
    luoyan_method_t** methods;      /* 方法数组 */
    int field_count;
    int method_count;
    int ref_count;
};

/* 环境结构 */
typedef struct luoyan_env_entry {
    char* name;
    luoyan_value_t* value;
    struct luoyan_env_entry* next;
} luoyan_env_entry_t;

struct luoyan_env {
    luoyan_env_entry_t* entries;
    struct luoyan_env* parent;
    int ref_count;
};

/* 函数结构 */
struct luoyan_function {
    luoyan_value_t* (*func_ptr)(luoyan_env_t* env, luoyan_value_t* arg);
    luoyan_env_t* closure_env;
    char* name;
    int ref_count;
};

/* 运行时值结构 */
struct luoyan_value {
    luoyan_value_type_t type;
    union {
        luoyan_int_t int_val;
        luoyan_float_t float_val;
        luoyan_string_t* string_val;
        luoyan_bool_t bool_val;
        luoyan_list_t* list_val;
        luoyan_function_t* function_val;
        luoyan_record_t* record_val;
        luoyan_array_t* array_val;
        luoyan_ref_t* ref_val;
        luoyan_constructor_t* constructor_val;
        luoyan_object_t* object_val;
        luoyan_class_t* class_val;
    } data;
    int ref_count;
};

/* 基础值创建函数 */
luoyan_value_t* luoyan_int(luoyan_int_t value);
luoyan_value_t* luoyan_float(luoyan_float_t value);
luoyan_value_t* luoyan_string(const char* str);
luoyan_value_t* luoyan_bool(luoyan_bool_t value);
luoyan_value_t* luoyan_unit(void);
luoyan_value_t* luoyan_list_empty(void);
luoyan_value_t* luoyan_record_empty(void);

/* 数组创建函数 */
luoyan_value_t* luoyan_array_empty(void);
luoyan_value_t* luoyan_array_create(size_t capacity);
luoyan_value_t* luoyan_array_from_values(luoyan_value_t** values, size_t count);

/* 引用创建函数 */
luoyan_value_t* luoyan_ref_create(luoyan_value_t* value);

/* 构造器创建函数 */
luoyan_value_t* luoyan_constructor_create(const char* name, luoyan_value_t* args);

/* 面向对象创建函数 */
luoyan_value_t* luoyan_class_create(const char* name, const char* superclass_name,
                                   char** field_names, int field_count);
luoyan_value_t* luoyan_object_create(const char* class_name, luoyan_value_t** field_values, int field_count);
luoyan_value_t* luoyan_method_call(luoyan_value_t* object, const char* method_name,
                                  luoyan_value_t** args, int argc);
void luoyan_class_add_method(luoyan_value_t* class_val, const char* method_name,
                            luoyan_value_t* (*impl)(luoyan_env_t* env, luoyan_value_t** args, int argc),
                            int param_count, char** param_names);

/* 全局类表 */
extern luoyan_value_t* luoyan_global_class_table;

/* 设置全局方法环境 */
void luoyan_set_global_env(luoyan_env_t* env);

/* 引用计数管理 */
luoyan_value_t* luoyan_retain(luoyan_value_t* value);
void luoyan_release(luoyan_value_t* value);

/* 值操作函数 */
bool luoyan_equals(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_copy(luoyan_value_t* value);
void luoyan_print_value(luoyan_value_t* value);

/* 算术运算 */
luoyan_value_t* luoyan_add(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_subtract(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_multiply(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_divide(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_modulo(luoyan_value_t* a, luoyan_value_t* b);

/* 比较运算 */
luoyan_value_t* luoyan_equal(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_not_equal(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_less_than(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_less_equal(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_greater_than(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_greater_equal(luoyan_value_t* a, luoyan_value_t* b);

/* 逻辑运算 */
luoyan_value_t* luoyan_logical_and(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_logical_or(luoyan_value_t* a, luoyan_value_t* b);
luoyan_value_t* luoyan_logical_not(luoyan_value_t* a);

/* 列表操作 */
luoyan_value_t* luoyan_list_cons(luoyan_value_t* head, luoyan_value_t* tail);
luoyan_value_t* luoyan_list_head(luoyan_value_t* list);
luoyan_value_t* luoyan_list_tail(luoyan_value_t* list);
luoyan_value_t* luoyan_list_is_empty(luoyan_value_t* list);
luoyan_value_t* luoyan_list_length(luoyan_value_t* list);

/* 记录操作 */
luoyan_value_t* luoyan_record_create(void);
luoyan_value_t* luoyan_record_set_field(luoyan_value_t* record, const char* field_name, luoyan_value_t* value);
luoyan_value_t* luoyan_record_get_field(luoyan_value_t* record, const char* field_name);
luoyan_value_t* luoyan_record_has_field(luoyan_value_t* record, const char* field_name);
luoyan_value_t* luoyan_record_update(luoyan_value_t* record, const char* field_name, luoyan_value_t* value);

/* 数组操作 */
luoyan_value_t* luoyan_array_get(luoyan_value_t* array, luoyan_value_t* index);
luoyan_value_t* luoyan_array_set(luoyan_value_t* array, size_t index, luoyan_value_t* value);
luoyan_value_t* luoyan_array_update(luoyan_value_t* array, luoyan_value_t* index, luoyan_value_t* value);
luoyan_value_t* luoyan_array_length(luoyan_value_t* array);
luoyan_value_t* luoyan_array_push(luoyan_value_t* array, luoyan_value_t* value);

/* 引用操作 */
luoyan_value_t* luoyan_ref_get(luoyan_value_t* ref);
luoyan_value_t* luoyan_ref_set(luoyan_value_t* ref, luoyan_value_t* value);

/* 函数操作 */
luoyan_value_t* luoyan_function_create(
    luoyan_value_t* (*func_ptr)(luoyan_env_t*, luoyan_value_t*),
    luoyan_env_t* closure_env,
    const char* name
);
luoyan_value_t* luoyan_function_call(luoyan_value_t* func, luoyan_value_t* arg);

/* 环境操作 */
luoyan_env_t* luoyan_env_create(luoyan_env_t* parent);
void luoyan_env_bind(luoyan_env_t* env, const char* name, luoyan_value_t* value);
luoyan_value_t* luoyan_env_lookup(luoyan_env_t* env, const char* name);
luoyan_env_t* luoyan_env_retain(luoyan_env_t* env);
void luoyan_env_release(luoyan_env_t* env);

/* 内置函数 */
luoyan_value_t* luoyan_builtin_print(luoyan_env_t* env, luoyan_value_t* arg);
luoyan_value_t* luoyan_builtin_read(luoyan_env_t* env, luoyan_value_t* arg);

/* 文件I/O函数 */
luoyan_value_t* luoyan_builtin_read_file(luoyan_env_t* env, luoyan_value_t* arg);
luoyan_value_t* luoyan_builtin_write_file(luoyan_env_t* env, luoyan_value_t* arg);
luoyan_value_t* luoyan_builtin_file_exists(luoyan_env_t* env, luoyan_value_t* arg);

/* 系统函数 */
luoyan_value_t* luoyan_builtin_system_args(luoyan_env_t* env, luoyan_value_t* arg);
luoyan_value_t* luoyan_builtin_system_exit(luoyan_env_t* env, luoyan_value_t* arg);

/* 字符串工具函数 */
luoyan_value_t* luoyan_builtin_string_length(luoyan_env_t* env, luoyan_value_t* arg);
luoyan_value_t* luoyan_builtin_string_concat(luoyan_env_t* env, luoyan_value_t* arg);
luoyan_value_t* luoyan_builtin_int_to_string(luoyan_env_t* env, luoyan_value_t* arg);
luoyan_value_t* luoyan_builtin_string_to_int(luoyan_env_t* env, luoyan_value_t* arg);

/* 运行时初始化和清理 */
void luoyan_runtime_init(void);
void luoyan_runtime_cleanup(void);

/* 系统参数设置 */
void luoyan_set_system_args(int argc, char** argv);

/* 错误处理 */
typedef enum {
    LUOYAN_OK,
    LUOYAN_ERROR_TYPE_MISMATCH,
    LUOYAN_ERROR_DIVISION_BY_ZERO,
    LUOYAN_ERROR_NULL_POINTER,
    LUOYAN_ERROR_OUT_OF_MEMORY,
    LUOYAN_ERROR_UNDEFINED_VARIABLE,
    LUOYAN_ERROR_INVALID_FUNCTION_CALL,
    LUOYAN_ERROR_FIELD_NOT_FOUND
} luoyan_error_t;

extern luoyan_error_t luoyan_last_error;
void luoyan_set_error(luoyan_error_t error);
const char* luoyan_error_string(luoyan_error_t error);

/* 调试支持 */
#ifdef LUOYAN_DEBUG
void luoyan_debug_print(const char* format, ...);
void luoyan_debug_value(luoyan_value_t* value);
#else
#define luoyan_debug_print(...)
#define luoyan_debug_value(...)
#endif

#endif /* LUOYAN_RUNTIME_H */