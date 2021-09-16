using Images,Statistics,FileIO, Printf

function img_save(img,path,filename)
	cur_path = pwd()
	img1 = Gray.(convert(Array{N0f16},img))
	img1 = Gray.(convert.(Normed{UInt16,16},img1))
	cd(path)
	FileIO.save(File{format"TIFF"}(filename), img1)
	cd(cur_path)
end
