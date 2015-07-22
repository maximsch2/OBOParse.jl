
type Ontology
    header
    prefix
    terms::Dict{UTF8String, Term}
    typedefs::Dict{UTF8String, Typedef}
end

function loadOBO(fn::String, prefix)
    header, stanzas = parseOBO(fn)
    terms = getterms(stanzas)
    typedefs = gettypedefs(stanzas)
    Ontology(header, prefix, terms, typedefs)
end

function gettermbyname(ontology::Ontology, name::String)
    lname = lowercase(name)
    for term in values(ontology.terms)
        if lowercase(term.name) == lname
            return term
        end
    end
    error("Term not found: $name")
end

gettermid(ontology::Ontology, id::Integer) = @sprintf("%s:%07d", ontology.prefix, id)

gettermbyid(ontology::Ontology, id::String) = ontology.terms[id]
gettermbyid(ontology::Ontology, id::Integer) = gettermbyid(ontology, gettermid(ontology, id))

import Base.length
length(ontology::Ontology) =  length(ontology.terms)

parents(ontology::Ontology, term::Term) = [is_a(term)...]

children(ontology::Ontology, term::Term) = [filter(t -> t != term && term in parents(ontology, t), values(ontology.terms))...]

descendants(ontology::Ontology, term::Term) = [filter(t -> t != term && is_a(t, term), values(ontology.terms))...]

ancestors(ontology::Ontology, term::Term) = [filter(t -> t != term && is_a(term, t), values(ontology.terms))...]


function is_a(term1::Term, term2::Term)
    if term1 == term2
        return true
    end
    if length(is_a(term1)) == 0
        return false
    end
    for p in is_a(term1)
        if is_a(p, term2)
            return true
        end
    end
    return false
end
