using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation
#using Plots, ImageView

include("s_save_image.jl")
include("filter.jl")
include("grid_fun.jl")

INITIAL_FLAG = 1


print("Disk label: ")
label = chomp(readline())

print("Date: ")
date=chomp(readline())
#date="20190315"
@show date

cd(@sprintf("/mnt/%s/jchang/%s/",label,date))
files=readdir()
filelist=filter(x->occursin(".imagine",x),files)
@show filelist

print("add scale bar(Y as 1, N as 0): ")
r=chomp(readline())
r=parse(Int,r)

l=0        
if r == 1
	print("The length of scale bar(in px): ")
        l = chomp(readline())
        l = parse(Int,l)
end

print("Background Filename: ")
BG_filename = chomp(readline())

if BG_filename == ""
	BG_filename = filelist[1][1:end-8]
end

print("Save every file during process (1 as Yes, 0 as No): ")
Save = chomp(readline())
Save = (Save == "1")

for k in 1:size(filelist,1)
	filename=filelist[k][1:end-8]
	exp = load(@sprintf("%s.imagine", filename))

	transfertotif(exp,filename,r,l)
	img = BG_subtraction(exp,BG_filename,filename,Save)
end

cd("/home/jchang/image/result")
files=readdir()
filelist=filter(x->occursin("-bi.tif",x),files)
filelist=filter(x->occursin("_grid",x),filelist)
filelist=filter(x->occursin(@sprintf("%s",date),x),filelist)
@show filelist

width_list = []
z_list = []
frame_list = []
pos_list = []
pos_range = []
stript_list = []
space_list = []
# loop through every image
for k in 1:size(filelist,1)
	filename=filelist[k][1:end-4]
	push!(z_list,parse(Int,filename[16:end-3]))
	exp = Float32.(load(@sprintf("%s.tif", filename)))
	width, pos_temp, frame, stript_width, space_width = grid_slice(exp)
	push!(frame_list,frame)
	push!(width_list,mean(width))
	push!(pos_list,mean(pos_temp))
	push!(pos_range, maximum(pos_temp)-minimum(pos_temp))
	push!(stript_list, stript_width)
	push!(space_list,space_width)
end

# print out lightsheet analysis
s = sortperm(z_list)
@show(z_list[s])
@show(width_list[s])
@show(frame_list[s])
@show(pos_list[s])
@show(stript_list[s])
@show(space_list[s])
@show(pos_range[s])

cd("/home/jchang/image/")

