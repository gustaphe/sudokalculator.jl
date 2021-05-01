using SudoKalculator: conciserange, getoptions, sudokupartitions
using Test
@testset "Trying conciserange" begin
    @test conciserange([1, 2, 3, 4, 6, 7, 10]) == "[1:4, 6, 7, 10]"
end
@testset "Trying getoptions" begin
    @test getoptions(2, 3, true) == [[1, 2], [1, 3], [2, 3]]
    @test getoptions(2, 3, false) == [[1, 1], [1, 2], [2, 2], [1, 3], [2, 3], [3, 3]]
end

@testset "sudokupartitions" begin
    @test length(sudokupartitions(9)) == 8
    @test length(sudokupartitions(9; atoms=[1, 2, 3, 6, 8])) == 3
    @test length(sudokupartitions(9; unique=false)) == 30
    @test isempty(sudokupartitions(9; atoms=[1, 2, 3]))
    @test length(sudokupartitions(1:2; unique=false)) == 2
    @test length(sudokupartitions(1:3; length=2, unique=false)) == 2
    @test length(sudokupartitions(; length=1)) == 9
end
