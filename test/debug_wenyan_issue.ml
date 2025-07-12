open Yyocamlc_lib

let debug_wenyan_parsing () =
  (* 测试单个关键字 *)
  let test_inputs = [
    "设";
    "为";
    "设 数值 为 42";
    "设数值为42"
  ] in
  
  List.iter (fun input ->
    Printf.printf "\n输入: %s\n" input;
    
    (* 测试词法分析 *)
    let token_list = Lexer.tokenize input "test" in
    Printf.printf "词法分析结果: %d 个词元\n" (List.length token_list);
    List.iteri (fun i (token, pos) ->
      let token_name = match token with
        | Lexer.SetKeyword -> "SetKeyword"
        | Lexer.IdentifierToken s -> "IdentifierToken(" ^ s ^ ")"
        | Lexer.AsForKeyword -> "AsForKeyword"
        | Lexer.IntToken n -> "IntToken(" ^ string_of_int n ^ ")"
        | Lexer.EOF -> "EOF"
        | _ -> "其他Token"
      in
      Printf.printf "  %d: %s (line %d, col %d)\n" i token_name pos.Lexer.line pos.Lexer.column
    ) token_list;
  ) test_inputs

let () = debug_wenyan_parsing ()