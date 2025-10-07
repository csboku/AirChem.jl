function log_message(msg)
    println("[$(now())] $msg")
    flush(stdout)
end

function process_file(fname::String,outdir::String,outpattern::String,var3d::Vector{String},var2d::Vector{String})
    try
        log_message("Processing: $fname")
        ds = Dataset(fname)
        wrf_lat = ds["XLAT"][1,:,1]
        wrf_lon = ds["XLONG"][:,1,1]
        wrf_time = ds["XTIME"][:]
        wrf_attribs = copy(ds.attrib)
        log_message("CREATE DATA")

        output_filename = last(split(fname,"/"))

        log_message("Create new dataset $output_filename")
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

        #Define Variables in a Loop as it is not thread save
        for var in var3d
            if !haskey(ds,var)
                @warn "Variable $var not found in dataset, skipping"
                continue
            end
            defVar(wrf_ds_out,var,Float32,("lon","lat","time"),attrib = ds[var].attrib)
        end

        for var in var2d
            if !haskey(ds,var)
                @warn "Variable $var not found in dataset, skipping"
                continue
            end
            defVar(wrf_ds_out,var,Float32,("lon","lat","time"),attrib = ds[var].attrib)
        end

        Threads.@threads for var in var3d
            if !haskey(ds,var)
                @warn "Variable $var not found in dataset, skipping"
                continue
            end
            log_message(var)
            wrf_ds_out[var][:,:,:] = ds[var][:,:,1,:]
        end

        Threads.@threads for var in var2d
            if !haskey(ds,var)
                @warn "Variable $var not found in dataset, skipping"
                continue
            end
            log_message(var)
            wrf_ds_out[var][:,:,:] = ds[var][:,:,:]
        end
    catch e
        log_message("ERROR processing $fname: $e")
        rethrow(e)
    finally
        close(ds)
        close(wrf_ds_out)
    end
end




export log_message,process_file
