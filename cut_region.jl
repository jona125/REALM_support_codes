using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation

function cut_region(date)
	cd("/home/jchang/image/result/")
	files=readdir()
	filelist=filter(x->occursin("-bi.tif",x),files)
	filelist=filter(x->occursin(@sprintf("%s",date),x),filelist)
	@show filelist
	
	(x,y,z) = size(load(@sprintf("%s-bi.tif",filelist[1][1:end-7])))
	
	
	print(@sprintf("range x: %d,y: %d\n",x,y))
	
	print("x_start: ")
	x_start = chomp(readline())
	x_start = parse(Int,x_start)
	
	print("x_end: ")
	x_end = chomp(readline())
	x_end = parse(Int,x_end)
	
	print("y_start: ")
	y_start = chomp(readline())
	y_start = parse(Int,y_start)
	
	print("y_end: ")
	y_end = chomp(readline())
	y_end = parse(Int,y_end)
	
	
	#print("Filename: ")
	#filename = chomp(readline())
	
	#@printf("time: ")
	#t = chomp(readline())
	#t = parse(Int,t)
	
	#scene = Scene()
	@showprogress @sprintf("Crope image ...") for k in 1:size(filelist,1)
		filename=filelist[k][1:end-7]
		exp = load(@sprintf("%s-bi.tif", filename))
		img = exp[x_start:x_end,y_start:y_end,:]
		
		FileIO.save(File{format"TIFF"}(@sprintf("%s-cbi.tif",filename)), img)
	end
	
	cd("/home/jchang/image/")
end	
