module SudoKalculator

export sudokalculate, sudokupartitions

"""
```julia
sudokalculate(Target[,Ns];<keyword arguments>)
```

Calculate ways to reach target sum `Target` with given constraints, as needed for killer sudoku and similar puzzles.
`Ns=1:9` is the number of digits to use, or a vector of allowed such numbers.

# Arguments
- `digits=1:9`: The allowed digits
- `include=zeros(Int64,0)`: Digits that *must* be present in the final solution. Alternate necessities can be given as tuples in a vector (not as a scalar tuple)
- `exclude=zeros(Int64,0)`: Digits that can not be present in the final solution (equivalent to leaving them out of `digits`)
- `maxrepeats=1`: The maximum number of times the same number can appear.

# Examples
```julia
sudokalculate(10)
```
gives a complete list of ways to make between 1 and 9 unique digits add to 10, as well as lower and upper bounds for the number of digits required if different from the supplied.

```julia
sudokalculate(10,2:3)
```
specifically lists ways to make 2 or 3 digits add to 10.

```julia
sudokalculate(10,4,digits=2:8)
```
(or equivalently `sudokalculate(10,4,exclude=[1,9])`) gives a list of ways to make 4 unique digits add to 10, not using 1 and 9 (helpfully informing you that it is impossible).

```julia
sudokalculate(10,4,maxrepeats=4)
```
gives a list of ways to make any 4 digits add to 10.

```julia
sudokalculate(nothing,...)
```
gives a list of sums reachable with the specified constraints.

```julia
sudokalculate(10,3,include=[1,(2,3)])
```
shows ways to add to 10, necessarilly including a 1 and at least one out of 2 and 3.
"""
function oldsudokalculate(
    Target::Union{Int64,Nothing},
    Ns::Union{Int64,AbstractVector{Int64}}=1:9,
    ;
    digits::AbstractVector{Int64}=1:9,
    include::Union{Int64,AbstractVector{Int64},AbstractVector{<:Any}}=zeros(Int64, 0), # Christ, this type feels like a violation of the point of typing your variables. But since Vector{Int64} !<: Vector{Any} for some reason, I think this is necessary
    exclude::Union{Int64,AbstractVector{Int64}}=zeros(Int64, 0),
    maxrepeats::Int64=1,
)
    digits = setdiff(digits, exclude)
    options = Array{Int64}[] # TODO: I know that the elements of this array will not be longer than maximum(Ns). Would it be more efficient to initialize it as zeros of that length?
    for N in Ns
        push!.(
            Ref(options), digits[x] for x in getoptions(N, length(digits), maxrepeats == 1)
        )
    end

    if !isnothing(Target)
        filter!(o -> sum(o) == Target, options)
    end

    filter!(o -> all(i -> any(d -> any(d .== o), i), include), options) # Deletes any options not containing every digit in `include`
    filter!(o -> !any(d -> count(d .== o) > maxrepeats, digits), options) # Deletes any options with more than `maxrepeats` of any one digit

    if length(options) == 0
        print("There is no way to do that.\n")
        return nothing
    end
    print.("$x :\t\t\t$(sum(x))\n" for x in options)

    if length(options) == 1
        return nothing
    end

    if isnothing(Target)
        print("You can make every sum in ", conciserange(unique(sort(sum.(options)))), "\n")
        return nothing
    end

    necessary = Int64[]
    unnecessary = Int64[]
    for d in digits
        s = [any(x .== d) for x in options]
        if all(s)
            push!(necessary, d)
        else
            if !any(s)
                push!(unnecessary, d)
            end
        end
    end

    length(necessary) > 0 &&
        print("This will require the use of $(conciserange(necessary))\n")
    length(unnecessary) > 0 && print("You cannot use $(conciserange(unnecessary))\n")
    extrema(length.(options)) != extrema(Ns) && print(
        "You will need a number of digits in the range $(extrema(length.(options)))\n"
    )
    return nothing
end

"Recursive get-options function. Gets the indices for the digits-vector outside."
function getoptions(
    N::Int64, # Number of digits to find
    M::Int64, # Max digit
    unique::Bool, # Reuse digits?
)::Array{Array{Int64}}
    if M == 0 # No possibilities left. Will propagate back and ruin everything in a good way. This will happen anyway, but this can save a couple of stacks.
        return []
    end
    if N == 1
        return [[m] for m in 1:M]
    end
    return [vcat(y, x) for x in 1:M for y in getoptions(N - 1, x - unique, unique)] # ( uses disgusting 5-true == 4 and loves it )
