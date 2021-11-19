#include <stdio.h>

void print_message() {
    printf("I am %s!\n", LIBNAME);
}

const char * get_identity() {
    return LIBNAME;
}
