/**
 * 骆言编程语言运行时系统实现
 * Luoyan Programming Language Runtime System Implementation
 */

#include "luoyan_runtime.h"
#include <stdarg.h>

/* 全局错误状态 */
luoyan_error_t luoyan_last_error = LUOYAN_OK;

/* =============================================================================
 * 错误处理
 * ============================================================================= */

void luoyan_set_error(luoyan_error_t error) {
    luoyan_last_error = error;
}

const char* luoyan_error_string(luoyan_error_t error) {
    switch (error) {
        case LUOYAN_OK: return "OK";
        case LUOYAN_ERROR_TYPE_MISMATCH: return "Type mismatch";
        case LUOYAN_ERROR_DIVISION_BY_ZERO: return "Division by zero";
        case LUOYAN_ERROR_NULL_POINTER: return "Null pointer";
        case LUOYAN_ERROR_OUT_OF_MEMORY: return "Out of memory";
        case LUOYAN_ERROR_UNDEFINED_VARIABLE: return "Undefined variable";
        case LUOYAN_ERROR_INVALID_FUNCTION_CALL: return "Invalid function call";
        case LUOYAN_ERROR_FIELD_NOT_FOUND: return "Field not found";
        default: return "Unknown error";
    }
}

/* =============================================================================
 * 内存管理和引用计数
 * ============================================================================= */

static void* luoyan_malloc(size_t size) {
    void* ptr = malloc(size);
    if (!ptr) {
        luoyan_set_error(LUOYAN_ERROR_OUT_OF_MEMORY);
    }
    return ptr;
}

luoyan_value_t* luoyan_retain(luoyan_value_t* value) {
    if (value) {
        value->ref_count++;
    }
    return value;
}

void luoyan_release(luoyan_value_t* value) {
    if (!value || --value->ref_count > 0) {
        return;
    }
    
    switch (value->type) {
        case LUOYAN_STRING:
            if (value->data.string_val && --value->data.string_val->ref_count <= 0) {
                free(value->data.string_val->data);
                free(value->data.string_val);
            }
            break;
        case LUOYAN_LIST:
            if (value->data.list_val && --value->data.list_val->ref_count <= 0) {
                luoyan_list_node_t* node = value->data.list_val->head;
                while (node) {
                    luoyan_list_node_t* next = node->next;
                    luoyan_release(node->value);
                    free(node);
                    node = next;
                }
                free(value->data.list_val);
            }
            break;
        case LUOYAN_FUNCTION:
            if (value->data.function_val && --value->data.function_val->ref_count <= 0) {
                luoyan_env_release(value->data.function_val->closure_env);
                free(value->data.function_val->name);
                free(value->data.function_val);
            }
            break;
        case LUOYAN_RECORD:
            if (value->data.record_val && --value->data.record_val->ref_count <= 0) {
                luoyan_record_field_t* field = value->data.record_val->fields;
                while (field) {
                    luoyan_record_field_t* next = field->next;
                    luoyan_release(field->value);
                    free(field->name);
                    free(field);
                    field = next;
                }
                free(value->data.record_val);
            }
            break;
        case LUOYAN_CLASS:
            if (value->data.class_val && --value->data.class_val->ref_count <= 0) {
                luoyan_class_t* class_data = value->data.class_val;
                free(class_data->name);
                if (class_data->superclass_name) free(class_data->superclass_name);
                
                // 释放字段名
                for (int i = 0; i < class_data->field_count; i++) {
                    free(class_data->field_names[i]);
                }
                free(class_data->field_names);
                
                // 释放方法
                for (int i = 0; i < class_data->method_count; i++) {
                    luoyan_method_t* method = class_data->methods[i];
                    if (--method->ref_count <= 0) {
                        free(method->name);
                        if (method->param_names) {
                            for (int j = 0; j < method->param_count; j++) {
                                free(method->param_names[j]);
                            }
                            free(method->param_names);
                        }
                        free(method);
                    }
                }
                free(class_data->methods);
                free(class_data);
            }
            break;
        case LUOYAN_OBJECT:
            if (value->data.object_val && --value->data.object_val->ref_count <= 0) {
                luoyan_object_t* obj_data = value->data.object_val;
                free(obj_data->class_name);
                
                // 释放字段值
                for (int i = 0; i < obj_data->field_count; i++) {
                    luoyan_release(obj_data->fields[i]);
                }
                free(obj_data->fields);
                
                // 方法是共享的，不需要释放
                free(obj_data->methods);
                free(obj_data);
            }
            break;
        default:
            break;
    }
    
    free(value);
}

/* =============================================================================
 * 基础值创建函数
 * ============================================================================= */

luoyan_value_t* luoyan_int(luoyan_int_t value) {
    luoyan_value_t* val = luoyan_malloc(sizeof(luoyan_value_t));
    if (!val) return NULL;
    
    val->type = LUOYAN_INT;
    val->data.int_val = value;
    val->ref_count = 1;
    return val;
}

luoyan_value_t* luoyan_float(luoyan_float_t value) {
    luoyan_value_t* val = luoyan_malloc(sizeof(luoyan_value_t));
    if (!val) return NULL;
    
    val->type = LUOYAN_FLOAT;
    val->data.float_val = value;
    val->ref_count = 1;
    return val;
}

