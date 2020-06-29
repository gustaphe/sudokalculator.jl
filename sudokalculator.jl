#!/usr/bin/julia -E

"""
```
sudokalculate(Target[,Ns];<keyword arguments>)
```

Calculate ways to reach target sum `Target` with given constraints, as needed for killer sudoku and similar puzzles.
`Ns=1:9` is the number of digits to use, or a vector of allowed such numbers.

# Arguments
- `include=1:9`: The allowed digits
- `exclude=zeros(Int64,0)`: Digits to exclude (Only digits that are in `include` and are NOT in `exclude` are used)
- `unique=true`: Whether to disallow repeat digits (i.e. disable for little killer diagonals)

# Examples
`sudokalculate(10)` gives a complete list of ways to make between 1 and 9 unique digits add to 10, as well as lower and upper bounds for the number of digits required if different from the supplied.  

`sudokalculate(10,2:3)` specifically lists ways to make 2 or 3 digits add to 10.  

`sudokalculate(10,4,include=2:8)` (or equivalently `sudokalculate(10,4,exclude=[1,9])`) gives a list of ways to make 4 unique digits add to 10, not using 1 and 9 (helpfully informing you that it is impossible).  

`sudokalculate(10,4,unique=false)` gives a list of ways to make any 4 digits between add to 10.  

`sudokalculate(nothing,...)` gives a list of sums reachable with 3 digits with the specified constraints.
"""
function sudokalculate(
		       Target::Union{Int64,Nothing},
		       Ns::Union{Int64,AbstractVector{Int64}}=1:9,
		       ;
		       include::AbstractVector{Int64}=1:9,
		       exclude::Union{Int64,AbstractVector{Int64}}=zeros(Int64,0),
		       unique::Bool=true,
		       )
	digits = setdiff(include,exclude);
	options = Array{Int64}[]; # TODO: I know that the elements of this array will not be longer than maximum(Ns). Would it be more efficient to initialize it as zeros of that length?
	for N = Ns
		push!.(Ref(options),digits[x] for x in getoptions(N,length(digits),unique))
	end

	if !isnothing(Target)
		deleteat!(options,sum.(options) .!== Target);
	end
	if length(options) == 0
		print("There is no way to do that.\n")
		return nothing;
	end
	print.("$x :\t\t\t$(sum(x))\n" for x in options);

	if length(options) == 1
		return nothing
	end

	if isnothing(Target)
		print("You can make every sum in ",conciserange(Base.unique(sort(sum.(options)))),"\n");
		return nothing;
	end

	necessary = Int64[];
	unnecessary = Int64[];
	for d in digits
		s = [ any(x .== d) for x in options ]
		if all(s)
			push!(necessary,d)
		else 
			if !any(s)
				push!(unnecessary,d)
			end
		end
	end

	length(necessary)>0 && print("This will require the use of $(conciserange(necessary))\n");
	length(unnecessary)>0 && print("You cannot use $(conciserange(unnecessary))\n");
	extrema(length.(options))!=extrema(Ns) && print("You will need a number of digits in the range $(extrema(length.(options)))\n")
	return nothing;
end

"Recursive get-options function. Gets the indices for the digits-vector outside."
function getoptions(
		    N::Int64, # Number of digits to find
		    M::Int64, # Max digit
		    unique::Bool, # Reuse digits?
		    )::Array{Array{Int64}}
	if M == 0 # No possibilities left. Will propagate back and ruin everything in a good way. This will happen anyway, but this can save a couple of stacks.
		return [];
	end
	if N == 1
		return [[m] for m=1:M];
	end
	return [vcat(y,x) for x in 1:M for y in getoptions(N-1,x-unique,unique)]; # ( uses disgusting 5-true == 4 and loves it )
end

"""
```
conciserange(R)::String
```

Convert sorted, unique vector (or integer) R to condensed readable form. Print runs of 3 or more consecutive integers as ranges, otherwise separate numbers by comma.

# Examples
```jldoctest
julia>str = conciserange([1,2,3,5,8,9])
"[1:3, 5, 8, 9]"
```
"""
function conciserange(
		      R::Union{Int64,AbstractVector{Int64}},
		      )::String
	sb = IOBuffer();
	print(sb,"[");

	it = Iterators.Stateful(R);
	while !isempty(it)
		f = first(it);
		l = f;
		while(Base.peek(it) == l+1)
			l = first(it);
		end
		if l == f
			print(sb,f);
		elseif l == f+1
			print(sb,f,", ",l);
		else
			print(sb,f,":",l);
		end
		if !isempty(it)
			print(sb,", ");
		end
	end
	print(sb,"]");

	return String(take!(sb));
end

