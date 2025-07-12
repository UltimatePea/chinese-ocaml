open Yyocamlc_lib

let debug_tokenize input =
  let tokens = Lexer.tokenize input "debug" in
  List.iter (fun (token, pos) ->
    Printf.printf "Token: %s at %s\n" 
      (match token with
       | Lexer.SheKeyword -> "SheKeyword"
       | Lexer.WeiKeyword -> "WeiKeyword"
       | Lexer.Identifier s -> Printf.sprintf "Identifier(%s)" s
       | Lexer.IntLit i -> Printf.sprintf "IntLit(%d)" i
       | _ -> "Other")
      (Printf.sprintf "%d:%d" pos.line pos.column)
  ) tokens

let () =
  Printf.printf "Testing: 设数值为42\n";
  debug_tokenize "设数值为42";
  Printf.printf "\nTesting individual keywords:\n";
  debug_tokenize "设";
  debug_tokenize "为";