end

"""
```julia
conciserange(R)::String
```

Convert sorted, unique vector (or integer) `R` to condensed readable form. Print runs of 3 or more consecutive integers as ranges, otherwise separate numbers by comma.

# Examples
```jldoctest
julia> str = conciserange([1,2,3,5,8,9])
"[1:3, 5, 8, 9]"
```
"""
function conciserange(io::IO, R)
    print(io, "[")
    it = Iterators.Stateful(R)
    while !isempty(it)
        f = first(it)
        l = f
        while (Base.peek(it) == l + 1)
            l = first(it)
        end
        if l == f
            print(io, f)
        elseif l == f + 1
            print(io, f, ", ", l)
        else
            print(io, f, ":", l)
        end
        if !isempty(it)
            print(io, ", ")
        end
    end
    print(io, "]")
    return nothing
end

function conciserange(R)
    sb = IOBuffer()
    conciserange(sb, R)
    return String(take!(sb))
end

function sudokupartitions!(list, root, N, len, atoms, unique)
    if iszero(N) # Target acquired
        if len == 0 || length(root) in len
            return push!(list, root)
        end
    end
    for n in atoms
        arr = vcat(root, n)
        newatoms = filter(x -> x >= n && x <= (N - n), unique ? setdiff(atoms, n) : atoms)
        sudokupartitions!(list, arr, N - n, len, newatoms, unique)
    end
    return nothing
end

"""
```julia
    sudokupartitions(N; length=0, atoms=1:9, unique=true)
```
Returns a vector of all the ways to add to `N`. If `length` is non-zero, uses that many
atoms.  `atoms` is a set of available numbers to use. If `unique` is false, numbers can be
used more than once. If `N` is a collection, a `Dict` is returned. `length` can also be a
collection of allowed lengths.
"""
function sudokupartitions(N::Integer; length=0, atoms=1:9, unique=true)
    if iszero(N)
        if length == 0
            @error "Specify target number or length"
        end
        atoms = sort(atoms)
        if unique
            m = sum(first(atoms, minimum(length)))
            M = sum(last(atoms, maximum(length)))
        else
            m = minimum(length) * first(atoms)
            M = maximum(length) * last(atoms)
        end
        return sudokupartitions(m:M; length, atoms, unique)
    end
    list = Vector{eltype(atoms)}[]
    sudokupartitions!(list, eltype(atoms)[], N, length, atoms, unique)
    return list
end

function sudokupartitions(Ns; kwargs...)
    return filter(x -> !isempty(x.second), Dict(Ns .=> sudokupartitions.(Ns; kwargs...)))
end

function sudokupartitions(; length=1:9, kwargs...)
    return sudokupartitions(0; length, kwargs...)
end

function sudokalculate(N, len, atoms=1:9, uniq=true)
    partitiondict = sudokupartitions(N; length=len, atoms, unique=uniq)
    iszero(length(partitiondict)) && return println("There is no way to do that.")
    if all(N .== 0)
        N = sort(keys(partitiondict))
    end
    mainhalal = collect(atoms)
    mainharam = collect(atoms)
    mainlens = []
    for x in filter(>(0), N)
        print(x, "\n=====\n")
        y = get(partitiondict, x, [])
        if isempty(y)
            print("Impossible\n\n")
            continue
        end
        println.(y)
        println()
        halal = filter(n -> all(in.(n, y)), atoms)
        intersect!(mainhalal, halal)
        haram = filter(n -> !any(in.(n, y)), atoms)
        intersect!(mainharam, haram)
        lens = sort(unique(length.(y)))
        union!(mainlens, lens)
        length(halal) > 0 && println("Must use ", conciserange(halal))
        length(haram) > 0 && println("Cannot use ", conciserange(haram))
        !all(in(lens), len) && println("Will require ", conciserange(lens), " digits")
        println()
    end
    isone(length(N)) && return nothing
    print("Total\n====\n")
    length(mainhalal) > 0 && println("Must use ", conciserange(mainhalal))
    length(mainharam) > 0 && println("Cannot use ", conciserange(mainharam))
    !all(in(mainlens), len) && println("Will require ", conciserange(mainlens), " digits")
    return nothing
end

sudokalculate(N::Integer, args...; kwargs...) = sudokalculate([N], args...; kwargs...)

sudokalculate(N; length=0, atoms=1:9, unique=true) = sudokalculate(N, length, atoms, unique)

end #module
