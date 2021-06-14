using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation
include("s_save_image.jl")
include("filter.jl")
include("cut_region.jl")
include("flat_recon.jl")
include("BG_correct.jl")

print("Disk label: ")
label = chomp(readline())

print("Date: ")
date=chomp(readline())
#date="20190315"
@show date

transfertotif(label,date)
imfilter(label,date)

print("File title: ")
date=chomp(readline())

cut_region(date)
flat_recon(date)
BG_correct(date)

