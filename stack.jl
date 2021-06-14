using Images,PlotlyJS, Printf, ProgressMeter, FileIO

print("Date: ")
date=chomp(readline())
#date="20190315"
@show date

cd("/home/jchang/image/result/")
files=readdir()
filelist=filter(x->occursin("bi.tif",x),files)
filelist=filter(x->occursin(@sprintf("%s",date),x),filelist)
@show filelist

print("Filename: ")
filename = chomp(readline())
@show filename

img = load(@sprintf("%s.tif", filename))
img = convert(Array{N0f16}, img)

maxi = maximum(img)
img = img./maxi
img[img.<0.01] .= 0

(x,y,z) = size(img)
img_s = zeros(x+Int(floor(z*tan(80/180*π))),y,z+18)
@showprogress @sprintf("Stacking %s...",filename) for i in 1:z
        for j in 1:x
                for k in 0:Int(floor(12/0.65))
                        img_s[j+Int(floor(i*tan(80/180*π))),:,i+k] += img[j,:,i]
                end
        end
end

img_mask = zeros(x+Int(floor(z*tan(80/180*π))),y,z+18)
img_final = zeros(x+Int(floor(z*tan(80/180*π))),y,z+18)
#form mask image
@showprogress @sprintf("Mask out signal %s...",filename) for i in 1:x
        for j in 1:y
                for k in 1:z
                        for h in 0:Int(floor(12/0.65))
                                img_mask[i+Int(floor(k*tan(80/180*π))),j,k+h] += (img[i,j,k]>0 ? 1 : 0)
                                if(img_mask[i+Int(floor(k*tan(80/180*π))),j,k+h] >= 4)
                                        img_final[i+Int(floor(k*tan(80/180*π))),j,k+h] = img_s[i+Int(floor(k*tan(80/180*π))),j,k+h]/img_mask[i+Int(floor(k*tan(80/180*π))),j,k+h]
                                end
                        end
                end
        end
end

(x,y,z) = size(img_final)
img_re = zeros(x,z,y)

@showprogress @sprintf("Getting YZ-Cross section %s...",filename) for i in 1:y
	img_re[:,:,i] = img_final[:,i,:]
end
#img_re = img_re ./ maximum(img_re)
FileIO.save(File{format"TIFF"}(@sprintf("%s-z.tif", filename)), img_re)

img_re = zeros(z,y,x)

@showprogress @sprintf("Getting XZ-Cross section %s...",filename) for i in 1:x
	img_re[:,:,i] = img_final[i,:,:]'
end
#img_re = img_re ./ maximum(img_yre)
FileIO.save(File{format"TIFF"}(@sprintf("%s-zy.tif", filename)), img_re)

cd("/home/jchang/image/")
