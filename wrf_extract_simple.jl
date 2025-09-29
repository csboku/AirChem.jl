using NCDatasets,YAML,Proj,Dates,CFTime

wrf_config = YAML.load_file("config.yaml")

data_dir = wrf_config["input"]["folder"]
data_files = readdir(data_dir,join=true)

output_dir = wrf_config["output"]["folder"]

wrf_vars_3d = wrf_config["variables_3d"]
wrf_vars_2d = wrf_config["variables_2d"]

ncin = Dataset(data_files[1]);
dt_string = join(ncin["Times"][:,1])


dt2cf(dt::DateTime, CFType::Type) = CFType(
    Dates.year(dt), Dates.month(dt), Dates.day(dt),
    Dates.hour(dt), Dates.minute(dt), Dates.second(dt)
)

#### Ectract coordinates and time

function wrf_get_coords(fpath_start,fpath_end)
    ds = Dataset(fpath_start)
    wrf_lat = ds["XLAT"][1,:,1]
    wrf_lon = ds["XLONG"][:,1,1]
    wrf_attribs = copy(ds.attrib)
    wrf_start_dt = DateTime(join(ds["Times"][:,1]),"y-m-d_H:M:S")
    close(ds)
    ds = Dataset(fpath_end)
    wrf_end_dt = DateTime(join(ds["Times"][:,end]),"y-m-d_H:M:S")
    close(ds)
    return wrf_lat,wrf_lon,wrf_start_dt,wrf_end_dt,wrf_attribs
end

lat,lon,start_date,end_date,wrf_ds_attribs = wrf_get_coords(data_files[1],data_files[end])

dt2cf(start_date,DateTimeNoLeap):Hour(1):dt2cf(end_date,DateTimeNoLeap) |> collect

function wrf_create_output_file(lat,lon,dt_start,dt_end,ds_name,attributes)
    rm(output_dir*ds_name,force=true)
    wrf_ds_out = NCDataset(output_dir*ds_name,"c",attrib = attributes)
    wrf_ds_time = collect(dt2cf(start_date,DateTimeNoLeap):Hour(1):dt2cf(end_date,DateTimeNoLeap))
    dt_format = Dates.format(start_date, "yyyy-mm-dd HH:MM:SS")
    defDim(wrf_ds_out,"lat",length(lat))
    defDim(wrf_ds_out,"lon",length(lon))
    defDim(wrf_ds_out,"time",length(wrf_ds_time))
    defVar(wrf_ds_out,"lat",Float32,("lat",))
    defVar(wrf_ds_out,"lon",Float32,("lon",))
    defVar(wrf_ds_out,"time",Int64,("time",),attrib = Dict("units" => "hours since $dt_format","calendar" => "noleap"))
    wrf_ds_out["lat"][:] = lat
    wrf_ds_out["lon"][:] = lon
    wrf_ds_out["time"][:] = NCDatasets.timeencode(wrf_ds_time, "hours since $dt_format","noleap")
    close(wrf_ds_out)
end

wrf_create_output_file(lat,lon,start_date,end_date,"attain_rcp45_nf.nc",wrf_ds_attribs)

ncout = NCDataset("/gpfs/data/fs71391/cschmidt/attain_processed/monika/attain_rcp45_nf.nc","a")



function wrf_ds_add_val(ncin)

end



ncin_dt = reinterpret.(DateTimeNoLeap,ncin["XTIME"][:])
ncin_dt = convert(Vector{DateTimeNoLeap},ncin_dt)

ncin_indconn  = indexin(ncin_dt, ncout["time"][:])


defVar(ncout,"o3",Float32,("lon","lat","time"))

@time ncin[:o3][:,:,1,:]


# ncout["o3"][:,:,ncin_indconn] = ncin["o3"][:,:,1,:]

