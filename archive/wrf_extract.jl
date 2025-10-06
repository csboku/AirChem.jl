using NCDatasets,YAML,Proj,Dates,CFTime

println("Load config")
wrf_config = YAML.load_file("config.yaml")

input_dir = wrf_config["input"]["folder"]
input_files = readdir(input_dir,join=true)
input_f = readdir(input_dir)

output_dir = wrf_config["output"]["folder"]
output_pattern = wrf_config["output"]["pattern"]


wrf_vars_3d = wrf_config["variables_3d"]
wrf_vars_2d = wrf_config["variables_2d"]


println("Check data loading speed")
# @time ncin[:o3][:,:,1,:]

function process_file(fname)
    ds = Dataset(fname)
    wrf_lat = ds["XLAT"][1,:,1]
    wrf_lon = ds["XLONG"][:,1,1]
    wrf_time = ds["XTIME"][:]
    wrf_attribs = copy(ds.attrib)

    wrf_ds_out = NCDataset(output_dir*output_pattern*fname,"c",attrib = wrf_attribs)
    # dt_format = Dates.format(wrf_time[1], "yyyy-mm-dd HH:MM:SS")
    defDim(wrf_ds_out,"lat",length(wrf_lat))
    defDim(wrf_ds_out,"lon",length(wrf_lon))
    defDim(wrf_ds_out,"time",length(wrf_time))
    defVar(wrf_ds_out,"lat",Float32,("lat",))
    defVar(wrf_ds_out,"lon",Float32,("lon",))
    defVar(wrf_ds_out,"time",Int64,("time",),attrib = ds[:XTIME].attrib)
    wrf_ds_out["lat"][:] = wrf_lat
    wrf_ds_out["lon"][:] = wrf_lon
    wrf_ds_out["time"][:] = wrf_time

    for var in wrf_vars_3d
        println(var)
        defVar(wrf_ds_out,var,Float32,("lon","lat","time"),attrib = ds[var].attrib)
        wrf_ds_out[var][:,:,:] = ds[var][:,:,1,:]
    end

    for var in wrf_vars_3d
        println(var)
        defVar(wrf_ds_out,var,Float32,("lon","lat","time"),attrib = ds[var].attrib)
        wrf_ds_out[var][:,:,:] = ds[var][:,:,:]
    end


    close(wrf_ds_out)
end














# ds = Dataset(input_files[1])
# wrf_lat = ds["XLAT"][1,:,1]
# wrf_lon = ds["XLONG"][:,1,1]
# wrf_time = ds["XTIME"][:]
# wrf_attribs = copy(ds.attrib)
#
# # ds[:XTIME].attrib
#
#
# # rm(output_dir*output_fname,force=true)
#
#
# wrf_ds_out = NCDataset(output_dir*output_pattern*input_f[1],"c",attrib = wrf_attribs)
# dt_format = Dates.format(wrf_time[1], "yyyy-mm-dd HH:MM:SS")
# defDim(wrf_ds_out,"lat",length(wrf_lat))
# defDim(wrf_ds_out,"lon",length(wrf_lon))
# defDim(wrf_ds_out,"time",length(wrf_time))
# defVar(wrf_ds_out,"lat",Float32,("lat",))
# defVar(wrf_ds_out,"lon",Float32,("lon",))
# defVar(wrf_ds_out,"time",Int64,("time",),attrib = ds[:XTIME].attrib)
# wrf_ds_out["lat"][:] = wrf_lat
# wrf_ds_out["lon"][:] = wrf_lon
# wrf_ds_out["time"][:] = wrf_time
#
# for var in wrf_vars_3d
#     println(var)
#     defVar(wrf_ds_out,var,Float32,("lon","lat","time"),attrib = ds[var].attrib)
#     wrf_ds_out[var][:,:,:] = ds[var][:,:,1,:]
# end
#
# for var in wrf_vars_3d
#     println(var)
#     defVar(wrf_ds_out,var,Float32,("lon","lat","time"),attrib = ds[var].attrib)
#     wrf_ds_out[var][:,:,:] = ds[var][:,:,:]
# end
#
#
# close(wrf_ds_out)



