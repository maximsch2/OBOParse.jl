function test_isa(term1, term2)
    @fact is_a(term1, term2) => true
    @fact is_a(term2, term1) => false
end

facts("is_a relationship") do

    GO = loadOBO("$testdir/data/go_mini.obo", "GO")

    term1 = gettermbyid(GO, 1)
    term2 = gettermbyid(GO, 2)
    term4 = gettermbyid(GO, 4)
    term5 = gettermbyid(GO, 5)

    test_isa(term1, term2)
    test_isa(term4, term2)
    test_isa(term5, term4)
    test_isa(term5, term2)

    @fact is_a(term1, term5) => false
    @fact is_a(term5, term1) => false

end

    # @test parents(term1) == [term2]
    # @test isempty(parents(term2))
    # @test parents(term4) == [term2]
    # @test parents(term5) == [term4]
    #
    # @test isempty(children(term1))
    # @test children(term2) == [term1, term4]
    # @test children(term4) == [term5]
    # @test isempty(children(term5))
