all:

# Build multiple variations of `libconfigurable`, each with the same SONAME
%/libconfigurable.so: libconfigurable.c
	mkdir -p $(dir $@)
	$(CC) -shared -fPIC -DLIBNAME=\"$(dir $@)\" -Wl,-soname,$(notdir $@) -o $@ $<

# Build one version of `libdependent`
libdependent.so: libdependent.c a/libconfigurable.so
	$(CC) -shared -fPIC -o $@ -lconfigurable -La $<

# Build one version of `libwrapper`
libwrapper.so: libwrapper.c
	$(CC) -shared -fPIC -o $@ $<

# Run test in Julia showcasing that we can load two different versions of the same library
test: libwrapper.so libdependent.so a/libconfigurable.so b/libconfigurable.so
	julia run_test.jl

all: libwrapper.so libdependent.so a/libconfigurable.so b/libconfigurable.so

clean:
	rm -rf *.so a b
