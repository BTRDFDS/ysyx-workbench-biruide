#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>

typedef int (*lib_function)(const char *data, const int max);

typedef struct {
    char *name;
    char *file;
    char *fun;
    char *data;
    int max;
}test;
#define TESTS_SIZE 8
test tests[TESTS_SIZE] = {
    {"ex29","./libex29.so", "print_a_message", "hello there", 512},
    {"./ex29","./ex29lib.so", "print_a_message", "hello there", 512},
    {"./ex29","./ex29lib.so", "uppercase", "hello there", 512},
    {"./ex29","./ex29lib.so", "lowercase", "HELLO tHeRe", 512},
    {"./ex29","./ex29lib.so", "fail_on_purpose", "i fail", 512},
    {"./ex29","./ex29lib.so", "fail_on_purpose", NULL, 512},
    {"./ex29","./ex29lib.so", "adfasfasdf", "asdfadff", 512},
    {"./ex29","./libex.so", "adfasfasdf", "asdfadfas", 512}
};


int main(int argc, char *argv[])
{
    int rc = 0;
    char *fileName;
    char *lib_file = NULL;
    char *func_to_run = NULL;
    char *data = NULL;
    int max = 512;

    for(int i = 0;i<TESTS_SIZE;i++){
        fileName = tests[i].name;
        lib_file = tests[i].file;
        func_to_run = tests[i].fun;
        data = tests[i].data;
        max = tests[i].max;
        if(max <1){
            max = 512;
        }
        printf("./ex29Test: %s %s %s %d\n", lib_file, func_to_run, data, max);
        if(fileName == NULL||strstr(fileName, "./ex29") !=fileName){
            printf("command cannot found\n");
        }
        if(lib_file == NULL || func_to_run == NULL || data == NULL){
            printf("USAGE: ex29 libex29.so function data\n");
            continue;
        }
        void *lib = dlopen(lib_file, RTLD_NOW);
        //check(lib != NULL, "Failed to open the library %s: %s", lib_file, dlerror());
        if(lib == NULL){
            printf("Failed to open the library %s: %s\n", lib_file, dlerror());
            continue;
        }
        lib_function func = dlsym(lib, func_to_run);
        //check(func != NULL, "Did not find %s function in the library %s: %s", func_to_run, lib_file, dlerror());
        if(func == NULL){
            printf("Did not find %s function in the library %s: %s\n", func_to_run, lib_file, dlerror());
            continue;
        }

        rc = func(data, max);
        //check(rc == 0, "Function %s return %d for data: %s", func_to_run, rc, data);
        if(rc != 0){
            printf("Function %s return %d for data: %s\n", func_to_run, rc, data);
            continue;
        }

        rc = dlclose(lib);
        //check(rc == 0, "Failed to close %s", lib_file);
        if(rc != 0){
            printf("Failed to close %s\n", lib_file);
        }
    }
    return 0;
}