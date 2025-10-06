using NCDatasets,Rasters,Proj,YAML,Dates
import ArchGDAL

wrf_config = YAML.load_file("config.yaml")
wrf_vars = wrf_config["variables"]

# wrf_in = RasterStack("/gpfs/data/fs71391/cschmidt/attain_raw_output/rcp45_2026t35/part_05/wrfout_d01_2028-01-01_00:00:00",source=:netcdf,lazy=true,name=["o3","no"])

wrf_in = Dataset("/gpfs/data/fs71391/cschmidt/attain_raw_output/rcp45_2026t35/part_05/wrfout_d01_2028-01-01_00:00:00")
## LCC proj string +proj=lcc +

# Metadata comes from dimensional data package
wrf_meta = metadata(wrf_in)

# println.(wrf_meta)
# wrf_proj = pyproj.Proj(proj='lcc', # projection type: Lambert Conformal Conic
#                        lat_1=ds.TRUELAT1, lat_2=ds.TRUELAT2, # Cone intersects with the sphere
#                        lat_0=ds.MOAD_CEN_LAT, lon_0=ds.STAND_LON, # Center point
#                        a=6370000, b=6370000) # This is it! The Earth is a perfect sphere


wrf_proj = "+proj=lcc +lat_1=$(wrf_meta["TRUELAT1"]) +lat_2=$(wrf_meta["TRUELAT2"]) +lat_0=$(wrf_meta["MOAD_CEN_LAT"]) +lon_0=$(wrf_meta["STAND_LON"])"


wrf_meta["DY"]
wrf_meta["DX"]
wrf_meta["CEN_LAT"]
wrf_meta["CEN_LON"]
wrf_meta["TRUELAT1"]
wrf_meta["TRUELAT2"]
wrf_meta["TRUELON"]

wrf_in
wrf_in.dim

dims(wrf_meta)

## Create WRF Grid
function create_wrf_gird(ds)



end

function repair_dataset(ds)

end

### Create datetimes for WRF

wrf_dt =  collect(DateTime(2007, 1, 1, 0):Hour(1):DateTime(2016, 12 , 31, 23))

wrf_lat = wrf_in["XLAT"][1,:,1]
wrf_lon = wrf_in["XLONG"][:,1,1]


nan_matrix = fill(NaN,189,165,length(wrf_dt))


wrf_out = Raster(nan_matrix,Y(wrf_lat),X(wrf_lon),Ti(wrf_dt))
wrf_out = Raster(nan_matrix,dims=(Y(wrf_lon),X(wrf_lat),Ti(wrf_dt)),name=:O3,crs=EPSG(4326))

wrf_sbl = Symbol.(wrf_vars)

for var in wrf_sbl
    println(var)
    write("/gpfs/data/fs71391/cschmidt/attain_processed/monika/attain_hist_chem.nc",Raster(nan_matrix,dims=(Y(wrf_lon),X(wrf_lat),Ti(wrf_dt)),name=var,crs=EPSG(4326)),force=true)
end
