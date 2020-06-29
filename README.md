# sudokalculator.jl

## sudokalculate
```
sudokalculate(Target[,Ns];<keyword arguments>)
```

Calculate ways to reach target sum `Target` with given constraints, as needed for killer sudoku and similar puzzles.
`Ns=1:9` is the number of digits to use, or a vector of allowed such numbers.

### Arguments
- `include=1:9`: The allowed digits
- `exclude=zeros(Int64,0)`: Digits to exclude (Only digits that are in `include` and are NOT in `exclude` are used)
- `unique=true`: Whether to disallow repeat digits (i.e. disable for little killer diagonals)

### Examples
`sudokalculate(10)` gives a complete list of ways to make between 1 and 9 unique digits add to 10, as well as lower and upper bounds for the number of digits required if different from the supplied.  

`sudokalculate(10,2:3)` specifically lists ways to make 2 or 3 digits add to 10.  

`sudokalculate(10,4,include=2:8)` (or equivalently `sudokalculate(10,4,exclude=[1,9])`) gives a list of ways to make 4 unique digits add to 10, not using 1 and 9 (helpfully informing you that it is impossible).  

`sudokalculate(10,4,unique=false)` gives a list of ways to make any 4 digits between add to 10.  

`sudokalculate(nothing,...)` gives a list of sums reachable with 3 digits with the specified constraints.

## getoptions
Recursive get-options function. Gets the indices for the digits-vector outside.

## conciserange
```
conciserange(R)::String
```

Convert sorted, unique vector (or integer) R to condensed readable form. Print runs of 3 or more consecutive integers as ranges, otherwise separate numbers by comma.

### Examples
```jldoctest
julia>str = conciserange([1,2,3,5,8,9])
"[1:3, 5, 8, 9]"
```
