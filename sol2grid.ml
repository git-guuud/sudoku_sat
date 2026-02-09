let to_char d =
  match d with 
    | 16 -> '0' 
    | x when x>=1 && x<=9 -> Char.chr (Char.code '0' + x)
    | x when x>=10 && x<=15 -> Char.chr (Char.code 'A' + (x-10))
    | _ -> '.'
    

let print_grid oc l n = 
  let rec aux x ls = 
    match ls with
    | [] -> ()
    | hd::tl -> if x=n
      then (Printf.fprintf oc "%s" "\n"; aux 0 ls)
      else (Printf.fprintf oc "%c" (to_char ((hd-1) mod n + 1)) ; aux (x+1) tl)
  in
  aux 0 l


let cubert = function
| 4096 -> 16
| 729 -> 9
| 64 -> 4
| 1 -> 1
| _ -> -1

let () = 
  let input_channel = stdin and output_channel = open_out "output.txt" in
  let l1 = String.trim (input_line input_channel) in
  if l1 = "s SATISFIABLE" then
    let l2 = input_line input_channel in
    let vals = String.split_on_char ' ' l2
    |> List.tl 
    |> List.map (fun x->String.trim x)
    |> List.filter (fun x -> x<>"") 
    |> List.map int_of_string in
    (* List.iter (fun x -> Printf.fprintf output_channel "%d " (-x)) vals;
    Printf.fprintf output_channel "%d\n" 0; *)
    let n = cubert (List.length vals) in
    let true_vars = List.filter (fun x -> x>0) vals in
    print_grid output_channel true_vars n
  else
    Printf.fprintf output_channel "%s" "UNSATISFIABLE\n" 
  ;
  close_in input_channel; close_out output_channel
;;