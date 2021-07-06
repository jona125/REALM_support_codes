using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation
#using Plots, ImageView
include("img_save.jl")

function BG_subtraction(exp,BG_filename,filename,Save)
	img = load(@sprintf("%s.tif", BG_filename))
	img1 = convert(Array{N0f16}, img)
		
	
	(x,y,z) = size(img1)
	b_mean = zeros(x,y)
	b_std = zeros(x,y)
	
	@showprogress "Preprocssing background file..." for i in 1:x
		for j in 1:y
			b_mean[i,j] = mean(img1[i,j,:])
			b_std[i,j] = std(img1[i,j,:])
		end
	end
	
    	img1 = convert(Array{N0f16}, exp)
	(x,y,z) = size(img1)
	
	result = []
	filtered = zeros(x,y,z)
	count = 0
	@showprogress @sprintf("Background filtering of Record %s...",filename) for t in 1:size(exp,3)
		img2 = img1[:,:,t]
	
		for i in 1:x
			for j in 1:y
				if(img2[i,j] >= b_mean[i,j] + 2*b_std[i,j])
					filtered[i,j,t] = img2[i,j] - b_mean[i,j]
				end
			end
		end
	end
	if Save
		img_save(filtered,"/home/jchang/image/result/",@sprintf("%s-bi.tif",filename))
	end
	return filtered
end	


