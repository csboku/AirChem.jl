using Pkg,YAML

Pkg.activate("/home/fs71391/cschmidt/git/AirChem.jl")

using Base.Threads,AirChem

cpus = Threads.nthreads()


log_message("Loading modules")

log_message("Running Julia whith $cpus cores")

log_message("Read config")
wrf_config = YAML.load_file("config.yaml")

input_dir = wrf_config["input"]["folder"]
input_files = readdir(input_dir,join=true)
input_f = readdir(input_dir)

output_dir = wrf_config["output"]["folder"]
output_pattern = wrf_config["output"]["pattern"]


wrf_vars_3d = wrf_config["variables_3d"]
wrf_vars_2d = wrf_config["variables_2d"]

for i in eachindex(input_f)
    print(input_f[i])
    process_file_chunks(input_files[i],output_dir,output_pattern,wrf_vars_3d,wrf_vars_2d)
end


