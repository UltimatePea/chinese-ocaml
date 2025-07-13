设 identity 为 函数 x -> x
设 num_result 为 identity 42
设 str_result 为 identity 『你好』
设 list_result 为 identity [1, 2, 3]

设 compose 为 函数 f -> 函数 g -> 函数 x -> f (g x)
设 add_one 为 函数 x -> x + 1
设 double 为 函数 x -> x * 2
设 add_one_then_double 为 compose double add_one
设 result 为 add_one_then_double 5

打印 num_result
打印 str_result
打印 list_result
打印 result