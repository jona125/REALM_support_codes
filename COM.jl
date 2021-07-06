using Images,Plots, Statistics,FileIO,Printf


function COM(img)
	x_pos = []
	y_pos = []
	for i in 1:size(img,3)
		tmp = img[:,:,i]
		x_data = mean(tmp,dims=2)
		push!(x_pos,findmid(x_data))
		y_data = mean(tmp,dims=1)
		push!(y_pos,findmid(y_data))
	end
	return x_pos, y_pos
end

function findmid(data)
	weighted_sum = 0
	int_sum = 0
	for i in 1:length(data)
		weighted_sum += data[i] * i
		int_sum += data[i]
	end
	return weighted_sum/int_sum
end


