using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation
#using Plots, ImageView

include("psf_fun.jl")


print("Date: ")
date=chomp(readline())
#date="20190315"
@show date

cd(@sprintf("/home/jchang/image/%s/",date))
files=readdir()
filelist=filter(x->occursin(".tif",x),files)
@show filelist

#print("Filename: ")
#filename = chomp(readline())

#@printf("time: ")
#t = chomp(readline())
#t = parse(Int,t)

#scene = Scene()
open(@sprintf("%s.txt",date),"w") do f
for k in 1:size(filelist,1)
	filename=filelist[k][1:end-4]
	exp = load(@sprintf("%s.tif", filename))
	img1 = exp[:,:,1]
	img2 = convert(Array{N0f16}, img1)
	background = img2[1:10,1:10]
	b_mean = mean(background)
	b_std = std(background)
	result = []
	#filtered = exp
	open(@sprintf("%s-beads_psf.txt",filename[10:end]),"w") do g
	count = 0
	@showprogress @sprintf("Range calculation of Record %s...",filename) for t in 1:size(exp,3)
		img1 = exp[:,:,t]
		img2 = convert(Array{N0f16}, img1)
		beads_x = []
		beads_y = []
		# old spot filter method
		#spots = findall(f -> f > (b_mean + 2 * b_std), img2)
		#for s in 1:size(spots,1)
		#	x = spots[s][1]
		#	y = spots[s][2]
		#	adjacent = img2[(x-2>0 ? x-2 : 1):(x+2<size(img2,1) ? x+2 : size(img2,1)),(y-2>0 ? y-2 : 1):(y+2<size(img2,2) ? y+2 : size(img2,2))]
		#	adjacent = adjacent.>(b_mean + 2 * b_std)
		#	if (mean(adjacent) > 0.2)
		#		if (x>10 && size(img2,1)-x>10 && y>10 && size(img2,2)-y>10)
		#			push!(beads_x,x)
		#			push!(beads_y,y)
		#			#filtered[x-2:x+2,y-2:y+2,t] .= 1
		#		else
		#			filtered[x,y,t] = b_mean
		#		end
		#	else
		#		filtered[x,y,t] = b_mean
		#	end
		#end
		seg = fast_scanning(img2, b_std)
		seg = prune_segments(seg,i->(segment_pixel_count(seg,i)<5), (i,j)->(-segment_pixel_count(seg,j)))
		label = segment_labels(seg)
		if size(label,1) > 1
			write(g, @sprintf("%s.tif in frame %d:\n", filename, t))
		end
		for l in label
			if segment_pixel_count(seg,l) <= 2000
				pxs = findall(f -> f == l , labels_map(seg))
				x_list = []
				y_list = []
				I = 0
				for p in pxs
					push!(x_list,p[1])
					push!(y_list,p[2])
					push!(beads_x,p[1])
					push!(beads_y,p[2])
					I += (img2[p] - b_mean)
				end

				beads = img2[minimum(x_list):maximum(x_list),minimum(y_list):maximum(y_list)]
				if (!isempty(beads) && size(beads,1) > 3 && size(beads,2) > 3)
					(y_fwhm,x_fwhm, x_skew, y_skew) = psf_cal(beads,b_mean)
					#if(abs(x_skew) < 0.6 && abs(y_skew) < 0.6)
						count += 1
						left = minimum(x_list)-5 > 1 ? minimum(x_list)-5 : 1
						right = maximum(x_list)+5 < size(img2,1) ? maximum(x_list)+5 : size(img2,1)
						upper = minimum(y_list)-5 > 1 ? minimum(y_list)-5 : 1
						lower = maximum(y_list)+5 < size(img2,2) ? maximum(y_list)+5 : size(img2,2)
						beads = img2[left:right,upper:lower]
						cd(@sprintf("/home/jchang/image/%s/%s/",date,filename[10:end]))
						FileIO.save(File{format"TIFF"}(@sprintf("%s_%d.tif",filename[10:end],count)), Gray.(convert.(Normed{UInt16,16},beads)))
						cd(@sprintf("/home/jchang/image/%s/",date))
						write(g, @sprintf("Beads # %d FWHM, x: %.2f y: %.2f , pos( %d , %d ), Intensity %.10f ,total %d pixels\n", count, x_fwhm, y_fwhm, (minimum(x_list)+maximum(x_list))/2, (minimum(y_list)+maximum(y_list))/2, I, segment_pixel_count(seg,l)))
					#end
				end
			end
		end
		beads_x = Int.(beads_x)
		beads_y = Int.(beads_y)
		if (!isempty(beads_x))
			x1 = minimum(beads_x)
			x2 = maximum(beads_x)
			y1 = minimum(beads_y)
			y2 = maximum(beads_y)
			push!(result, (x1,x2,y1,y2))
		end
	end
	end
	if (isempty(result))
		push!(result,(1,size(img2,1),1,size(img2,2)))
	end
	x_start = zeros(1,size(result,1))
	x_end = zeros(1,size(result,1))
	y_start = zeros(1,size(result,1))
	y_end = zeros(1,size(result,1))
	for idx in 1:size(result,1)
		x_start[idx] = result[idx][1]
		x_end[idx] = result[idx][2]
		y_start[idx] = result[idx][3]
		y_end[idx] = result[idx][4]
	end
	@show (minimum(x_start),maximum(x_end),minimum(y_start),maximum(y_end))
	write(f, @sprintf("%s.tif image (%d,%d) in x, (%d,%d) in y. Range %d X %d\n", filename, minimum(x_start), maximum(x_end), minimum(y_start), maximum(y_end), maximum(x_end)-minimum(x_start), maximum(y_end)-minimum(y_start)))
	img_re = exp[Int(minimum(x_start)):Int(maximum(x_end)),Int(minimum(y_start)):Int(maximum(y_end)),:]
	cd("/home/jchang/image/result/")
        FileIO.save(File{format"TIFF"}(@sprintf("m-%s.tif", filename)), img_re)
        cd(@sprintf("/home/jchang/image/%s/", date))
end
end


cd("/home/jchang/image/")

