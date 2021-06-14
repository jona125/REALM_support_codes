using Images, StaticArrays, FileIO, ProgressMeter, Printf, Statistics

files=readdir()
filelist=filter(x->occursin("-t.tif",x),files)
@show filelist

print("Filename: ")
file=chomp(readline())
#file = "20210302_10_M35_3-65-t.tif"
file=filter(x->occursin(@sprintf("%s",file),x),filelist)
@show file

filename=file[1][1:end-4]

img = load(@sprintf("%s.tif", filename))
img = convert(Array{N0f16}, img)
img_l = mean(img,dims = 2)

@show (x,y,z) = size(img)

function img_dist(img1,img2,shift)
	x1 = size(img1)
	x2 = size(img2)
	dist = 0
	for i in (shift+1):x1[1]
		dist += (img1[i] - img2[i-shift]) ^ 2
	end
	return sqrt(dist)
end

img_1 = img_l[:,1,3]
img_re = zeros(x,y,z)
@showprogress "Aligning each frame....." for s in 1:z
	min_dist = 1000000
	shift = 0
	if s != 3
		for i in 0:6
			temp_dist =  img_dist(img_1,img_l[:,1,s],i*9)
			if min_dist > temp_dist
				min_dist = temp_dist
				shift = i
			end
		end
	end
	img_re[shift*9+1:end,:,s] = img[1:end-shift*9,:,s]
end

img_re = Gray.(convert.(Normed{UInt16,16},img_re))
FileIO.save(File{format"TIFF"}(@sprintf("%s-align.tif", filename)), img_re)
