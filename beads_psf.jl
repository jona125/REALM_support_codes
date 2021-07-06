using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation
#using Plots, ImageView

include("psf_fun.jl")
include("s_save_image.jl")
include("filter.jl")
include("psf_analyze.jl")

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

	transfertotif(exp,filename,r,l) # save .imagine into .tif
	files=readdir()
	framelist=filter(x->occursin(".tif",x),files)
	framelist=filter(x->occursin(@sprintf("%s",filename),x),framelist)
	
	for i in 1:size(framelist,1)
		filename=framelist[i][1:end-4]
		exp = load(@sprintf("%s.tif", filename))

		img = BG_subtraction(exp,BG_filename,filename,Save)# filter image with background signal
		psf_analyze(img,filename)
	end
end





