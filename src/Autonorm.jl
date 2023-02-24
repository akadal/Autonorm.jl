module Autonorm

using SQLite, DataFrames, XLSX, Random, Metaheuristics

struct Problem

    nrow::Integer
    ncol::Integer
    vars::Array{String}
    m::Integer
    tab::Integer
    chsize::Integer
    data::DataFrame
    
end

struct Candidate

    ch::Array{Integer}
    matrix::Matrix{Int64}
    tablesByVariables::Array{Integer}
    tablesUnique::Array{Integer}
    db::Dict

end

function normalize(data::DataFrame)

    m = calculateM(data)

    prob = prepareProblem(data, m)

    res = optimize(prob)

    return res
    
end

function optimize(prob::Problem)

    minimizer = gaSearch(prob)
    
    candidate = toPhenotype(minimizer, prob)

    return candidate

end

function toPhenotype(ch, prob)

    theMatrix = chToMatrix(ch, prob)
    
    theTables = matrixToTables(theMatrix, prob)
    
    db = tablesToDb(theTables, prob)

    candidate = Candidate(ch, theMatrix, theTables, unique(theTables), db)

    return candidate

end

function tablesToDb(theTables, prob::Problem)::Dict
    
    myDict = Dict()

    for i in unique(theTables)

        push!(myDict, "table$i" => unique(prob.data[:,findall(theTables .== i)]) )

    end

    return myDict

end

function chToMatrix(ch::Vector{Bool}, prob::Problem)

    theMatrix = zeros(Int, prob.ncol, prob.m)
    
    for r in 1:prob.ncol
        for c in 1:prob.m
            theMatrix[r, c] = ch[(r+c)]
        end
    end

    return theMatrix
    
end

function matrixToTables(theMatrix, prob::Problem)
    
    theTables = []

    for r in 1:prob.ncol

        push!(theTables, parse(Int, join(theMatrix[r,:], ""), base=2))

    end

    return theTables

end

function evaluate(ch, prob::Problem)::Float64

    theMatrix = chToMatrix(ch, prob)

    theTables = matrixToTables(theMatrix, prob)

    db = tablesToDb(theTables, prob)

    candidate = Candidate(ch, theMatrix, theTables, unique(theTables), db)
    
    ffs = fitnessFunctions()
    score = 0
    
    for f in ffs

        score = score + f(ch, candidate)

    end

    return score

end

function fitnessFunctions()
    
    return [
        _ff1
    ]

end

function _ff1(ch, candidate)::Float64

    score = 0

    for (key, df) in candidate.db

        score = score + nrow(df) * (ncol(df) + 1)

    end

    return score
    
end

function _ff2(ch, candidate)::Float64


    
end

function _ff3(ch, candidate)::Float64


    
end

function _ff4(ch, candidate)::Float64


    
end

function gaSearch(prob::Problem)

    res = Metaheuristics.optimize((ch)->evaluate(ch, prob), repeat([false, true], 1, prob.chsize), GA())

    return Metaheuristics.minimizer(res)

end

function prepareProblem(data::DataFrame, m::Integer)::Problem

    dataNames = names(data)
    rename!(data, Symbol.(createColNames(ncol(data))))
    
    return Problem(
        nrow(data),
        ncol(data),
        dataNames,
        m,
        2^m,
        m * ncol(data),
        data
    )

end

function calculateM(data::DataFrame)::Integer
    
    return max(2,ceil(log2(ncol(data))))

end

function createColNames(n::Int)
    v = Vector{String}(undef, n)
    for i in 1:n
        v[i] = "v" * string(i)
    end
    return v
end

function prepareInputtedFile(path::String)::DataFrame
    inputtedFile = XLSX.readxlsx(path)
    sheetNames = XLSX.sheetnames(inputtedFile)
    firstSheetName = sheetNames[1]
    theData = DataFrame(XLSX.readtable(path, firstSheetName))
    return theData
end














"""
    getdatabase()

# Arguments

No arguments

# Description
Connects to a on-memory-database file and returns a SQLite.DB object.

# Output


# Examples
```julia-repl
julia> db = getdatabase()
SQLite.DB(":memory:")
```
# References

"""
function getdatabase()::SQLite.DB 
    return SQLite.DB()
end  


"""
    getdatabase(s)

# Arguments
- `s::AbstractString`: Path to database file.

# Description
Connects to a database file and returns a SQLite.DB object.

# Output


# Examples
```julia-repl
julia> db = getdatabase("test.db")
```
# References

"""
function getdatabase(s::AbstractString)::SQLite.DB 
    return SQLite.DB(s)
end 

function chromosomesize(attributes::Int)::Int
    return ceil(log2(attributes)) * attributes
end 

end # module Autonorm
