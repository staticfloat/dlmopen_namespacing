#include <stdio.h>

void print_message();

void do_work() {
    printf("libdependent about to call print_message():\n");
    print_message();
}

