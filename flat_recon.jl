using Images,StaticArrays, FileIO, Printf, ProgressMeter, Statistics
include("img_save.jl")


function flat_recon(img,filename,step=9,Save=True)
	img_cut = img

	(x,y,z) = size(img_cut)

	img_re = zeros(z*step,y,Int(floor(x/step)))
	
	@showprogress "Image Reconstruction for Record %s..." for i in 1:z
		for j in 1:Int(floor(x/step))
			#for h in 0:step-1
				img_re[1+(i-1)*step:i*step,:,j] = img_cut[(j-1)*step+1:j*step,:,i]
		end
	end

	#img_scale = zeros(Int(floor(z*step/1.5)),y,Int(floor(x/step)))
	#(x,y,z) = size(img_scale)

	#@showprogress "Image scaling for Record %s..." for i in 0:Int(floor(x/2)-1)
	#	for j in 1:y
	#		for k in 1:z
	#			img_scale[i*2+1,j,k] = img_re[i*3+1,j,k] + img_re[i*3+2,j,k]
	#			img_scale[i*2+2,j,k] = img_re[i*3+2,j,k] + img_re[i*3+3,j,k]
	#		end
	#	end
	#end

	if Save
		img_save(img_re,"/home/jchang/image/result/",(@sprintf("%s-.tif", filename)))
	end
	return img_re
end
