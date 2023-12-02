#!/bin/sh -xeu

# Reset expected files whatever's checked into git.
git restore expect

### Initial/manual examples using multiply.pl0.
#./pl0_lexer.py < examples/multiply.pl0
#./pl0_parser.py < examples/multiply.pl0
#./pl0_graphviz.py < examples/multiply.pl0
#./pl0_interpreter.py < examples/multiply.pl0
#./pl0_compiler.py < examples/multiply.pl0 | ./pl0_assembler.py | ./pl0_machine.py

### The fibonacci example.
# pl0_lexer.py is used by pl0_parser.py.
# pl0_parser.py and pl0_node_visitor.py are then used by several other source files.
./pl0_interpreter.py < examples/fibonacci.pl0 > expect/fibonacci.run
./pl0_compiler.py < examples/fibonacci.pl0 > expect/fibonacci.asm
./pl0_compiler.py < examples/fibonacci.pl0 | ./pl0_assembler.py | ./pl0_machine.py > expect/fibonacci.run2

# Handwritten assembler variant.
#./pl0_assembler.py < examples/fibonacci.pl0a | ./pl0_machine.py

# Check graphviz output (for parse tree visualization).
#./pl0_graphviz.py < examples/fibonacci.pl0
#(sleep 1; mv graph.dot expect/fibonacci.dot; rm -f graph.pdf) &

### Run all examples using the interpreter, compiler, and the alternative compiler to Forth.
for f in examples/*.pl0 tests/*.pl0; do
  : $f
  ./pl0_interpreter.py < $f
  ./pl0_compiler.py < $f | ./pl0_assembler.py | ./pl0_machine.py
  ./pl0_ansforth.py < $f | gforth
done

## Retro Forth 11 backend tests.
for f in tests/*.pl0 ; do
  # Strip the path and extension.
  name="$(basename $f)" # Remove the directory prefix.
  name="${name%.pl0}"   # Remove the '.pl0' suffix.

  # Run the file through the retro compiler.
  ./pl0_retro11.py $f > expect/retro11/$name.rx
done

# Check changes in the generated output.
git diff --exit-code --word-diff expect