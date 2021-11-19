using Libdl, Random

function wrapper_load(libconfigurable_path::String, libdependent_path::String)
    mktempdir() do dir
        # Create randomized `libwrapper.so`
        wrapper_path = joinpath(dir, "libwrapper-$(randstring(8)).so")
        cp(joinpath(@__DIR__, "libwrapper.so"), wrapper_path)

        # Open it with RTLD_LOCAL, so that it does not interfere in our global symbol namespace
        hdl = dlopen(wrapper_path, RTLD_LOCAL | RTLD_LAZY)
        @assert hdl != C_NULL "libwrapper loads properly"
        
        # Ensure that we cannot lookup the symbols in `libconfigurable` or `libdependent`
        function symcheck(hdl, symbol_name)
            @assert dlsym(hdl, symbol_name; throw_error=false) === nothing "$(symbol_name) inaccessible"
        end
        symcheck.(hdl, ("print_message", "get_identity", "do_work"))

        # But call `load_libraries()` to get 
        load_libraries = dlsym(hdl, :load_libraries)
        wrapper_dlsym = dlsym(hdl, :wrapper_dlsym)

        # Tell libwrapper to load the libraries we're interested in
        ccall(load_libraries, Cvoid, (Ptr{Cstring},), [libconfigurable_path, libdependent_path, ""])

        # Assert that Julia still can't see these symbols
        symcheck.(hdl, ("print_message", "get_identity", "do_work"))

        # But we can call through our wrapper dlsym
        do_work = ccall(wrapper_dlsym, Ptr{Cvoid}, (Cstring,), "do_work")
        @assert do_work != C_NULL "wrapper_dlsym can lookup do_work"

        # Call do_work
        @info("About to call do_work", do_work)
        ccall(do_work, Cvoid, ())
        println()
    end
end

wrapper_load("./a/libconfigurable.so", "./libdependent.so")
wrapper_load("./b/libconfigurable.so", "./libdependent.so")
