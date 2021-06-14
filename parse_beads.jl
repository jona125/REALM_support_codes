using Statistics, Plots, StaticArrays, ProgressMeter
using Printf, FileIO
plotlyjs()

print("Disk: ")
disk=chomp(readline())

print("Date: ")
date=chomp(readline())
#date="20190315"

cd(@sprintf("/mnt/%s/jchang/%s/",disk,date))
files=readdir()
filelist=filter(x->occursin(".txt",x),files)
@show filelist

print("Filename: ")
filename = chomp(readline())

cd(@sprintf("/mnt/%s/jchang/%s/%s",disk,date,filename[1:end-10]))
files = readdir()
numb = zeros(size(files,1))
for i in 1:size(files,1)
	numb[i] = parse(Float64,files[i][length(filename)-8:end-4])
end
cd(@sprintf("/mnt/%s/jchang/%s/",disk,date))

dataF = []
beads = []
open(@sprintf("%s.txt", filename), "r") do io
	t = 1;
	for line in eachline(io)
		data = split(line[1:end-1], " ")
		if occursin(".tif",line)
			t = parse(Float64,data[4])
			continue
		end
		push!(dataF,(parse(Float64,data[6]),parse(Float64,data[8]),parse(Float64,data[11]), parse(Float64,data[13]), t, parse(Float64,data[16]), parse(Float64,data[18]),parse(Float64,data[3])))
	end
	push!(beads,dataF[1])
	for idx in 2:size(dataF,1)
		#if(dataF[idx][1] <= 1.5 || dataF[idx][2] <= 1.5)
		#	continue
		#end
		i = size(beads,1)
		while i > 0
			if(beads[i][5] == (dataF[idx][5]-1))
				if(abs(beads[i][3] - dataF[idx][3]) <= 20 && abs(beads[i][4] - dataF[idx][4]) <= 20)
					if(dataF[idx][6] < beads[i][6])
						if(size(findall(x -> x == dataF[idx][8],numb),1) == 1)
							beads[i] = dataF[idx]
						end
						break
					end
				end
			end
			if(beads[i][5] < (dataF[idx][5]-1))
				if(size(findall(x -> x == dataF[idx][8],numb),1) == 1)
					push!(beads,dataF[idx])
				end
				break
			end
			i -= 1
		end
		if(size(beads,1) > 1 && (beads[1][1] <= 2 || beads[1][2] <= 2))
			popfirst!(beads)
		end
	end
end

beads_x = []
beads_y = []
for i in 1:size(beads,1)
	push!(beads_x,beads[i][1])
	push!(beads_y,beads[i][2])
end 
@show(mean(beads_x),mean(beads_y))
cd("/home/jchang/image/")
