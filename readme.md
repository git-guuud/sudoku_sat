# Sudoku SAT encoder and solver

An OCaml-based Sudoku  SAT encoder. It encodes Sudoku puzzles as CNF, calls Z3 to solve them, converts the SAT model back to a grid. Also provides helpers to verify solutions and check uniqueness.

## Requirements
- ocamlc 5.4.0
- Z3 version 4.8.12 - 64 bit
- `make` (GNU Make 4.3)

## Build
Build the OCaml helpers using the provided Makefile:

```sh
#compiles main, sol2grid, check_sudoku, check_unique
make 
```

## Typical workflow
1. Put your puzzle in `input.txt` (see Input format below).
2. Generate CNF, run Z3 and put the solution in `output.txt`:

```sh
# runs ./main, then z3 -dimacs sudoku.cnf > z3_out.txt
make run  
```


3. Verify solution against the original puzzle:

```sh
make check_sol
```

4. Check whether the solution is unique:

```sh
# outputs in the terminal 
make check_uni
```

The `make check_uni` flow uses `check_unique` to append a clause negating the found model and asks Z3 whether the modified CNF is UNSAT (unique) or SAT (multiple solutions).

## Input format
- `input.txt` should contain N lines where N = n*n (for an n-by-n Sudoku box size). For standard 9×9 Sudoku, provide 9 lines of 9 characters each.
- Use `.` for empty cells and decimal/hexadecimal-style digits for cells: `1`..`9` for 9x9 puzzles, `0`..`F` for 16×16 puzzles.

Examples:

3x3
```
..3..2.6
9..3.5..1
.18......
....7....
..2.1.9..
....6....
......3.5
1..2.8..9
7.5..1..4
```

4x4
```
......5..7C4...A
.478.2.....9....
1.6..4A...F.B72.
2.BC3..F.E.5..4.
..4.1.87F2...6.3
7..6..F.8.3D..E.
9.A....0.1.67.8.
.D..2.3..4.BA..1
.0.7.5...3...8..
...54......E2..B
..91..B...2F.5..
A2..C013B......6
.7.2B8.9C..A..35
FB...1..E...9AD7
D.....C.4...6E0.
.3.0.A.4..72.1..
```

## Output
- `output.txt` contains the solved grid (one line per row). If the solver reports UNSAT, `output.txt` will contain `UNSATISFIABLE`.
- Verdict of uniqueness check is printed to the terminal.

## Code files
- `main.ml` — encodes the Sudoku propositions and writes `sudoku.cnf`.
- `sol2grid.ml` — reads Z3 model output and writes grid in `output.txt`.
- `check_sudoku.ml` — verifies a solution against the original puzzle. (provided by the instructor)
- `check_unique.ml` — prepares a CNF that to test uniqueness.
- `Makefile` — for build and convinience of use.

## Notes
- The CNF variable indexing and encoding are implemented in `main.ml` and support multiple grid sizes (e.g., 4×4, 9×9, 16×16) based on the number of input lines.
- The project expects `z3` on PATH. If Z3 binary is named differently, update the Makefile or call Z3 directly.

## Logical overview
- Each cell (i,j) can take values from 1 to n*n. We encode this using propositional variables x_i,j,d which is true if cell (i,j) contains digit d. 
- For the CNF encoding, x_i,j,d is mapped to variable (i-1)*n*n*n + (j-1)*n*n + d.
- The CNF clauses ensure:
  - Each cell has atleast one number 
  - Each cell has atmost one number 
  - Each number appears atleast once in a row 
  - Each number appears atleast once in a column 
  - Each number appears atleast once in a box 
  - Each number appears atmost once in a row
  - Each number appears atmost once in a column
  - Constraints -> one clause for each value pre-provided (if we know cell(1,1) has 8 then x_1,1,8 is the corresponding clause)

Note: The clauses for each number appearing atmost once in a box is not explicitly put in the CNF file as the row and column uniqueness clauses already imply this condition. (And even though atmost once per row/column are also implied by the other conditions, removing them causes a significant slowdown in Z3 solving time. Hence they are not excluded)