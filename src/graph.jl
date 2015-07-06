using Graphs

typealias TermVertex KeyVertex{Term}

import Base: ==, isequal

isequal(tv1::TermVertex, tv2::TermVertex) = isequal(tv1.key, tv2.key)
==(tv1::TermVertex, tv2::TermVertex) = isequal(tv1, tv2)

type GOGraph
    ids::Vector{TermID}
    upward::IncidenceList{TermVertex,Edge{TermVertex}}
    downward::IncidenceList{TermVertex,Edge{TermVertex}}

    function GOGraph(filepath::String; mode::Int=2)
        ids, upward, downward = gograph_builder(filepath, mode)
        new(ids, upward, downward)
    end
end

type ISAVisitor <: AbstractGraphVisitor
    target::TermVertex
    found::Bool

    function ISAVisitor(target::TermVertex)
        new(target, false)
    end
end

function Graphs.discover_vertex!(visitor::ISAVisitor, v::TermVertex)
    # if discovered the target, immediately finish traversing
    if v == visitor.target
        visitor.found = true
        return false
    end
    true
end

# check whether term1 *is a* term2 or not
function is_a(go::GOGraph, term1::Term, term2::Term)
    id = binary_search(go.ids, term1.id)
    v = TermVertex(id, term1)
    pid = binary_search(go.ids, term2.id)
    pv = TermVertex(pid, term2)
    visitor = ISAVisitor(pv)
    traverse_graph(go.upward, DepthFirst(), v, visitor)
    visitor.found
end

function binary_search(ids::Vector{TermID}, id::TermID)
    isempty(ids) && return 0
    l = 1
    n = endof(ids)
    while n >= l
        m = div(n - l, 2) + l
        if id < ids[m]
            n = m - 1
        elseif id > ids[m]
            l = m + 1
        else
            return m
        end
    end
    0
end

function search_vertex(go::GOGraph, term::Term)
    id = binary_search(go.ids, term.id)
    id == 0 && error("term $term does not exist in the ontology graph")
    TermVertex(id, term)
end

function gograph_builder(filepath::String, mode::Int)
    parser = OBOParser(filepath, mode=mode)
    terms = Term[]

    # accumulate all terms
    for term in eachterm(parser)
        push!(terms, term)
    end

    sort!(terms)
    upward = inclist(TermVertex)
    downward = inclist(TermVertex)
    ids = TermID[]

    # add term vertices
    for (i, term) in enumerate(terms)
        v = KeyVertex{Term}(i, term)
        add_vertex!(upward, term)
        add_vertex!(downward, term)
        push!(ids, term.id)
    end

    # add edges between two terms
    for (i, term) in enumerate(terms)
        v = TermVertex(i, term)
        for pid in term.isa
            ip = binary_search(ids, pid)
            @assert ip != 0
            parent = terms[ip]
            vp = TermVertex(ip, parent)
            add_edge!(upward, v, vp)
            add_edge!(downward, vp, v)
        end
    end

    ids, upward, downward
end

function parents(go::GOGraph, term::Term)
    v = search_vertex(go, term)
    Term[p.key for p in out_neighbors(v, go.upward)]
end

function children(go::GOGraph, term::Term)
    v = search_vertex(go, term)
    Term[p.key for p in out_neighbors(v, go.downward)]
end
