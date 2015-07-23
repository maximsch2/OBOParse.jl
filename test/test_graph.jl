function test_isa(onto, term1, term2)
    @fact is_a(onto, term1, term2) => true
    @fact is_a(onto, term2, term1) => false
end

facts("is_a relationship tests") do

    GO = loadOBO("$testdir/data/go_mini.obo", "GO")

    term1 = gettermbyid(GO, 1)
    term2 = gettermbyid(GO, 2)
    term4 = gettermbyid(GO, 4)
    term5 = gettermbyid(GO, 5)

    test_isa(GO, term1, term2)
    test_isa(GO, term4, term2)
    test_isa(GO, term5, term4)
    test_isa(GO, term5, term2)

    @fact is_a(GO, term1, term5) => false
    @fact is_a(GO, term5, term1) => false

    @fact parents(GO, term1) => [term2]
    @fact isempty(parents(GO, term2)) => true
    @fact parents(GO, term4) => [term2]
    @fact parents(GO, term5) => [term4]


    @fact children(GO, term1) => []
    @fact Set(children(GO, term2)) => Set([term1, term4])
    @fact children(GO, term4) => [term5]
    @fact children(GO, term5) => []


    @fact ancestors(GO, term1) => [term2]
    @fact Set(ancestors(GO, term5)) => Set([term2, term4])

    @fact Set(descendants(GO, term2)) => Set([term1, term4, term5])
    @fact descendants(GO, term5) => []
end
