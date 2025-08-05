(lang dune 3.16)

(name yyocamlc)
(version 387ad10)

(package
 (name yyocamlc)
 (depends 
   ocaml
   (dune (>= 3.0))
   menhir
   ppx_deriving
   (alcotest :with-test)
   (bisect_ppx :dev)
   yojson
   uutf
   threads)
 (synopsis "骆言 - 中文编程语言编译器")
 (description
  "一个模仿 OCaml 的中文编程语言编译器实现，现名为骆言"))

(using menhir 2.1)