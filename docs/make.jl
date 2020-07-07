push!(LOAD_PATH,"../src/")
using Documenter, SudoKalculator
makedocs(
	 repo="https://github.com/gustaphe/sudokalculator.jl.git",
	 sitename="SudoKalculator",
	 );

deploydocs(
	   repo = "github.com/gustaphe/sudokalculator.jl.git",
	   );

