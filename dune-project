(lang dune 3.16)

(name yyocamlc)

(package
 (name yyocamlc)
 (depends 
   ocaml
   (dune (>= 3.16))
   (menhir (>= 20240715))
   ppx_deriving
   alcotest
   bisect_ppx
   (yojson (>= 2.0)))
 (synopsis "骆言 - 中文编程语言编译器")
 (description
  "一个模仿 OCaml 的中文编程语言编译器实现，现名为骆言"))

(using menhir 2.1)