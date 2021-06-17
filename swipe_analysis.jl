import ImageMagick
using Images, ImageView, ImageTransformations, StaticArrays, LinearAlgebra, FFTW
using FileIO, Printf, Makie,Statistics,DSP

function overtime(img)
	img_result = zeros(size(img[:,:,1]))

	for i in 1:length(img[:,1,1])
		for j in 1:length(img[1,:,1])
			img_result[i,j] = sum(img[i,j,:])
		end
	end
	return img_result
end

function speed_cal(angle, line)
	band_speed = zeros(150,2)
	current_point = 1
	band_num = 1
	for i in 2:length(line)-1
		if ((line[i-1] >= 0.02) && (line[i] <= 0.02))||((line[i-1] <= 0.02) && (line[i] >= 0.02))
			dis = i - current_point
			band_speed[band_num,2] = 34*band_num
			band_speed[band_num,1] = (i-100)/100*angle 
			current_point = i 
			band_num += 1
		end
	end
	return band_speed
end

function smoothing(img,freq)
	designmethod = Butterworth(5)
	ff = digitalfilter(Lowpass(freq),designmethod)
	result = filtfilt(ff, img)
	return result
end

function fwhm(data)
	max_d = maximum(data) - data[end]
	mid_d = argmax(data)[1]
	half_value = max_d / 2 + data[end]
	sigma = zeros(1,2)
	for i in 1:mid_d-1
		if data[mid_d-i] <= half_value && data[mid_d-i+1] >= half_value
			sigma[1] = mid_d - i
			break
		end
	end
	for i in mid_d:length(data)-1
		if data[i] <= half_value && data[i+1] >= half_value
			sigma[2] = i
			break
		end
	end
	return (sigma[2] - sigma[1])
end

function clearzero(data)
	for i in 1:length(data[:,1])
		if data[end-i+1,2] != 0.0
			return data[1:end-i+1,:]
			break
		end
	end
end


print("Date: ")
date=chomp(readline())
#date="20190315"

cd(@sprintf("/mnt/jchang_005/jchang/%s/",date))
files=readdir()
filelist=filter(x->occursin(".imagine",x),files)
@show filelist

print("Filename: ")
files=readdir()
filename = chomp(readline())

@printf("angle: ")
A = chomp(readline())
A = parse(Int,A)


scene1 = Scene()
scene2 = Scene()
exp = load(@sprintf("%s_1.tif", filename))
#img1 = exp[:,:,t]
#img2 = convert(Array{N0f16}, img1)
img3 = overtime(exp)
idx = argmax(img3)
#scene1 = Makie.plot(smoothing(img2[idx,:],0.05))
line_c = exp[idx[1],idx[2],:]
line_s = smoothing(line_c,0.9)
band_speed = speed_cal(A,line_c)
band_pos = clearzero(band_speed)

scene = Makie.lines(band_pos)

time_pos = zeros(length(band_pos[:,1]),2)
for i in 1:length(band_pos[:,1])
        img3 = exp[:,:,Int(floor((band_pos[i,1]+A)*100/A))]
        img4 = convert(Array{N0f16}, img3)
        time_c = argmax(img4)[2]
        time_pos[i,2] = std(img4[:,time_c])
	time_pos[i,1] = band_pos[i,1]
end
#time_pos = smoothing(time_pos,0.3)
