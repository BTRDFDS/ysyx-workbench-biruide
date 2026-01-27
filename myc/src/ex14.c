#include <stdio.h>
#include <ctype.h>
#include <string.h>
int can_print_it(char ch);
void print_letters(char arg[],int l);
void print_arguments(int argc, char *argv[])
{
    int i = 0;
    for(i = 0; i < argc; i++) {
        print_letters(argv[i],strlen(argv[i]));
    }
}

void print_letters(char arg[],int l)
{
    int i = 0;
    for(i = 0; i < l; i++){
        char ch = arg[i];
        if(can_print_it(ch))
        {printf("'%c' == %d ", ch, ch);}
        }
    printf("\n");
}
int can_print_it(char ch){return isalpha(ch) || isblank(ch);}

int main(int argc, char *argv[])
{
    print_arguments(argc, argv);
    
    
    int i = 0;
    int j;

    for(i = 0; i < argc; i++) {
    j = 0;

    for(j = 0; argv[i][j] != '\0'; j++) {
        char ch = argv[i][j];

        if(isalpha(ch) || isblank(ch)) {printf("*'%c' == %d ", ch, ch);
        }
    }
    printf("\n");
    }
    i = 0;

    for(i = 0; i < argc; i++) {
    j = 0;

    for(j = 0; argv[i][j] != '\0'; j++) {
        char ch = argv[i][j];

        if(isdigit(ch)) {printf("'%c' == %d ", ch, ch);
        }
    }
    printf("\n");
    }
    i = 0;

    for(i = 0; i < argc; i++) {
    j = 0;

    for(j = 0; argv[i][j] != '\0'; j++) {
        char ch = argv[i][j];

        if(!isalnum(ch)) {printf("*'%c' == %d ", ch, ch);
        }
    }
    printf("\n");
    }
    return 0;
}
