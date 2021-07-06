using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation
#using Plots, ImageView

include("s_save_image.jl")
include("filter.jl")
include("COM.jl")


function fwhm(data,b_mean,b_std)
        max_d = maximum(data) - b_mean
        #mid_d = Int(floor(findmid(data)))
	mid_d = argmax(data)[1]
        #half_value = max_d /2 + b_mean
	half_value = b_mean + b_std
        sigma = zeros(2,1)
	# find left edge with signal
        for i in 1:mid_d-1
                if data[i] <= half_value && data[i+1] >= half_value
                        sigma[1] = i
                        break
                end
        end
	# find right edge with signal
        for i in 1:size(data,1) - mid_d-1
                if data[end-i] >= half_value && data[end-i+1] <= half_value
                        sigma[2] = size(data,1) - i
                        break
                end
        end
        return (sigma[2] - sigma[1]), (sigma[1]+sigma[2])/2
end

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
filelist=filter(x->occursin(@sprintf("%s",date),x),filelist)
@show filelist

#scene = Scene()
width_list = []
z_list = []
frame_list = []
pos_list = []
pos_range = []
# loop through every image
for k in 1:size(filelist,1)
	filename=filelist[k][1:end-4]
	push!(z_list,parse(Int,filename[14:end-5]))
	exp = load(@sprintf("%s.tif", filename))
	exp = Float32.(exp)
	b_mean = mean(exp)
	flag = 0
	width_temp = []
	pos_temp = []
	# loop through every frame
	for i in 10:size(exp,3)
		img1 = exp[:,:,i]
		img2 = convert(Array{N0f16}, img1)
		line = mean(img2,dims=2)
		b_std = std(line)
		# skip frames without signal
		if(b_std < b_mean/3 && flag == 0) 
			continue 
		end
		# change flag and record signal starting point
		if (flag == 0)
			flag = 1
			push!(frame_list,i)
		end
		# take moving average in line signal
		new_line = zeros(size(line,1),1)
		for i in 5:size(line,1)
			new_line[i] = mean(line[i-4:i])
		end
		# calculate image signal range
		(width , mid) = fwhm(new_line,b_mean,b_std)
		push!(width_temp,width)
		push!(pos_temp,mid)
	end
	push!(width_list,mean(width_temp))
	push!(pos_list,mean(pos_temp))
	push!(pos_range, maximum(pos_temp)-minimum(pos_temp))
end

# print out lightsheet analysis
s = sortperm(z_list)
@show(z_list[s])
@show(width_list[s])
@show(frame_list[s])
@show(pos_list[s])
@show(pos_range)

cd("/home/jchang/image/")

