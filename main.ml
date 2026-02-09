type clause = Cl of int list
type prop = P of clause list
(* let orr (Cl x) y = y::x *)

let rec read_lines ic = 
  try let line = input_line ic in
    String.trim(line)::read_lines ic
  with
    End_of_file -> []


let to_val c = 
  match c with 
    | '0' -> 16 
    | '1'..'9' -> int_of_char c - 48 
    | 'A'..'F' -> int_of_char c - 55 
    | 'a'..'f' -> int_of_char c - 87 
    | _ -> -1

let inp_parse line n = 
  let rec aux idx acc = 
    if idx >= (n*n*n*n) then acc
    else if line.[idx] = '.' then aux (idx + 1) acc
    else aux (idx + 1) ((idx*n*n + (to_val line.[idx])) :: acc)
  in
  P(List.map (fun x->Cl([x])) (aux 0 []))

let rec print_int_list oc = function
  | [] -> ()
  | x::xs -> Printf.fprintf oc "%d " x; print_int_list oc xs 


(* let print_clause (Cl x) oc = print_int_list x oc; print_int 0; print_newline () *)

let print_prop (P l) oc = 
  List.iter (fun (Cl x) -> (print_int_list oc x; Printf.fprintf oc "%d\n" 0) ) l

(*takes the row, column and digit and returns the number associated 
with the variable x_i,j,d representing the truth value of whether 
digit d is in the cell in the ith row and jth column*)
let indexer i j d n = (i-1)*n*n + (j-1)*n*n*n*n + d

let sqrti = function 
| 16 -> 4
| 9 -> 3
| 4 -> 2
| _ -> 1 

let rec gen_list i j = 
  if i>j then []
  else i::(gen_list (i+1) j) 

let rec gen_grid r_i r_j c_i c_j =
  if r_i>r_j then []
  else (List.map (fun x -> (r_i, x)) (gen_list c_i c_j))::(gen_grid (r_i + 1) r_j c_i c_j)

(*
Clauses -
  Each cell has atleast one number -> 81 clauses
  Each cell has atmost one nubmer -> 81*9C2 clauses (for each pair of numbers make sure atleast one is not in the cell)
  Each number appears atleast once in a row -> 9*9 (9 numbers each for 9 rows)
  Each number appears atleast once in a column -> 9*9 (9 numbers each for 9 columns)
  Each number appears atleast once in a box -> 9*9 (9 numbers each for 9 boxes)
  Each number appears atmost once in a row/column/box -> directly implied by above
  Constraints -> one clause for each value pre-provided (if we know cell(1,1) has 8 then x_1,1,8 is the corresponding clause)
*)

(*Cell has atleast one number -> or(x_i,j,d) for all d=1..9*)
let cell_fill_clause (i, j) n = 
  Cl (List.map (fun d -> indexer i j d n) (gen_list 1 (n*n)))
  
(*Row has atleast one of digit d -> or(x_i,j,d) for all j=1..9*)
let row_clause (i, d) n =
  Cl (List.map (fun j -> indexer i j d n) (gen_list 1 (n*n)))
  
(*Column has atleast one of digit d -> or(x_i,j,d) for all i=1..9*)
let col_clause (j, d) n =
  Cl (List.map (fun i -> indexer i j d n) (gen_list 1 (n*n)))
let box_clause (b, d) n =
  let l = 
    gen_grid 1 n 1 n
    |> List.flatten
    |> List.map (fun (x,y) -> indexer ((b-1)/n *n +x) ((b-1) mod n *n +y) d n)
  in
  Cl (l)

(*Cell has atmost one value*)
let cell_unique_clause (i, j) n = 
  List.map (fun (d1,d2) -> Cl([-(indexer i j d1 n) ; -indexer i j d2 n])) (
    List.flatten (gen_grid 1 (n*n) 1 (n*n))
    |> List.filter (fun (x,y) -> x<y)
  )

(*Row has atmost one of digit d*)
let row_unique_clause (i, d) n = 
  List.map (fun (j1,j2) -> Cl([-(indexer i j1 d n) ; -indexer i j2 d n])) (
    List.flatten (gen_grid 1 (n*n) 1 (n*n))
    |> List.filter (fun (x,y) -> x<y)
  )

(*Column has atmost one of digit d*)
let col_unique_clause (j, d) n = 
  List.map (fun (i1,i2) -> Cl([-(indexer i1 j d n) ; -indexer i2 j d n])) (
    List.flatten (gen_grid 1 (n*n) 1 (n*n))
    |> List.filter (fun (x,y) -> x<y)
  )

(* let box_unique_clause (i, j) = 
  List.map (fun (d1,d2) -> Cl([-(indexer i j d1) ; -indexer i j d2])) (
    List.flatten (gen_grid 1 (n*n) 1 (n*n))
    |> List.filter (fun (x,y) -> x<y)
  ) *)

let () = 
  let out_channel = open_out "sudoku.cnf" and input_channel = open_in "input.txt" in

  let lines = read_lines input_channel in 
  let n = sqrti (List.length lines) in
  let constraint_prop = inp_parse (String.concat "" lines) n in
  let extra_num = List.length (match constraint_prop with P(x) -> x) in
  Printf.fprintf out_channel "p cnf %d %d \n" (n*n*n*n*n*n) (n*n*n*n*4 + 3*(n*n*(n*n-1)*n*n*n*n)/2 + extra_num);
  print_prop (constraint_prop) out_channel;

  let grid = gen_grid 1 (n*n) 1 (n*n) |> List.flatten in 
  let res = [
    List.map (fun x -> cell_fill_clause x n) grid;
    List.map (fun x -> row_clause x n) grid;
    List.map (fun x -> col_clause x n) grid;
    List.map (fun x -> box_clause x n) grid;
    List.map (fun x -> cell_unique_clause x n) grid |> List.flatten;
    List.map (fun x -> row_unique_clause x n) grid |> List.flatten;
    List.map (fun x -> col_unique_clause x n) grid |> List.flatten;
  ]
  in
  List.iter (fun x -> print_prop (P x) out_channel) res;
  close_in input_channel; close_out out_channel;

  
;;