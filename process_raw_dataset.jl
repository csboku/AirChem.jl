using NCDatasets,YAML,Proj,Dates

Threads.

wrf_config = YAML.load_file("config.yaml")
wrf_vars = wrf_config["variables"]


wrf_in = Dataset("/gpfs/data/fs71391/cschmidt/attain_raw_output/rcp45_2026t35/part_05/wrfout_d01_2028-01-01_00:00:00")


wrf_dt =  collect(DateTime(2007, 1, 1, 0):Hour(1):DateTime(2016, 12 , 31, 23))

wrf_lat = wrf_in["XLAT"][1,:,1]
wrf_lon = wrf_in["XLONG"][:,1,1]


# nan_matrix = fill(NaN,189,165,length(wrf_dt))

##### Create an ncfile for the calculations
nc_out = NCDataset("/gpfs/data/fs71391/cschmidt/attain_processed/monika/attain_hist_chem.nc","c")
defDim(nc_out,"lon",189)
defDim(nc_out,"lat",165)
defDim(nc_out,"time",length(wrf_dt))

wrf_var_out = defVar(nc_out,"O3",Float32,("lon","lat","time"))

wrf_var_out[:,:,:] = wrf_in["o3"][:,:,1,:]

close(nc_out)

