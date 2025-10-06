
#
# t _threads = Threads.nthreads()
#
# println("Using julia with $t_threads threads")
#
#
# t_arr = zeros(Threads.nthreads())
#
# Threads.@threads for i = 1:Threds.nthreads()
#     t_arr[i] = Threads.threadid()
# end
#
# println("T_arr")
# println.(t_arr)
#

function asc_test()
    t_threads = Threads.nthreads()

    println("Using julia with $t_threads threads")

    t_arr = zeros(Threads.nthreads());

    Threads.@threads for i = 1:t_threads
        t_arr[i] = Threads.threadid()
    end

    println.(t_arr)
end


export asc_test

