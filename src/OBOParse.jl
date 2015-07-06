module OBOParse

export
    # term
    Term, isobsolete, is_a,

    # parser
    parseOBO, getterms


include("term.jl")
include("parser.jl")

end # OBOParse module
