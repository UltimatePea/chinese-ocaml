(lang dune 3.0)

(name yyocamlc)

(package
 (name yyocamlc)
 (synopsis "中文编程语言编译器 - 基于OCaml设计的中文编程语言")
 (description "一个完全中文化的编程语言编译器，深度模仿OCaml的功能特性和设计哲学，让中文母语者能够以自然的中文思维进行编程。")
 (authors "AI开发团队")
 (license MIT)
 (homepage "https://github.com/your-org/yyocamlc")
 (bug-reports "https://github.com/your-org/yyocamlc/issues")
 (depends
  ocaml
  dune
  (menhir (>= 20220210))
  (ppx_deriving (>= 5.0))
  (ppx_sexp_conv (>= v0.15.0))
  (core (>= v0.15.0))
  (stdio (>= v0.15.0))
  (base (>= v0.15.0))
  (alcotest :with-test)
  (ounit2 :with-test)
  (bisect_ppx :with-test)))

(generate_opam_files true)

(formatting
 (enabled_for dune ocaml))

(env
 (dev
  (flags (:standard -w +a-4-9-18-40-41-42-44-45-48-70))))