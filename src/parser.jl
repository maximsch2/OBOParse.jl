# The OBO Flat File parser

immutable Stanza
    Typ::String # Official ones are: "Term", "Typedef" and "Instance"
    id::String
    tagvalues::Dict{String, Vector{String}}
end

function find_first_nonescaped(s, ch)
    i = searchindex(s, ch)
    while i > 0
        numescapes = 0
        @inbounds for j in i-1:-1:1
            (s[j] == '\\') || break
            numescapes += 1
        end
        iseven(numescapes) && return i # this is not escaped
        i = searchindex(s, ch, i+1)
    end
    return i
end

function removecomments(line)
    i = find_first_nonescaped(line, "!")
    return i > 0 ? line[1:i-1] : line
end

const id_tag = "id"

function parseOBO(stream::IO)
    # first set of tag values is a header
    header, nextstanza = parsetagvalues(stream)
    stanzas = Stanza[]
    while nextstanza != ""
        prevstanza = nextstanza
        vals, nextstanza = parsetagvalues(stream)
        haskey(vals, id_tag) || error("Stanza is missing ID tag")
        id = vals[id_tag][1]
        push!(stanzas, Stanza(prevstanza, id, vals))
    end

    return header, stanzas
end


parseOBO(filepath::AbstractString) = open(parseOBO, filepath, "r")

const r_stanza = r"^\[(.*)\]$"

function parsetagvalues(s)
    vals = Dict{String, Vector{String}}()

    for line in eachline(s)
        line = strip(removecomments(line))
        m = match(r_stanza, line)
        (m !== nothing) && return vals, m.captures[1]

        isempty(line) && continue

        tag, value, ok = tagvalue(line)
        ok || error("cannot find a tag (position: $(position(s))), empty: $(isempty(line)), line: `$(line)`")
        push!(get!(()->Vector{String}(), vals, tag), value)
    end

    return vals, ""
end


function tagvalue(line)
    # TODO: what an ad hoc parser!
    i = searchindex(line, ": ")
    if i == 0
        # empty tag value
        endswith(line, ":") && (return line, "", true)

        # empty strings are dummy
        return "", "", false
    end

    j = searchindex(line, " !")
    tag = line[1:i-1]
    value = j==0 ? line[i+2:end] : line[i+2:j-1]

    return tag, value, true
end

function getuniqueval(st::Stanza, tagname, def::String="")
    if haskey(st.tagvalues, tagname)
        arr = st.tagvalues[tagname]
        (length(arr) > 1) && error("Expect unique tag named $tagname")
        return arr[1]
    else
        return def
    end
end

function getterms(arr::Vector{Stanza})
    result = Dict{String, Term}()

    for st in arr
        st.Typ == "Term" || continue

        term_obsolete = getuniqueval(st, "is_obsolete") == "true"
        term_name = getuniqueval(st, "name")
        term_def = getuniqueval(st, "def")
        term_namespace = getuniqueval(st, "namespace")
        if haskey(result, st.id)
            # term was automatically created, re-create it with the correct properties,
            # but preserve the existing relationships
            term = result[st.id] = Term(result[st.id], term_name, term_obsolete, term_namespace, term_def)
        else # brand new term
            term = result[st.id] = Term(st.id, term_name, term_obsolete, term_namespace, term_def)
        end

        for otherid in get(st.tagvalues, "is_a", String[])
            otherterm = get!(() -> Term(otherid), result, otherid)
            push!(relationship(term, :is_a), otherid)
            push!(rev_relationship(otherterm, :is_a), st.id)
        end

        for rel in get(st.tagvalues, "relationship", String[])
            rel = strip(rel)
            tmp = split(rel)
            length(tmp) == 2 || error("Failed to parse relationship field: $rel")

            rel_type = Symbol(tmp[1])
            rel_id = tmp[2]
            otherterm = get!(() -> Term(rel_id), result, rel_id)

            push!(relationship(term, rel_type), rel_id)
            push!(rev_relationship(otherterm, rel_type), st.id)
        end

        if isobsolete(term) && length(relationship(term ,:is_a)) > 0
            error("Obsolete term $term contains is_a relationship")
        end

        append!(term.synonyms, get(st.tagvalues, "synonym", String[]))
        for (k, v) in st.tagvalues
            append!(get!(() -> Vector{String}(), term.tagvalues, k), v)
        end

    end
    result
end

function gettypedefs(arr::Vector{Stanza})
    result = Dict{String, Typedef}()
    result
end
