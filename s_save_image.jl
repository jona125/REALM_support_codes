using Images, FileIO, ImageTransformations, ProgressMeter, Printf

function transfertotif(label,date)
	cd(@sprintf("/mnt/%s/jchang/%s/",label,date))
	files=readdir()
	filelist=filter(x->occursin(".imagine",x),files)
	@show filelist
	
	print("add scale bar(Y as 1, N as 0): ")
	r=chomp(readline())
	r=parse(Int,r)
	
	if r == 1
		print("The length of scale bar(in px): ")
		l = chomp(readline())
		l = parse(Int,l)
	end
	
	@printf("time margin from center: ")
	t1 = chomp(readline())
	t1 = parse(Int,t1)
	
	
	@showprogress for k in 1:size(filelist, 1)
		filename=filelist[k][1:end-8]
		exp = load(@sprintf("%s.imagine", filename))
		for f in 1:size(exp,4)
		img1=exp[:,:,Int(floor(size(exp,3)/2)-t1):Int(floor(size(exp,3)/2)+t1),f]
		if r == 1
			x,y,z = size(img1)
			for i in x-l*3-5:x-l*3
				for j in y-l*4:y-l*3
					for h in 1:z
						img1[i,j,h] = 0.05N0f16
					end
				end
			end
		end
		img3=convert(Array{N0f16}, img1)
		img3=colorview(Gray,img3)
		FileIO.save(File{format"TIFF"}(@sprintf("%s_%d.tif", filename,f)), img3)
		end
	end
	cd("/home/jchang/image")
end

