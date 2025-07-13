设「identity」为函数 x -> x
设「num_result」为identity 42
设「str_result」为identity 『你好』
设「list_result」为identity (列开始 1 其一 2 其二 3 其三 列结束)

设「compose」为函数 f -> 函数 g -> 函数 x -> f （g x）
设「add_one」为函数 x -> x + 1
设「double」为函数 x -> x * 2
设「add_one_then_double」为compose double add_one
设「result」为add_one_then_double 5

打印 num_result
打印 str_result
打印 list_result
打印 result