(lang dune 3.0)

(name yyocamlc)

(package
 (name yyocamlc)
 (depends 
  ocaml 
  dune 
  menhir
  ppx_deriving
  alcotest)
 (synopsis "豫语 - 中文编程语言编译器")
 (description "一个模仿 OCaml 的中文编程语言编译器实现"))

(using menhir 2.1)