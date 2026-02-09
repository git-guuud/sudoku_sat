let rec copy oc ic = 
  try let line = input_line ic in
    (Printf.fprintf oc "%s\n" line; copy oc ic)
  with
    End_of_file -> ()

let () =
  let cnf_ch = open_in "sudoku.cnf" and z3_ch = open_in "z3_out.txt" in
  let out_channel = open_out "check_unique.cnf" in

  let p_line = input_line cnf_ch in
  (match String.split_on_char ' ' (String.trim p_line) with
  | a::b::c::d::xs -> Printf.fprintf out_channel "%s %s %s %d\n"  a b c ((int_of_string d) + 1)
  | _ -> Printf.fprintf out_channel "%s" p_line)
  ;
  let l1 = input_line z3_ch in 
  if l1 <> "s SATISFIABLE" then exit 1
  else (
  let l2 = input_line z3_ch in
  let vals = String.split_on_char ' ' l2
    |> List.tl 
    |> List.map (fun x->String.trim x)
    |> List.filter (fun x -> x<>"") 
    |> List.map int_of_string in
    List.iter (fun x -> Printf.fprintf out_channel "%d " (-x)) vals;
    Printf.fprintf out_channel "%d\n" 0;
    copy out_channel cnf_ch
  );
  close_in cnf_ch; close_in z3_ch; close_out out_channel; 
;;