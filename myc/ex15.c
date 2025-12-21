#include <stdio.h>
void print1(int *ages, char **names, int count) {
    int i;
    for(i = 0; i < count; i++) {
        printf("#%s has %d years alive.\n",
                *(names+i), *(ages+i));
    }
    printf("---\n");
}
void print2(int *cur_age, char **cur_name, int count) {
    int i;
    for(i = 0; i < count; i++) {
        printf("#%s is %d years old.\n",
                cur_name[i], cur_age[i]);
    }
    printf("---\n");
}
void print3(int *cur_age, char **cur_name, int count) {
    int i;
    for(i = 0; i < count; i++) {
        printf("#%s is %d years old again.\n",
                *(cur_name+i), *(cur_age+i));
    }
    printf("---\n");
}
void print4(int *ages, char **names, int count) {
    int *cur_age = ages;
    char **cur_name = names;
    for(cur_name = names, cur_age = ages;
            (cur_age - ages) < count;
            cur_name++, cur_age++)
    {
        printf("#%s lived %d years so far.\n",
                *cur_name, *cur_age);
    }
    printf("---\n");
}
int main(int argc, char *argv[])
{
    // create two arrays we care about
    int ages[] = {23, 43, 12, 89, 2};
    char *names[] = {
        "Alan", "Frank",
        "Mary", "John", "Lisa"
    };

    // safely get the size of ages
    int count = sizeof(ages) / sizeof(int);
    int i = 0;


    // setup the pointers to the start of the arrays
    int *cur_age = ages;
    char **cur_name = names;

	print1(ages, names, count);
	print2(cur_age, cur_name, count);
	print3(cur_age, cur_name, count);
	print4(ages, names, count);


    // first way using indexing
    for(i = 0; i < count; i++) {
        printf("%s has %d years alive.\n",
                *(names+i), *(ages+i));
    }

    printf("---\n");

    // second way using pointers
    for(i = 0; i < count; i++) {
        printf("%s is %d years old.\n",
                cur_name[i], cur_age[i]);
    }

    printf("---\n");

    // third way, pointers are just arrays
    for(i = 0; i < count; i++) {
        printf("%s is %d years old again.\n",
                *(cur_name+i), *(cur_age+i));
    }
    printf("---\n");

    // fourth way with pointers in a stupid complex way
    for(cur_name = names, cur_age = ages;
            (cur_age - ages) < count;
            cur_name++, cur_age++)
    {
        printf("%s lived %d years so far.\n",
                *cur_name, *cur_age);
    }
    printf("---\n");
	for(i=0;i<argc;i++){
		printf("%p: %s,%p,%p\n", *(argv+i), *(argv+i),(void*)(argv+i),argv+i);
	}
    printf("---\n");
    i=0;
    while(i<argc){
		printf("%p: %s,%p,%p\n", *(names+i), *(names+i),(void*)(names+i),names+i);
    	i++;
    }
    printf("---\n");
	for(i=0;i<argc;i++){
		printf(" %d,%p\n", *(ages+i),ages+i);
	}
    printf("---\n");

    return 0;
}
