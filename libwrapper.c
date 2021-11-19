#define _GNU_SOURCE

#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <errno.h>

void * handles[1024] = {0};
int num_handles = 0;

void load_libraries(const char ** libnames) {
    Lmid_t lmid = LM_ID_NEWLM;
    while (libnames[num_handles] != NULL && strlen(libnames[num_handles]) != 0) {
        printf("libwrapper: loading %s\n", libnames[num_handles]);
        handles[num_handles] = dlmopen(lmid, libnames[num_handles], RTLD_LAZY);
        if (handles[num_handles] == NULL) {
            printf("ERROR: could not dlopen(%s): %s\n", libnames[num_handles], dlerror());
            return;
        }
        dlinfo(handles[num_handles], RTLD_DI_LMID, &lmid);
        num_handles++;
    }
}

void * wrapper_dlsym(const char * symbol) {
    for (int lib_idx=0; lib_idx<num_handles; ++lib_idx) {
        void * addr = dlsym(handles[lib_idx], symbol);
        if (addr != NULL)
            return addr;
    }
    return NULL;
}
