using NCDatasets,Dates,CFTime


function process_file(fname::String,outdir::String,outpattern::String,var3d::Vector{String},var2d::Vector{String})
    # println("READ DATA")
    # println(fname)
    println("Read in data")
    ds = Dataset(fname)
    wrf_lat = ds["XLAT"][1,:,1]
    wrf_lon = ds["XLONG"][:,1,1]
    wrf_time = ds["XTIME"][:]
    wrf_attribs = copy(ds.attrib)
    println("CREATE DATA")

    output_filename = last(split(fname,"/"))

    println(output_filename)
    println("Create new dataset")
    wrf_ds_out = NCDataset(outdir*outpattern*output_filename,"c",attrib = wrf_attribs)
    defDim(wrf_ds_out,"lat",length(wrf_lat))
    defDim(wrf_ds_out,"lon",length(wrf_lon))
    defDim(wrf_ds_out,"time",length(wrf_time))
    defVar(wrf_ds_out,"lat",Float32,("lat",))
    defVar(wrf_ds_out,"lon",Float32,("lon",))
    defVar(wrf_ds_out,"time",Int64,("time",),attrib = ds[:XTIME].attrib)
    wrf_ds_out["lat"][:] = wrf_lat
    wrf_ds_out["lon"][:] = wrf_lon
    wrf_ds_out["time"][:] = wrf_time

    for var in var3d
        println(var)
        defVar(wrf_ds_out,var,Float32,("lon","lat","time"),attrib = ds[var].attrib)
        wrf_ds_out[var][:,:,:] = ds[var][:,:,1,:]
    end

    for var in var2d
        println(var)
        defVar(wrf_ds_out,var,Float32,("lon","lat","time"),attrib = ds[var].attrib)
        wrf_ds_out[var][:,:,:] = ds[var][:,:,:]
    end

    close(ds)
    close(wrf_ds_out)
end

export process_file

