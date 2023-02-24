include("../src/Autonorm.jl")

using XLSX, DataFrames

export Autonorm

path = "digimon.xlsx"

myfile = Autonorm.prepareInputtedFile(path)

res = Autonorm.normalize(myfile)

display(res)

