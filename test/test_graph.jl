function test_isa(onto, term1, term2)
    @test is_a(onto, term1, term2)
    @test !is_a(onto, term2, term1)
end

@testset "is_a relationship tests" begin
    GO = OBOParse.load("$testdir/data/go_mini.obo", "GO")

    term1 = gettermbyid(GO, 1)
    term2 = gettermbyid(GO, 2)
    term4 = gettermbyid(GO, 4)
    term5 = gettermbyid(GO, 5)

    test_isa(GO, term1, term2)
    test_isa(GO, term4, term2)
    test_isa(GO, term5, term4)
    test_isa(GO, term5, term2)

    @test !is_a(GO, term1, term5)
    @test !is_a(GO, term5, term1)

    @test parents(GO, term1) == [term2]
    @test isempty(parents(GO, term2))
    @test parents(GO, term4) == [term2]
    @test parents(GO, term5) == [term4]

    @test children(GO, term1) == []
    @test Set(children(GO, term2)) == Set([term1, term4])
    @test children(GO, term4) == [term5]
    @test children(GO, term5) == []

    @test ancestors(GO, term1) == [term2]
    @test Set(ancestors(GO, term5)) == Set([term2, term4])

    @test Set(descendants(GO, term2)) == Set([term1, term4, term5])
    @test descendants(GO, term5) == []
end
