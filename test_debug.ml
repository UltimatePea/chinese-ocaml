open Printf

let debug_tokens () =
  let input = "设「数值」为４２" in
  printf "Input: %s\n" input;
  printf "Tokens:\n";
  let rec print_tokens tokens i =
    match tokens with
     < /dev/null |  [] -> printf "End of tokens\n"
    | (token, pos) :: rest ->
        printf "%d: %s at line %d, col %d\n" i
          (match token with
           | SetKeyword -> "SetKeyword"
           | QuotedIdentifierToken s -> "QuotedIdentifierToken(\"" ^ s ^ "\")"
           | AsForKeyword -> "AsForKeyword"
           | IntToken i -> "IntToken(" ^ string_of_int i ^ ")"
           | _ -> "Other")
          pos.line pos.column;
        print_tokens rest (i + 1)
  in
  print_tokens [] 0

let () = debug_tokens ()
