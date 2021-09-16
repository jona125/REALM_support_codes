using Images, StaticArrays, Statistics, StatsBase
THRESHOLD = 1.2


function fwhm_axis(img, axis, b_mean)
	x, y = size(img)
	if axis == 1
		axis_1 = x
		axis_2 = y
	else
		axis_1 = y
		axis_2 = x
	end
	y_fwhm = []
	y_start = 1
	y_end = axis_2

	for idx in 1:axis_1
		if axis == 1
			temp = img[idx,:]
		else
			temp = img[:,idx]
		end
		if isempty(temp)
			continue
		end
		maxi = maximum(temp)
		half = (maxi + b_mean)/2
		mid = argmax(temp)
		if half <= b_mean*THRESHOLD # take away lines of background
			continue
		end
		for idy in 1:mid-1
			if temp[idy] < half && temp[idy+1] >= half
				y_start = mid-idy
				break
			end 
		end
		for idy in 1:axis_2-mid
			if temp[axis_2-idy] < half && temp[axis_2-idy+1] >= half
				y_end = idy
				break
			end
		end
		temp_fwhm = abs(y_end - y_start)
		append!(y_fwhm, temp_fwhm)
	end
	skew = 0
	if isempty(y_fwhm)
		append!(y_fwhm, 1)
	end
	return (maximum(Float64.(y_fwhm)),skew)
end


function psf_cal(img, b_mean)
	#background = append!(img[1,:],img[end,:])
	#append!(background,img[:,1])
	#append!(background,img[:,end])
	#b_mean = mean(background)

 
	(y_fwhm, y_skew) = fwhm_axis(img,1,b_mean)
	(x_fwhm, x_skew) = fwhm_axis(img,2,b_mean)
	x_fwhm = Float64(x_fwhm)
	y_fwhm = Float64(y_fwhm)
	x_fwhm *=0.65
	y_fwhm *=0.65
	return (x_fwhm, y_fwhm, x_skew, y_skew)
end

