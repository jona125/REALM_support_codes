using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation
#using Plots, ImageView

include("psf_fun.jl")
include("s_save_image.jl")
include("filter.jl")
include("psf_analyze.jl")

print("Disk label: ")
label = chomp(readline())

print("Date: ")
date=chomp(readline())
#date="20190315"
@show date

transfertotif(label,date) # save .imagine into .tif
imfilter(label,date) # filter image with background signal
psf_analyze(label,date)


