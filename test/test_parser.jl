import OBOParse.removecomments
import OBOParse.parseOBO, OBOParse.getterms


facts("removecomments tests") do
    @fact removecomments("test") --> "test"
    @fact removecomments("! this is commment") --> ""
    @fact removecomments("test ! comment") --> "test "
    @fact removecomments("test \\! aa") --> "test \\! aa"
end


facts("parseOBO() tests") do
    header, stanzas = parseOBO("$testdir/data/go_mini.obo")
    @fact length(stanzas) --> 4
    @fact header["format-version"] --> ["1.2"]

    terms = getterms(stanzas)
    @fact length(terms) --> 4
end

facts("load() tests") do
    GO = OBOParse.load("$testdir/data/go_mini.obo", "GO")

    @fact length(GO) --> 4
end

facts("test parse GO") do
  GO = OBOParse.load("$testdir/data/go.obo", "GO")
  @fact length(GO) --> greater_than(71)

  term1 = gettermbyid(GO, 18)
  term2 = gettermbyid(GO, 6310)


  @fact relationship(term1, :regulates) --> [term2]
  @fact relationship(term2, :regulates) --> []
end

#
# let
#     parser = OBOParser("$testdir/data/go.obo")
#     @test parser.filepath == "$testdir/data/go.obo"
#     @test parser.version == "1.2"
#     @test parser.headertags["data-version"] == "releases/2014-08-09"
#     @test parser.headertags["auto-generated-by"] == "TermGenie 1.0"
# end
#
# let
#     parser = OBOParser("$testdir/data/go.obo")
#     terms = Array(Term, 0)
#     typedefs = Array(Typedef, 0)
#
#     for term in eachterm(parser)
#         push!(terms, term)
#     end
#
#     for typedef in eachtypedef(parser)
#         push!(typedefs, typedef)
#     end
#
#     # NOTE: the equality of two terms is defined by their GO id only
#     @test isequal(terms[1], Term("GO:0000001", "mitochondrion inheritance"))
#     @test terms[1] == Term("GO:0000001", "mitochondrion inheritance")
#     @test terms[2] == Term("GO:0000002", "mitochondrial genome maintenance")
#     @test terms[4] == Term("GO:0000005", "ribosomal chaperone activity")
#     # ...
#     @test terms[end] == Term("GO:0000086", "G2/M transition of mitotic cell cycle")
#
#     # is_obsolete flag
#     @test !isobsolete(terms[2])
#     @test isobsolete(terms[4])
#
#     # [Term]
#     # id: GO:0000001
#     # name: mitochondrion inheritance
#     # namespace: biological_process
#     # def: "The distribution of mitochondria, including the mitochondrial genome, into daughter cells after mitosis or meiosis, mediated by interactions between mitochondria and the cytoskeleton." [GOC:mcc, PMID:10873824, PMID:11389764]
#     # synonym: "mitochondrial inheritance" EXACT []
#     # is_a: GO:0048308 ! organelle inheritance
#     # is_a: GO:0048311 ! mitochondrion distribution
#     @test is(terms[1].namespace, biological_process)
#     @test terms[1].def == "The distribution of mitochondria, including the mitochondrial genome, into daughter cells after mitosis or meiosis, mediated by interactions between mitochondria and the cytoskeleton."
#
#     # [Typedef]
#     # id: ends_during
#     # name: ends_during
#     # namespace: external
#     # xref: RO:0002093
#     @test typedefs[1] == Typedef("ends_during", "ends_during", "external", "RO:0002093")
#     @test typedefs[end] == Typedef("happens_during", "happens_during", "external", "RO:0002092")
# end
