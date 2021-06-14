using Images,StaticArrays, FileIO, Printf, ProgressMeter, Statistics

cd("/home/jchang/image/result/")

print("Date: ")
date=chomp(readline())
#date="20190315"
@show date

files=readdir()
filelist=filter(x->occursin("_1--b.tif",x),files)
filelist=filter(x->occursin(@sprintf("%s",date),x),filelist)
@show filelist

print("Filename: ")
file=chomp(readline())
@show file
filelist=filter(x->occursin("--b.tif",x),files)
filelist=filter(x->occursin(@sprintf("%s",file),x),filelist)
@show filelist


print("Frame start: ")
z_start=chomp(readline())
z_start=parse(Int,z_start)

print("Frame end: ")
z_end=chomp(readline())
z_end=parse(Int,z_end)

print("Is bidirectional(Y:1,N:0): ")
bi=chomp(readline())
bi=parse(Int,bi)

filename=filelist[1][1:end-4]

img = load(@sprintf("%s.tif", filename))
img = convert(Array{N0f16}, img)

(x,y,z) = size(img)


@showprogress "Building time series file..." for s in z_start:z_end

	if bi == 1
		img_re = zeros(Int(floor(x/2)),y,size(filelist,1)*2)

		for k in 1:size(filelist, 1)
			filename=filelist[k][1:end-4]

			img = load(@sprintf("%s.tif", filename))
			img = convert(Array{N0f16}, img)
		
			img_re[:,:,k*2-1] = img[1:Int(floor(x/2)),:,s]
			img_re[end:-1:1,:,k*2] = img[end-Int(floor(x/2)):end-1,:,s]
		end

	else
		img_re = zeros(x,y,size(filelist,1))

		for k in 1:size(filelist, 1)
			filename=filelist[k][1:end-4]

			img = load(@sprintf("%s.tif", filename))
			img = convert(Array{N0f16}, img)
		
			img_re[:,:,k] = img[:,:,s]
		end
	end
	
	img_re = Gray.(convert.(Normed{UInt16,16},img_re))
	FileIO.save(File{format"TIFF"}(@sprintf("%s-%s-t.tif", file,s)), img_re)
end

cd("/home/jchang/image/")
