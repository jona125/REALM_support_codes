using Images, FileIO, ImageTransformations, ProgressMeter, Printf

WHITE_BG = 0.05N0f16

function transfertotif(img,filename,r = 0,l = 15)
	
	@showprogress @sprintf("Saving %s:",filename) for f in 1:size(img,4)
		img1 = img[:,:,:,f]
		if r == 1
			x,y,z = size(img1)
			for i in x-l*3-5:x-l*3
				for j in y-l*4:y-l*3
					for h in 1:z
						img1[i,j,h] = WHITE_BG
					end
				end
			end
		end
		img3=convert(Array{N0f16}, img1)
		img3=colorview(Gray,img3)
	FileIO.save(File{format"TIFF"}(@sprintf("%s_%d.tif", filename,f)), img3)
	end
end

