using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation
#using Plots, ImageView

function imfilter(label,date)
	cd(@sprintf("/mnt/%s/jchang/%s/",label,date))
	files=readdir()
	filelist=filter(x->occursin(".tif",x),files)
	@show filelist
	
	print("Is there background file (No=0,Yes=1): ")
	no_BG = chomp(readline())
	no_BG = parse(Int,no_BG)
	
	if no_BG == 1
		print("Background Filename: ")
		BG_filename = chomp(readline())
	
	else
		BG_filename = filelist[1][1:end-4]
	end
	
	exp = load(@sprintf("%s.tif",BG_filename))
	img1 = convert(Array{N0f16}, exp)
	
	
	(x,y,z) = size(img1)
	b_mean = zeros(x,y)
	b_std = zeros(x,y)
	
	if no_BG == 1
		@showprogress "Preprocssing background file..." for i in 1:x
		for j in 1:y
			b_mean[i,j] = mean(img1[i,j,:])
			b_std[i,j] = std(img1[i,j,:])
			end
		end
	end
	
	#scene = Scene()
	#open(@sprintf("%s.txt",date),"w") do f
	for k in 1:size(filelist,1)
		filename=filelist[k][1:end-4]
		exp = load(@sprintf("%s.tif", filename))
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
		img3 = Gray.(convert(Array{N0f16},filtered))
		img4 = Gray.(convert.(Normed{UInt16,16},img3))
		cd("/home/jchang/image/result/")
		FileIO.save(File{format"TIFF"}(@sprintf("%s-bi.tif",filename)), img4)
	        cd(@sprintf("/mnt/%s/jchang/%s/",label,date))
	end
	#end
	
	
	cd("/home/jchang/image/")
end	


