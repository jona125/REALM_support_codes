using Images,StaticArrays, FileIO, Printf, ProgressMeter, Statistics

function flat_recon(date)
	
	cd("/home/jchang/image/result/")
	
	print("Pixel per frame: ")
	step=chomp(readline())
	step=parse(Int,step)
	
	
	files=readdir()
	filelist=filter(x->occursin("-cbi.tif",x),files)
	filelist=filter(x->occursin(@sprintf("%s",date),x),filelist)
	@show filelist
	
	for k in 1:size(filelist, 1)
		filename=filelist[k][1:end-4]
	
		img = load(@sprintf("%s.tif", filename))
		img = convert(Array{N0f16}, img)
	
		#img_cut = img[400:2000,370:1120,:]
		img_cut = img
	
		(x,y,z) = size(img_cut)
	
		img_re = zeros(z*step,y,Int(floor(x/step)))
		
		@showprogress @sprintf("Image Reconstruction for Record %s...",filename) for i in 1:z
			for j in 1:Int(floor(x/step))
				#for h in 0:step-1
					img_re[1+(i-1)*step:i*step,:,j] = img_cut[(j-1)*step+1:j*step,:,i]
					#for k in 1:y
					#	img_re[1+(i-2)*step+h,k,j] = mean(img_cut[(j-1)*step*3+h+1:(j-1)*step*3+h+3,k,i])
					#end
			end
		end
	
		#img_scale = zeros(Int(floor(z*step/1.5)),y,Int(floor(x/step)))
		#(x,y,z) = size(img_scale)
	
		#@showprogress @sprintf("Image scaling for Record %s...",filename) for i in 0:Int(floor(x/2)-1)
		#	for j in 1:y
		#		for k in 1:z
		#			img_scale[i*2+1,j,k] = img_re[i*3+1,j,k] + img_re[i*3+2,j,k]
		#			img_scale[i*2+2,j,k] = img_re[i*3+2,j,k] + img_re[i*3+3,j,k]
		#		end
		#	end
		#end
	
	
		img_scale = Gray.(convert.(Normed{UInt16,16},img_re))
		FileIO.save(File{format"TIFF"}(@sprintf("%s.tif", filename[1:end-3])), img_scale)
	end
	cd("/home/jchang/image/")
end