luoyan_value_t* luoyan_string(const char* str) {
    luoyan_value_t* val = luoyan_malloc(sizeof(luoyan_value_t));
    if (!val) return NULL;
    
    luoyan_string_t* string_obj = luoyan_malloc(sizeof(luoyan_string_t));
    if (!string_obj) {
        free(val);
        return NULL;
    }
    
    size_t len = strlen(str);
    string_obj->data = luoyan_malloc(len + 1);
    if (!string_obj->data) {
        free(string_obj);
        free(val);
        return NULL;
    }
    
    strcpy(string_obj->data, str);
    string_obj->length = len;
    string_obj->capacity = len + 1;
    string_obj->ref_count = 1;
    
    val->type = LUOYAN_STRING;
    val->data.string_val = string_obj;
    val->ref_count = 1;
    return val;
}

luoyan_value_t* luoyan_bool(luoyan_bool_t value) {
    luoyan_value_t* val = luoyan_malloc(sizeof(luoyan_value_t));
    if (!val) return NULL;
    
    val->type = LUOYAN_BOOL;
    val->data.bool_val = value;
    val->ref_count = 1;
    return val;
}

luoyan_value_t* luoyan_unit(void) {
    luoyan_value_t* val = luoyan_malloc(sizeof(luoyan_value_t));
    if (!val) return NULL;
    
    val->type = LUOYAN_UNIT;
    val->ref_count = 1;
    return val;
}

luoyan_value_t* luoyan_list_empty(void) {
    luoyan_value_t* val = luoyan_malloc(sizeof(luoyan_value_t));
    if (!val) return NULL;
    
    luoyan_list_t* list = luoyan_malloc(sizeof(luoyan_list_t));
    if (!list) {
        free(val);
        return NULL;
    }
    
    list->head = NULL;
    list->tail = NULL;
    list->length = 0;
    list->ref_count = 1;
    
    val->type = LUOYAN_LIST;
    val->data.list_val = list;
    val->ref_count = 1;
    return val;
}

/* =============================================================================
 * 值操作函数
 * ============================================================================= */

bool luoyan_equals(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) return false;
    if (a->type != b->type) return false;
    
    switch (a->type) {
        case LUOYAN_INT:
            return a->data.int_val == b->data.int_val;
        case LUOYAN_FLOAT:
            return a->data.float_val == b->data.float_val;
        case LUOYAN_STRING:
            return strcmp(a->data.string_val->data, b->data.string_val->data) == 0;
        case LUOYAN_BOOL:
            return a->data.bool_val == b->data.bool_val;
        case LUOYAN_UNIT:
            return true;
        case LUOYAN_LIST:
            // 简单的指针比较，更完整的实现需要递归比较
            return a->data.list_val == b->data.list_val;
        case LUOYAN_FUNCTION:
            return a->data.function_val == b->data.function_val;
        default:
            return false;
    }
}

luoyan_value_t* luoyan_copy(luoyan_value_t* value) {
    if (!value) return NULL;
    
    switch (value->type) {
        case LUOYAN_INT:
            return luoyan_int(value->data.int_val);
        case LUOYAN_FLOAT:
            return luoyan_float(value->data.float_val);
        case LUOYAN_STRING:
            return luoyan_string(value->data.string_val->data);
        case LUOYAN_BOOL:
            return luoyan_bool(value->data.bool_val);
        case LUOYAN_UNIT:
            return luoyan_unit();
        default:
            // 对于复杂类型，只是增加引用计数
            return luoyan_retain(value);
    }
}

void luoyan_print_value(luoyan_value_t* value) {
    if (!value) {
        printf("null");
        return;
    }
    
    switch (value->type) {
        case LUOYAN_INT:
            printf("%ld", (long)value->data.int_val);
            break;
        case LUOYAN_FLOAT:
            printf("%g", value->data.float_val);
            break;
        case LUOYAN_STRING:
            printf("%s", value->data.string_val->data);
            break;
        case LUOYAN_BOOL:
            printf("%s", value->data.bool_val ? "true" : "false");
            break;
        case LUOYAN_UNIT:
            printf("()");
            break;
        case LUOYAN_LIST: {
            printf("[");
            luoyan_list_node_t* node = value->data.list_val->head;
            bool first = true;
            while (node) {
                if (!first) printf("; ");
                first = false;
                luoyan_print_value(node->value);
                node = node->next;
            }
            printf("]");
            break;
        }
        case LUOYAN_FUNCTION:
            printf("<function:%s>", value->data.function_val->name ? value->data.function_val->name : "anonymous");
            break;
        case LUOYAN_RECORD: {
            printf("{ ");
            luoyan_record_field_t* field = value->data.record_val->fields;
            bool first = true;
            while (field) {
                if (!first) printf("; ");
                printf("%s = ", field->name);
                luoyan_print_value(field->value);
                field = field->next;
                first = false;
            }
            printf(" }");
            break;
        }
        case LUOYAN_CLASS:
            printf("<类 %s>", value->data.class_val->name);
            break;
        case LUOYAN_OBJECT:
            printf("<%s 对象>", value->data.object_val->class_name);
            break;
        default:
            printf("<unknown>");
            break;
    }
}

