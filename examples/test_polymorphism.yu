让 identity = 函数 x -> x
让 num_result = identity 42
让 str_result = identity "hello"
让 list_result = identity [1, 2, 3]

让 compose = 函数 f -> 函数 g -> 函数 x -> f (g x)
让 add_one = 函数 x -> x + 1
让 double = 函数 x -> x * 2
让 add_one_then_double = compose double add_one
让 result = add_one_then_double 5

打印 num_result
打印 str_result
打印 list_result
打印 result