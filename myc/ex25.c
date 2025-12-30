/** WARNING: This code is fresh and potentially isn't correct yet. */

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "dbg.h"

#define MAX_DATA 100

int read_string(char **out_string, int max_buffer)
{
    *out_string = calloc(1, max_buffer + 1);
    check_mem(*out_string);

    char *result = fgets(*out_string, max_buffer, stdin);
    check(result != NULL, "Input error.");

    return 0;

error:
    if(*out_string) free(*out_string);
    *out_string = NULL;
    return -1;
}

int read_int(int *out_int)
{
    char *input = NULL;
    int rc = read_string(&input, MAX_DATA);
    check(rc == 0, "Failed to read number.");

    *out_int = atoi(input);

    free(input);
    return 0;

error:
    if(input) free(input);
    return -1;
}

int printfString(char *out_string, int max_buffer)
{
    for(int i = 0; i < max_buffer && out_string[i] != '\0'; i++){
        fputc(out_string[i],stdout);
    }

    return 0;
}

int printfInt(int out_int)
{
    #define MAX 11
    char number[MAX] = {0};
    int idx = MAX-1;

    if(out_int == 0){
        fputc('0', stdout);
        return 0;
    }else if(out_int < 0){
        fputc('-', stdout);
        out_int = -out_int;
    }
    while(out_int > 0 && idx >= 0){
        number[idx] = (out_int % 10) + '0';
        out_int /= 10;
        idx--;
    }
    for(int i = idx + 1; i < MAX; i++){
        if(number[i] != '\0'){
            fputc(number[i], stdout);
        }
    }
    return 0;
}
int read_scan(const char *fmt, ...)
{
    int i = 0;
    int rc = 0;
    int *out_int = NULL;
    char *out_char = NULL;
    char **out_string = NULL;
    int max_buffer = 0;

    va_list argp;
    va_start(argp, fmt);

    for(i = 0; fmt[i] != '\0'; i++) {
        if(fmt[i] == '%') {
            i++;
            switch(fmt[i]) {
                case '\0':
                    sentinel("Invalid format, you ended with %%.");
                    break;

                case 'd':
                    out_int = va_arg(argp, int *);
                    rc = read_int(out_int);
                    check(rc == 0, "Failed to read int.");
                    break;

                case 'c':
                    out_char = va_arg(argp, char *);
                    *out_char = fgetc(stdin);
                    break;

                case 's':
                    max_buffer = va_arg(argp, int);
                    out_string = va_arg(argp, char **);
                    rc = read_string(out_string, max_buffer);
                    check(rc == 0, "Failed to read string.");
                    break;

                default:
                    sentinel("Invalid format.");
            }
        } else {
            fgetc(stdin);
        }

        check(!feof(stdin) && !ferror(stdin), "Input error.");
    }

    va_end(argp);
    return 0;

error:
    va_end(argp);
    return -1;
}
int myPrintf(const char *fmt, ...)
{
    int i = 0;
    int out_int = 0;
    char out_char = '\0';
    char *out_string = NULL;
    va_list argp;
    va_start(argp, fmt);

    for(i = 0; fmt[i] != '\0'; i++) {
        if(fmt[i] == '%') {
            i++;
            switch(fmt[i]) {
                case '\0':
                    sentinel("Invalid format, you ended with %%.");
                    break;
                case 'd':
                    out_int = va_arg(argp, int);
                    //fputc(out_int,stdout);
                    printfInt(out_int);
                    break;
                case 'c':
                    out_char = (char)va_arg(argp, int);
                    fputc(out_char,stdout);
                    break;
                case 's':
                    out_string = va_arg(argp, char*);
                    printfString(out_string, MAX_DATA);
                    //fputc(*out_string,stdout);
                    break;
                default:
                    sentinel("Invalid format.");
            }
        } else {
            fputc(fmt[i],stdout);
        }
    }
    va_end(argp);
    return 0;

error:
    va_end(argp);
    return -1;
}

int main(int argc, char *argv[])
{
    char *first_name = NULL;
    char initial = ' ';
    char *last_name = NULL;
    int age = 0;

    printf("What's your first name? ");
    int rc = read_scan("%s", MAX_DATA, &first_name);
    check(rc == 0, "Failed first name.");

    printf("What's your initial? ");
    rc = read_scan("%c\n", &initial);
    check(rc == 0, "Failed initial.");

    printf("What's your last name? ");
    rc = read_scan("%s", MAX_DATA, &last_name);
    check(rc == 0, "Failed last name.");

    printf("How old are you? ");
    rc = read_scan("%d", &age);

    printf("---- RESULTS ----\n");
    printf("First Name: %s", first_name);
    printf("Initial: '%c'\n", initial);
    printf("Last Name: %s", last_name);
    printf("Age: %d\n", age);
    myPrintf("First Name: %s", first_name);
    myPrintf("Initial: '%c'\n", initial);
    myPrintf("Last Name: %s", last_name);
    myPrintf("Age: %d\n", age);
    free(first_name);
    free(last_name);
    return 0;
error:
    return -1;
}