/* =============================================================================
 * 算术运算
 * ============================================================================= */

luoyan_value_t* luoyan_add(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_INT && b->type == LUOYAN_INT) {
        return luoyan_int(a->data.int_val + b->data.int_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_FLOAT) {
        return luoyan_float(a->data.float_val + b->data.float_val);
    } else if (a->type == LUOYAN_INT && b->type == LUOYAN_FLOAT) {
        return luoyan_float((double)a->data.int_val + b->data.float_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_INT) {
        return luoyan_float(a->data.float_val + (double)b->data.int_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

luoyan_value_t* luoyan_subtract(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_INT && b->type == LUOYAN_INT) {
        return luoyan_int(a->data.int_val - b->data.int_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_FLOAT) {
        return luoyan_float(a->data.float_val - b->data.float_val);
    } else if (a->type == LUOYAN_INT && b->type == LUOYAN_FLOAT) {
        return luoyan_float((double)a->data.int_val - b->data.float_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_INT) {
        return luoyan_float(a->data.float_val - (double)b->data.int_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

luoyan_value_t* luoyan_multiply(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_INT && b->type == LUOYAN_INT) {
        return luoyan_int(a->data.int_val * b->data.int_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_FLOAT) {
        return luoyan_float(a->data.float_val * b->data.float_val);
    } else if (a->type == LUOYAN_INT && b->type == LUOYAN_FLOAT) {
        return luoyan_float((double)a->data.int_val * b->data.float_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_INT) {
        return luoyan_float(a->data.float_val * (double)b->data.int_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

luoyan_value_t* luoyan_divide(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_INT && b->type == LUOYAN_INT) {
        if (b->data.int_val == 0) {
            luoyan_set_error(LUOYAN_ERROR_DIVISION_BY_ZERO);
            return NULL;
        }
        return luoyan_int(a->data.int_val / b->data.int_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_FLOAT) {
        if (b->data.float_val == 0.0) {
            luoyan_set_error(LUOYAN_ERROR_DIVISION_BY_ZERO);
            return NULL;
        }
        return luoyan_float(a->data.float_val / b->data.float_val);
    } else if (a->type == LUOYAN_INT && b->type == LUOYAN_FLOAT) {
        if (b->data.float_val == 0.0) {
            luoyan_set_error(LUOYAN_ERROR_DIVISION_BY_ZERO);
            return NULL;
        }
        return luoyan_float((double)a->data.int_val / b->data.float_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_INT) {
        if (b->data.int_val == 0) {
            luoyan_set_error(LUOYAN_ERROR_DIVISION_BY_ZERO);
            return NULL;
        }
        return luoyan_float(a->data.float_val / (double)b->data.int_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

luoyan_value_t* luoyan_modulo(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_INT && b->type == LUOYAN_INT) {
        if (b->data.int_val == 0) {
            luoyan_set_error(LUOYAN_ERROR_DIVISION_BY_ZERO);
            return NULL;
        }
        return luoyan_int(a->data.int_val % b->data.int_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

/* =============================================================================
 * 比较运算
 * ============================================================================= */

luoyan_value_t* luoyan_equal(luoyan_value_t* a, luoyan_value_t* b) {
    return luoyan_bool(luoyan_equals(a, b));
}

luoyan_value_t* luoyan_not_equal(luoyan_value_t* a, luoyan_value_t* b) {
    return luoyan_bool(!luoyan_equals(a, b));
}

luoyan_value_t* luoyan_less_than(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_INT && b->type == LUOYAN_INT) {
        return luoyan_bool(a->data.int_val < b->data.int_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_FLOAT) {
        return luoyan_bool(a->data.float_val < b->data.float_val);
    } else if (a->type == LUOYAN_INT && b->type == LUOYAN_FLOAT) {
        return luoyan_bool((double)a->data.int_val < b->data.float_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_INT) {
        return luoyan_bool(a->data.float_val < (double)b->data.int_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

luoyan_value_t* luoyan_less_equal(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_INT && b->type == LUOYAN_INT) {
        return luoyan_bool(a->data.int_val <= b->data.int_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_FLOAT) {
        return luoyan_bool(a->data.float_val <= b->data.float_val);
    } else if (a->type == LUOYAN_INT && b->type == LUOYAN_FLOAT) {
        return luoyan_bool((double)a->data.int_val <= b->data.float_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_INT) {
        return luoyan_bool(a->data.float_val <= (double)b->data.int_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

luoyan_value_t* luoyan_greater_than(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_INT && b->type == LUOYAN_INT) {
        return luoyan_bool(a->data.int_val > b->data.int_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_FLOAT) {
        return luoyan_bool(a->data.float_val > b->data.float_val);
    } else if (a->type == LUOYAN_INT && b->type == LUOYAN_FLOAT) {
        return luoyan_bool((double)a->data.int_val > b->data.float_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_INT) {
        return luoyan_bool(a->data.float_val > (double)b->data.int_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

luoyan_value_t* luoyan_greater_equal(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_INT && b->type == LUOYAN_INT) {
        return luoyan_bool(a->data.int_val >= b->data.int_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_FLOAT) {
        return luoyan_bool(a->data.float_val >= b->data.float_val);
    } else if (a->type == LUOYAN_INT && b->type == LUOYAN_FLOAT) {
        return luoyan_bool((double)a->data.int_val >= b->data.float_val);
    } else if (a->type == LUOYAN_FLOAT && b->type == LUOYAN_INT) {
        return luoyan_bool(a->data.float_val >= (double)b->data.int_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

/* =============================================================================
 * 逻辑运算
 * ============================================================================= */

luoyan_value_t* luoyan_logical_and(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_BOOL && b->type == LUOYAN_BOOL) {
        return luoyan_bool(a->data.bool_val && b->data.bool_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

luoyan_value_t* luoyan_logical_or(luoyan_value_t* a, luoyan_value_t* b) {
    if (!a || !b) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_BOOL && b->type == LUOYAN_BOOL) {
        return luoyan_bool(a->data.bool_val || b->data.bool_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

luoyan_value_t* luoyan_logical_not(luoyan_value_t* a) {
    if (!a) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (a->type == LUOYAN_BOOL) {
        return luoyan_bool(!a->data.bool_val);
    } else {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
}

/* =============================================================================
 * 列表操作
 * ============================================================================= */

luoyan_value_t* luoyan_list_cons(luoyan_value_t* head, luoyan_value_t* tail) {
    if (!head || !tail) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (tail->type != LUOYAN_LIST) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    luoyan_value_t* new_list = luoyan_malloc(sizeof(luoyan_value_t));
    if (!new_list) return NULL;
    
    luoyan_list_t* list = luoyan_malloc(sizeof(luoyan_list_t));
    if (!list) {
        free(new_list);
        return NULL;
    }
    
    luoyan_list_node_t* node = luoyan_malloc(sizeof(luoyan_list_node_t));
    if (!node) {
        free(list);
        free(new_list);
        return NULL;
    }
    
    node->value = luoyan_retain(head);
    node->next = NULL;
    
    list->head = node;
    list->tail = node;
    list->length = 1;
    list->ref_count = 1;
    
    // 如果tail不是空列表，将其所有元素添加到新列表
    if (tail->data.list_val->length > 0) {
        luoyan_list_node_t* tail_node = tail->data.list_val->head;
        while (tail_node) {
            luoyan_list_node_t* new_node = luoyan_malloc(sizeof(luoyan_list_node_t));
            if (!new_node) {
                // 清理已分配的内存
                luoyan_release(new_list);
                return NULL;
            }
            new_node->value = luoyan_retain(tail_node->value);
            new_node->next = NULL;
            
            list->tail->next = new_node;
            list->tail = new_node;
            list->length++;
            tail_node = tail_node->next;
        }
    }
    
    new_list->type = LUOYAN_LIST;
    new_list->data.list_val = list;
    new_list->ref_count = 1;
    return new_list;
}

luoyan_value_t* luoyan_list_head(luoyan_value_t* list) {
    if (!list) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (list->type != LUOYAN_LIST) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    if (list->data.list_val->length == 0) {
        luoyan_set_error(LUOYAN_ERROR_INVALID_FUNCTION_CALL);
        return NULL;
    }
    
    return luoyan_retain(list->data.list_val->head->value);
}

luoyan_value_t* luoyan_list_tail(luoyan_value_t* list) {
    if (!list) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (list->type != LUOYAN_LIST) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    if (list->data.list_val->length == 0) {
        return luoyan_list_empty();
    }
    
    luoyan_value_t* new_list = luoyan_list_empty();
    if (!new_list) return NULL;
    
    luoyan_list_node_t* node = list->data.list_val->head->next;
    luoyan_list_node_t* prev = NULL;
    
    while (node) {
        luoyan_list_node_t* new_node = luoyan_malloc(sizeof(luoyan_list_node_t));
        if (!new_node) {
            luoyan_release(new_list);
            return NULL;
        }
        
        new_node->value = luoyan_retain(node->value);
        new_node->next = NULL;
        
        if (prev) {
            prev->next = new_node;
        } else {
            new_list->data.list_val->head = new_node;
        }
        
        new_list->data.list_val->tail = new_node;
        new_list->data.list_val->length++;
        prev = new_node;
        node = node->next;
    }
    
    return new_list;
}

luoyan_value_t* luoyan_list_is_empty(luoyan_value_t* list) {
    if (!list) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (list->type != LUOYAN_LIST) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    return luoyan_bool(list->data.list_val->length == 0);
}

luoyan_value_t* luoyan_list_length(luoyan_value_t* list) {
    if (!list) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (list->type != LUOYAN_LIST) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    return luoyan_int((luoyan_int_t)list->data.list_val->length);
}

/* =============================================================================
 * 函数操作
 * ============================================================================= */

luoyan_value_t* luoyan_function_create(
    luoyan_value_t* (*func_ptr)(luoyan_env_t*, luoyan_value_t*),
    luoyan_env_t* closure_env,
    const char* name
) {
    luoyan_value_t* val = luoyan_malloc(sizeof(luoyan_value_t));
    if (!val) return NULL;
    
    luoyan_function_t* func = luoyan_malloc(sizeof(luoyan_function_t));
    if (!func) {
        free(val);
        return NULL;
    }
    
    func->func_ptr = func_ptr;
    func->closure_env = luoyan_env_retain(closure_env);
    func->name = name ? strdup(name) : NULL;
    func->ref_count = 1;
    
    val->type = LUOYAN_FUNCTION;
    val->data.function_val = func;
    val->ref_count = 1;
    return val;
}

luoyan_value_t* luoyan_function_call(luoyan_value_t* func, luoyan_value_t* arg) {
    if (!func || !arg) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    if (func->type != LUOYAN_FUNCTION) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    if (!func->data.function_val->func_ptr) {
        luoyan_set_error(LUOYAN_ERROR_INVALID_FUNCTION_CALL);
        return NULL;
    }
    
    return func->data.function_val->func_ptr(func->data.function_val->closure_env, arg);
}

/* =============================================================================
 * 环境操作
 * ============================================================================= */

luoyan_env_t* luoyan_env_create(luoyan_env_t* parent) {
    luoyan_env_t* env = luoyan_malloc(sizeof(luoyan_env_t));
    if (!env) return NULL;
    
    env->entries = NULL;
    env->parent = parent ? luoyan_env_retain(parent) : NULL;
    env->ref_count = 1;
    return env;
}

void luoyan_env_bind(luoyan_env_t* env, const char* name, luoyan_value_t* value) {
    if (!env || !name || !value) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return;
    }
    
    // 查找是否已存在同名绑定
    luoyan_env_entry_t* entry = env->entries;
    while (entry) {
        if (strcmp(entry->name, name) == 0) {
            luoyan_release(entry->value);
            entry->value = luoyan_retain(value);
            return;
        }
        entry = entry->next;
    }
    
    // 创建新绑定
    luoyan_env_entry_t* new_entry = luoyan_malloc(sizeof(luoyan_env_entry_t));
    if (!new_entry) return;
    
    new_entry->name = strdup(name);
    if (!new_entry->name) {
        free(new_entry);
        return;
    }
    
    new_entry->value = luoyan_retain(value);
    new_entry->next = env->entries;
    env->entries = new_entry;
}

luoyan_value_t* luoyan_env_lookup(luoyan_env_t* env, const char* name) {
    if (!env || !name) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    luoyan_env_entry_t* entry = env->entries;
    while (entry) {
        if (strcmp(entry->name, name) == 0) {
            return entry->value;
        }
        entry = entry->next;
    }
    
    if (env->parent) {
        return luoyan_env_lookup(env->parent, name);
    }
    
    luoyan_set_error(LUOYAN_ERROR_UNDEFINED_VARIABLE);
    return NULL;
}

luoyan_env_t* luoyan_env_retain(luoyan_env_t* env) {
    if (env) {
        env->ref_count++;
    }
    return env;
}

void luoyan_env_release(luoyan_env_t* env) {
    if (!env || --env->ref_count > 0) {
        return;
    }
    
    luoyan_env_entry_t* entry = env->entries;
    while (entry) {
        luoyan_env_entry_t* next = entry->next;
        free(entry->name);
        luoyan_release(entry->value);
        free(entry);
        entry = next;
    }
    
    luoyan_env_release(env->parent);
    free(env);
}

/* =============================================================================
 * 内置函数
 * ============================================================================= */

luoyan_value_t* luoyan_builtin_print(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env; // 未使用的参数
    
    if (!arg) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    luoyan_print_value(arg);
    printf("\n");
    fflush(stdout);
    
    return luoyan_unit();
}

luoyan_value_t* luoyan_builtin_read(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env; // 未使用的参数
    (void)arg; // 未使用的参数
    
    char buffer[1024];
    if (fgets(buffer, sizeof(buffer), stdin)) {
        // 去除换行符
        size_t len = strlen(buffer);
        if (len > 0 && buffer[len-1] == '\n') {
            buffer[len-1] = '\0';
        }
        return luoyan_string(buffer);
    }
    
    return luoyan_string("");
}

/* =============================================================================
 * 文件I/O函数
 * ============================================================================= */

luoyan_value_t* luoyan_builtin_read_file(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env;
    
    if (!arg || arg->type != LUOYAN_STRING) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    const char* filename = arg->data.string_val->data;
    FILE* file = fopen(filename, "r");
    if (!file) {
        return luoyan_string("");  // Return empty string on error
    }
    
    // 获取文件大小
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    // 分配缓冲区
    char* buffer = malloc(size + 1);
    if (!buffer) {
        fclose(file);
        luoyan_set_error(LUOYAN_ERROR_OUT_OF_MEMORY);
        return NULL;
    }
    
    // 读取文件内容
    size_t read_size = fread(buffer, 1, size, file);
    buffer[read_size] = '\0';
    fclose(file);
    
    luoyan_value_t* result = luoyan_string(buffer);
    free(buffer);
    return result;
}

luoyan_value_t* luoyan_builtin_write_file(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env;
    
    // 期望参数是一个包含(filename, content)的元组
    if (!arg || arg->type != LUOYAN_LIST) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    luoyan_list_t* list = arg->data.list_val;
    if (!list || !list->head || !list->head->next) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    luoyan_value_t* filename_val = list->head->value;
    luoyan_value_t* content_val = list->head->next->value;
    
    if (!filename_val || filename_val->type != LUOYAN_STRING ||
        !content_val || content_val->type != LUOYAN_STRING) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    const char* filename = filename_val->data.string_val->data;
    const char* content = content_val->data.string_val->data;
    
    FILE* file = fopen(filename, "w");
    if (!file) {
        return luoyan_bool(false);
    }
    
    size_t written = fwrite(content, 1, strlen(content), file);
    fclose(file);
    
    return luoyan_bool(written == strlen(content));
}

luoyan_value_t* luoyan_builtin_file_exists(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env;
    
    if (!arg || arg->type != LUOYAN_STRING) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    const char* filename = arg->data.string_val->data;
    FILE* file = fopen(filename, "r");
    if (file) {
        fclose(file);
        return luoyan_bool(true);
    }
    return luoyan_bool(false);
}

/* =============================================================================
 * 系统函数
 * ============================================================================= */

// 全局变量存储命令行参数
static int global_argc = 0;
static char** global_argv = NULL;

void luoyan_set_system_args(int argc, char** argv) {
    global_argc = argc;
    global_argv = argv;
}

luoyan_value_t* luoyan_builtin_system_args(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env;
    (void)arg;
    
    luoyan_value_t* result = luoyan_list_empty();
    
    // 从后往前构建列表
    for (int i = global_argc - 1; i >= 0; i--) {
        luoyan_value_t* arg_str = luoyan_string(global_argv[i]);
        result = luoyan_list_cons(arg_str, result);
        luoyan_release(arg_str);
    }
    
    return result;
}

luoyan_value_t* luoyan_builtin_system_exit(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env;
    
    int exit_code = 0;
    if (arg && arg->type == LUOYAN_INT) {
        exit_code = (int)arg->data.int_val;
    }
    
    exit(exit_code);
    return luoyan_unit(); // 永远不会到达这里
}

/* =============================================================================
 * 字符串工具函数
 * ============================================================================= */

luoyan_value_t* luoyan_builtin_string_length(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env;
    
    if (!arg || arg->type != LUOYAN_STRING) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    return luoyan_int((luoyan_int_t)arg->data.string_val->length);
}

luoyan_value_t* luoyan_builtin_string_concat(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env;
    
    // 期望参数是包含两个字符串的列表
    if (!arg || arg->type != LUOYAN_LIST) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    luoyan_list_t* list = arg->data.list_val;
    if (!list || !list->head || !list->head->next) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    luoyan_value_t* str1 = list->head->value;
    luoyan_value_t* str2 = list->head->next->value;
    
    if (!str1 || str1->type != LUOYAN_STRING ||
        !str2 || str2->type != LUOYAN_STRING) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    const char* s1 = str1->data.string_val->data;
    const char* s2 = str2->data.string_val->data;
    
    size_t len1 = strlen(s1);
    size_t len2 = strlen(s2);
    char* result = malloc(len1 + len2 + 1);
    
    if (!result) {
        luoyan_set_error(LUOYAN_ERROR_OUT_OF_MEMORY);
        return NULL;
    }
    
    strcpy(result, s1);
    strcat(result, s2);
    
    luoyan_value_t* ret = luoyan_string(result);
    free(result);
    return ret;
}

luoyan_value_t* luoyan_builtin_int_to_string(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env;
    
    if (!arg || arg->type != LUOYAN_INT) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "%lld", (long long)arg->data.int_val);
    return luoyan_string(buffer);
}

luoyan_value_t* luoyan_builtin_string_to_int(luoyan_env_t* env, luoyan_value_t* arg) {
    (void)env;
    
    if (!arg || arg->type != LUOYAN_STRING) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    const char* str = arg->data.string_val->data;
    char* endptr;
    long long value = strtoll(str, &endptr, 10);
    
    // 检查是否成功转换
    if (*endptr != '\0') {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    return luoyan_int((luoyan_int_t)value);
}

/* =============================================================================
 * 运行时初始化和清理
 * ============================================================================= */

void luoyan_runtime_init(void) {
    luoyan_last_error = LUOYAN_OK;
}

void luoyan_runtime_cleanup(void) {
    // 目前没有全局资源需要清理
}

/* =============================================================================
 * 记录操作
 * ============================================================================= */

luoyan_value_t* luoyan_record_empty(void) {
    return luoyan_record_create();
}

luoyan_value_t* luoyan_record_create(void) {
    luoyan_value_t* value = luoyan_malloc(sizeof(luoyan_value_t));
    if (!value) return NULL;
    
    luoyan_record_t* record = luoyan_malloc(sizeof(luoyan_record_t));
    if (!record) {
        free(value);
        return NULL;
    }
    
    record->fields = NULL;
    record->field_count = 0;
    record->ref_count = 1;
    
    value->type = LUOYAN_RECORD;
    value->data.record_val = record;
    value->ref_count = 1;
    
    return value;
}

luoyan_value_t* luoyan_record_set_field(luoyan_value_t* record, const char* field_name, luoyan_value_t* value) {
    if (!record || record->type != LUOYAN_RECORD || !field_name || !value) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    // 查找现有字段
    luoyan_record_field_t* field = record->data.record_val->fields;
    while (field) {
        if (strcmp(field->name, field_name) == 0) {
            // 更新现有字段
            luoyan_release(field->value);
            field->value = luoyan_retain(value);
            return record;
        }
        field = field->next;
    }
    
    // 创建新字段
    luoyan_record_field_t* new_field = luoyan_malloc(sizeof(luoyan_record_field_t));
    if (!new_field) return NULL;
    
    new_field->name = luoyan_malloc(strlen(field_name) + 1);
    if (!new_field->name) {
        free(new_field);
        return NULL;
    }
    strcpy(new_field->name, field_name);
    
    new_field->value = luoyan_retain(value);
    new_field->next = record->data.record_val->fields;
    record->data.record_val->fields = new_field;
    record->data.record_val->field_count++;
    
    return record;
}

luoyan_value_t* luoyan_record_get_field(luoyan_value_t* record, const char* field_name) {
    if (!record || record->type != LUOYAN_RECORD || !field_name) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    luoyan_record_field_t* field = record->data.record_val->fields;
    while (field) {
        if (strcmp(field->name, field_name) == 0) {
            return field->value;
        }
        field = field->next;
    }
    
    luoyan_set_error(LUOYAN_ERROR_FIELD_NOT_FOUND);
    return NULL;
}

luoyan_value_t* luoyan_record_has_field(luoyan_value_t* record, const char* field_name) {
    if (!record || record->type != LUOYAN_RECORD || !field_name) {
        return luoyan_bool(false);
    }
    
    luoyan_record_field_t* field = record->data.record_val->fields;
    while (field) {
        if (strcmp(field->name, field_name) == 0) {
            return luoyan_bool(true);
        }
        field = field->next;
    }
    
    return luoyan_bool(false);
}

luoyan_value_t* luoyan_record_update(luoyan_value_t* record, const char* field_name, luoyan_value_t* value) {
    if (!record || record->type != LUOYAN_RECORD || !field_name || !value) {
        luoyan_set_error(LUOYAN_ERROR_NULL_POINTER);
        return NULL;
    }
    
    // 创建记录的副本
    luoyan_value_t* new_record = luoyan_record_create();
    if (!new_record) return NULL;
    
    // 复制所有字段
    luoyan_record_field_t* field = record->data.record_val->fields;
    while (field) {
        if (strcmp(field->name, field_name) == 0) {
            // 使用新值
            luoyan_record_set_field(new_record, field->name, value);
        } else {
            // 使用原值
            luoyan_record_set_field(new_record, field->name, field->value);
        }
        field = field->next;
    }
    
    // 如果字段不存在，添加新字段
    luoyan_error_t old_error = luoyan_last_error;
    luoyan_last_error = LUOYAN_OK;
    luoyan_value_t* existing = luoyan_record_get_field(record, field_name);
    if (!existing && luoyan_last_error == LUOYAN_ERROR_FIELD_NOT_FOUND) {
        luoyan_record_set_field(new_record, field_name, value);
    }
    luoyan_last_error = old_error;
    
    return new_record;
}

/* =============================================================================
 * 面向对象支持
 * ============================================================================= */

/* 全局类表 */
luoyan_value_t* luoyan_global_class_table = NULL;

/* 初始化全局类表 */
static void init_class_table() {
    if (!luoyan_global_class_table) {
        luoyan_global_class_table = luoyan_record_create();
    }
}

/* 类创建函数 */
luoyan_value_t* luoyan_class_create(const char* name, const char* superclass_name, 
                                   char** field_names, int field_count) {
    init_class_table();
    
    luoyan_value_t* class_val = (luoyan_value_t*)luoyan_malloc(sizeof(luoyan_value_t));
    if (!class_val) return NULL;
    
    luoyan_class_t* class_data = (luoyan_class_t*)luoyan_malloc(sizeof(luoyan_class_t));
    if (!class_data) {
        free(class_val);
        return NULL;
    }
    
    // 设置类名
    class_data->name = strdup(name);
    class_data->superclass_name = superclass_name ? strdup(superclass_name) : NULL;
    
    // 设置字段名
    class_data->field_names = (char**)luoyan_malloc(sizeof(char*) * field_count);
    class_data->field_count = field_count;
    for (int i = 0; i < field_count; i++) {
        class_data->field_names[i] = strdup(field_names[i]);
    }
    
    // 初始化方法数组
    class_data->methods = NULL;
    class_data->method_count = 0;
    class_data->ref_count = 1;
    
    class_val->type = LUOYAN_CLASS;
    class_val->data.class_val = class_data;
    class_val->ref_count = 1;
    
    // 注册到全局类表
    luoyan_record_set_field(luoyan_global_class_table, name, class_val);
    
    return class_val;
}

/* 对象创建函数 */
luoyan_value_t* luoyan_object_create(const char* class_name, luoyan_value_t** field_values, int field_count) {
    init_class_table();
    
    // 查找类定义
    luoyan_value_t* class_val = luoyan_record_get_field(luoyan_global_class_table, class_name);
    if (!class_val || class_val->type != LUOYAN_CLASS) {
        luoyan_set_error(LUOYAN_ERROR_UNDEFINED_VARIABLE);
        return NULL;
    }
    
    luoyan_value_t* object_val = (luoyan_value_t*)luoyan_malloc(sizeof(luoyan_value_t));
    if (!object_val) return NULL;
    
    luoyan_object_t* object_data = (luoyan_object_t*)luoyan_malloc(sizeof(luoyan_object_t));
    if (!object_data) {
        free(object_val);
        return NULL;
    }
    
    // 设置对象类名
    object_data->class_name = strdup(class_name);
    
    // 复制字段值
    object_data->field_count = field_count;
    object_data->fields = (luoyan_value_t**)luoyan_malloc(sizeof(luoyan_value_t*) * field_count);
    for (int i = 0; i < field_count; i++) {
        object_data->fields[i] = luoyan_retain(field_values[i]);
    }
    
    // 复制类的方法
    luoyan_class_t* class_data = class_val->data.class_val;
    object_data->method_count = class_data->method_count;
    if (class_data->method_count > 0) {
        object_data->methods = (luoyan_method_t**)luoyan_malloc(sizeof(luoyan_method_t*) * class_data->method_count);
        for (int i = 0; i < class_data->method_count; i++) {
            object_data->methods[i] = class_data->methods[i]; // 共享方法定义
        }
    } else {
        object_data->methods = NULL;
    }
    
    object_data->ref_count = 1;
    
    object_val->type = LUOYAN_OBJECT;
    object_val->data.object_val = object_data;
    object_val->ref_count = 1;
    
    return object_val;
}

/* 全局环境变量，用于访问内置函数 */
static luoyan_env_t* global_method_env = NULL;

/* 设置全局方法环境 */
void luoyan_set_global_env(luoyan_env_t* env) {
    global_method_env = env;
}

/* 方法调用函数 */
luoyan_value_t* luoyan_method_call(luoyan_value_t* object, const char* method_name, 
                                  luoyan_value_t** args, int argc) {
    if (!object || object->type != LUOYAN_OBJECT) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return NULL;
    }
    
    luoyan_object_t* obj_data = object->data.object_val;
    
    // 查找方法
    for (int i = 0; i < obj_data->method_count; i++) {
        luoyan_method_t* method = obj_data->methods[i];
        if (strcmp(method->name, method_name) == 0) {
            // 创建环境，继承全局环境以访问内置函数
            luoyan_env_t* method_env = luoyan_env_create(global_method_env);
            
            // 绑定字段值到环境（通过字段名）
            luoyan_value_t* class_val = luoyan_record_get_field(luoyan_global_class_table, obj_data->class_name);
            if (class_val && class_val->type == LUOYAN_CLASS) {
                luoyan_class_t* class_data = class_val->data.class_val;
                for (int j = 0; j < obj_data->field_count && j < class_data->field_count; j++) {
                    luoyan_env_bind(method_env, class_data->field_names[j], obj_data->fields[j]);
                }
            }
            
            // 调用方法
            luoyan_value_t* result = method->impl(method_env, args, argc);
            
            luoyan_env_release(method_env);
            return result;
        }
    }
    
    luoyan_set_error(LUOYAN_ERROR_FIELD_NOT_FOUND);
    return NULL;
}

/* 为类添加方法 */
void luoyan_class_add_method(luoyan_value_t* class_val, const char* method_name,
                            luoyan_value_t* (*impl)(luoyan_env_t* env, luoyan_value_t** args, int argc),
                            int param_count, char** param_names) {
    if (!class_val || class_val->type != LUOYAN_CLASS) {
        luoyan_set_error(LUOYAN_ERROR_TYPE_MISMATCH);
        return;
    }
    
    luoyan_class_t* class_data = class_val->data.class_val;
    
    // 创建新方法
    luoyan_method_t* method = (luoyan_method_t*)luoyan_malloc(sizeof(luoyan_method_t));
    if (!method) return;
    
    method->name = strdup(method_name);
    method->impl = impl;
    method->param_count = param_count;
    method->ref_count = 1;
    
    if (param_count > 0 && param_names) {
        method->param_names = (char**)luoyan_malloc(sizeof(char*) * param_count);
        for (int i = 0; i < param_count; i++) {
            method->param_names[i] = strdup(param_names[i]);
        }
    } else {
        method->param_names = NULL;
    }
    
    // 扩展方法数组
    class_data->method_count++;
    class_data->methods = (luoyan_method_t**)realloc(class_data->methods, 
                                                    sizeof(luoyan_method_t*) * class_data->method_count);
    class_data->methods[class_data->method_count - 1] = method;
}

/* =============================================================================
 * 调试支持
 * ============================================================================= */

#ifdef LUOYAN_DEBUG
void luoyan_debug_print(const char* format, ...) {
    va_list args;
    va_start(args, format);
    printf("[DEBUG] ");
    vprintf(format, args);
    printf("\n");
    va_end(args);
}

void luoyan_debug_value(luoyan_value_t* value) {
    printf("[DEBUG] Value: ");
    luoyan_print_value(value);
    printf(" (type=%d, ref_count=%d)\n", value ? value->type : -1, value ? value->ref_count : 0);
}
#endif