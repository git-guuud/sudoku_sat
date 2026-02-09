compile: main sol2grid check_sudoku check_unique

main: main.ml
	ocamlc main.ml -o main
	rm -f *.cm[io]

sol2grid: sol2grid.ml
	ocamlc sol2grid.ml -o sol2grid 
	rm -f *.cm[io]

check_sudoku: check_sudoku.ml
	ocamlc check_sudoku.ml -o check_sudoku 
	rm -f *.cm[io]

check_unique: check_unique.ml
	ocamlc check_unique.ml -o check_unique
	rm -f *.cm[io]

z3_out.txt: main input.txt
	./main 
	z3 -dimacs sudoku.cnf > z3_out.txt 

run: sol2grid z3_out.txt 
	cat z3_out.txt | ./sol2grid 

check_sol: check_sudoku run 
	./check_sudoku "output.txt" "input.txt"

check_uni: check_unique z3_out.txt
	@if ./check_unique; then \
		(z3 -dimacs check_unique.cnf | \
		if grep -q "s UNSATISFIABLE"; then \
			echo "Unique solution"; \
		else \
			echo "Multiple solutions"; \
		fi); \
	else \
		echo "\eNo solution"; \
	fi
