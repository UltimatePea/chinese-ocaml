「：列表操作示例：」

让 「数列」 = 【1；2；3；4；5】

让 「平方列表」 = List.map （函数 「x」 → 「x」 * 「x」） 「数列」

让 「总和」 = List.fold_left （+） 0 「数列」

让 （） =
  Printf.printf "原列表：";
  List.iter （函数 「x」 → Printf.printf "%d " 「x」） 「数列」；
  print_newline （）；
  Printf.printf "平方列表：";
  List.iter （函数 「x」 → Printf.printf "%d " 「x」） 「平方列表」；
  print_newline （）；
  Printf.printf "总和：%d\n" 「总和」
