module OBOParse

export
    # term
    isobsolete, is_a,

    # parser
    loadOBO,
    gettermbyid, gettermbyname


include("term.jl")
include("parser.jl")
include("ontology.jl")

end # OBOParse module
