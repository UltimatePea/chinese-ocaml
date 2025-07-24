let test_simple () =
  let test_cases = [
    ("test1", "input1");
    ("test2", "input2");
  ] in
  
  List.iter (fun (desc, input) ->
    Printf.printf "%s: %s\n" desc input
  ) test_cases;
  ()

let () =
  test_simple ();