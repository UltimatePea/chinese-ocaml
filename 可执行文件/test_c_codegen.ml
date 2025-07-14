open Yyocamlc_lib.C_codegen
open Yyocamlc_lib.Ast

let test_config = {
  output_file = "test_output.c";
  include_debug = true;
  optimize = false;
  runtime_path = "c_backend/runtime";
}

let test_program = [
  LetStmt ("x", LitExpr (IntLit 42));
  LetStmt ("y", LitExpr (StringLit "你好世界"));
  ExprStmt (FunCallExpr (VarExpr "打印", [VarExpr "x"]));
  ExprStmt (FunCallExpr (VarExpr "打印", [VarExpr "y"]));
  LetStmt ("sum", BinaryOpExpr (VarExpr "x", Add, LitExpr (IntLit 8)));
  ExprStmt (FunCallExpr (VarExpr "打印", [VarExpr "sum"]));
]

let () =
  Printf.printf "测试C代码生成器...\n";
  compile_to_c test_config test_program;
  Printf.printf "C代码生成完成！\n"