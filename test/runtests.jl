using SudoKalculator
using Test
@testset "Trying conciserange" begin
	@test SudoKalculator.conciserange([1,2,3,4,6,7,10]) == "[1:4, 6, 7, 10]"
end
@testset "Trying getoptions" begin
	@test SudoKalculator.getoptions(2,3,true) == [[1,2],[1,3],[2,3]]
	@test SudoKalculator.getoptions(2,3,false) == [[1,1],[1,2],[2,2],[1,3],[2,3],[3,3]]
end

