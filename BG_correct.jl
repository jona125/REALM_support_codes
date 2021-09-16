using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation
#using Plots, ImageView
include("img_save.jl")

function BG_correct(img,filename,GRIN)
	(x,y,z) = size(img)
	b_mean = zeros(z,1)
	@showprogress @sprintf("Background calculating for Record %s...",filename) for i in 1:z
		b_mean[i] = mean(img[:,:,i])
	end
	base = maximum(b_mean)

	filtered = zeros(x,y,z)
	@showprogress @sprintf("Light sheet filtering of Record %s...",filename) for t in 1:size(img,3)
		img2 = img[:,:,t]

		for i in 1:x
			for j in 1:y
				filtered[i,j,t] = img2[i,j] - b_mean[t] + base
				if (filtered[i,j,t] >= 1) filtered[i,j,t] = 1 end
			end
		end
	end
	if(GRIN==1)
		b_mean = zeros(x,y)
		for i in 1:x
			for j in 1:y
				b_mean[i,j] = mean(filtered[i,j,:])
			end
		end
		base = maximum(b_mean)		

		@showprogress @sprintf("GRIN lens correction of Record %s...",filename) for t in 1:size(img,3)
                	img2 = img1[:,:,t]
	
        	        for i in 1:x
                	        for j in 1:y
                        	        filtered[i,j,t] = filtered[i,j,t] - b_mean[i,j] + base
					if (filtered[i,j,t] >= 1) filtered[i,j,t] = 1 end
                        	end
         	       end
        	end
	end

	img_save(filtered,"/home/jchang/image/result/",@sprintf("%s-b.tif",filename))
end	
