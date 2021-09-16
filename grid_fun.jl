using Images,Statistics,FileIO,Printf

include("COM.jl")
INITIAL_FLAG = 1 == 1


function fwhm(data,b_mean,b_std)
	half_value = b_mean + 2*b_std
	peak = findall(data.>half_value)       
	if(length(peak)<=5)
		return 0,0
	end
	return (peak[end][1] - peak[1][1]), findmid(data)
end

function grid_resolution(data)
	# Input (mean cross section , mean background)
	# Output (mean band tickness, mean space tickness)
	diff_l = abs.(data[4:end] - data[1:end-3])
	b_mean = mean(diff_l)
	b_std = std(diff_l)
	peak = findall(diff_l.>b_mean+b_std)
	diff_ = diff(peak)
	end_pos = peak[findall(diff_.>13)]
	start_pos = peak[findall(diff_.>13).+1]
	stript = 0
	for i in 1:length(start_pos)-1
		stript += end_pos[i+1] - start_pos[i] - 2
	end
	#counts = count(i->(i>3),diff_)
	return 	stript/(length(start_pos)-1),  mean(diff(start_pos))
end

function grid_slice(img)
	img = convert(Array{N0f16}, img)
	b_mean = mean(img)
	flag = Bool.(INITIAL_FLAG)
	width_temp = []
	pos_temp = []
	stript_temp = []
	space_temp = []
	frame = 1
	# loop through every frame
	for i in 5:size(img,3)
		img1 = img[:,:,i]
		line = mean(img1,dims=2)
		b_std = std(line)
		# skip frames without signal
		if(b_std > b_mean/1.5) 
			if(flag == INITIAL_FLAG)
				flag = !flag
				frame = i
			end
			continue 
		end
		# take moving average in line signal
		new_line = zeros(size(line,1),1)
		for i in 5:size(line,1)
			new_line[i] = mean(line[i-4:i])
		end
		# calculate image signal range
		(width , mid) = fwhm(new_line,b_mean,b_std)
		# analysis resolution
	#	img_l = mean(img1,dims=1)[1,:,1]
	#	if width != 0
	#		stript_width, space_width = grid_resolution(img_l)
	#	else
	#		stript_width, space_width = (0,0)
	#	end
		width != 0 ? push!(width_temp,width) : 1
		mid != 0 ? push!(pos_temp,mid) : 1
	#	width == 0 ? frame = i : 1
	#	stript_width !=0 ? push!(stript_temp , stript_width) : 1
	#	space_width !=0 ? push!(space_temp, space_width) : 1
	end
	img_l = mean(mean(img,dims=3),dims=1)[1,:,1]
	stript_width , space_width = grid_resolution(img_l)
	if isempty(width_temp)
		width_temp = 0
	end
	if isempty(pos_temp)
		pos_temp = 0
	end
	return width_temp,pos_temp, frame, stript_width, space_width
end

