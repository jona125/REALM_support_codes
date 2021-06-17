using Images, StaticArrays, LinearAlgebra, Statistics
using FileIO, ProgressMeter, Printf, ImageSegmentation
#using Plots, ImageView

include("psf_fun.jl")

function psf_analyze(disk,date)
	cd("/home/jchang/image/result/")
	files=readdir()
	filelist=filter(x->occursin("-bi.tif",x),files)
	filelist=filter(x->occursin("um",x),filelist)
	filelist=filter(x->occursin(@sprintf("%s",date),x),filelist)
	@show filelist
	
	#scene = Scene()
	for k in 1:size(filelist,1)
		filename=filelist[k][1:end-7]
		exp = load(@sprintf("%s-bi.tif", filename))
		img1 = convert(Array{N0f16}, exp)
		img1[img1.<0.05*maximum(img1)] .= 0
		(x,y,z) = size(exp)
		filtered = zeros(x,y,z)
	
		threshold = minimum(img1[img1.>0])
		@show(threshold)
		fwhm_x_list = []
		fwhm_y_list = []
		result = []
		open(@sprintf("%s-beads_psf.txt",filename[10:end]),"w") do g
		count = 0
		@showprogress @sprintf("Range calculation of Record %s...",filename) for t in 1:size(exp,3)
			img2 = img1[:,:,t]
			beads_x = []
			beads_y = []

			seg = fast_scanning(img2, threshold)
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
					end
	
					beads = img2[minimum(x_list):maximum(x_list),minimum(y_list):maximum(y_list)]
					if (!isempty(beads) && minimum(x_list) > 10 && minimum(y_list) > 10 && maximum(x_list) < x-10 && maximum(y_list) < y-10)
						if(size(beads,1) >= 3 && size(beads,2) >= 3)
							(y_fwhm,x_fwhm, x_skew, y_skew) = psf_cal(beads,0)
						else
							(y_fwhm,x_fwhm) = size(beads)
						end
						push!(fwhm_x_list,x_fwhm)
						push!(fwhm_y_list,y_fwhm)
						for p in pxs
							push!(beads_x,p[1])
							push!(beads_y,p[2])
							I += (img2[p])
							filtered[p[1],p[2],t] = img2[p]
						end
	
						count += 1
						cd("/home/jchang/image/result/")
							write(g, @sprintf("Beads # %d FWHM, x: %.2f y: %.2f , pos( %d , %d ), Intensity %.10f ,total %d pixels\n", count, x_fwhm, y_fwhm, (minimum(x_list)+maximum(x_list))/2, (minimum(y_list)+maximum(y_list))/2, I, segment_pixel_count(seg,l)))
					end
				end
			end
				end
		end
		if(!isempty(fwhm_x_list) && !isempty(fwhm_y_list))
			@show(mean(fwhm_x_list),mean(fwhm_y_list))
		end

		if (isempty(result))
			push!(result,(1,size(img1,1),1,size(img1,2)))
		end	
		img3 = Gray.(convert(Array{N0f16},filtered))
		img4 = Gray.(convert.(Normed{UInt16,16},img3))
	
		FileIO.save(File{format"TIFF"}(@sprintf("%s-fbi.tif",filename)), img4)
	end
	
	cd("/home/jchang/image/")
end
