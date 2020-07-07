var documenterSearchIndex = {"docs":
[{"location":"#SudoKalculator.jl-Documentation","page":"SudoKalculator.jl Documentation","title":"SudoKalculator.jl Documentation","text":"","category":"section"},{"location":"","page":"SudoKalculator.jl Documentation","title":"SudoKalculator.jl Documentation","text":"sudokalculate","category":"page"},{"location":"#SudoKalculator.sudokalculate","page":"SudoKalculator.jl Documentation","title":"SudoKalculator.sudokalculate","text":"sudokalculate(Target[,Ns];<keyword arguments>)\n\nCalculate ways to reach target sum Target with given constraints, as needed for killer sudoku and similar puzzles. Ns=1:9 is the number of digits to use, or a vector of allowed such numbers.\n\nArguments\n\ndigits=1:9: The allowed digits\ninclude=zeros(Int64,0): Digits that must be present in the final solution. Alternate necessities can be given as tuples in a vector (not as a scalar tuple)\nexclude=zeros(Int64,0): Digits that can not be present in the final solution (equivalent to leaving them out of digits)\nmaxrepeats=0: The maximum number of times the same number can appear.\n\nExamples\n\nsudokalculate(10)\n\ngives a complete list of ways to make between 1 and 9 unique digits add to 10, as well as lower and upper bounds for the number of digits required if different from the supplied.  \n\nsudokalculate(10,2:3)\n\nspecifically lists ways to make 2 or 3 digits add to 10.  \n\nsudokalculate(10,4,digits=2:8)\n\n(or equivalently sudokalculate(10,4,exclude=[1,9])) gives a list of ways to make 4 unique digits add to 10, not using 1 and 9 (helpfully informing you that it is impossible).  \n\nsudokalculate(10,4,maxrepeats=4)\n\ngives a list of ways to make any 4 digits between add to 10.  \n\nsudokalculate(nothing,...)\n\ngives a list of sums reachable with 3 digits with the specified constraints.\n\nsudokalculate(10,3,include=[1,(2,3)])\n\nshows ways to add to 10, necessarilly including a 1 and at least one out of 2 and 3.\n\n\n\n\n\n","category":"function"}]
}
