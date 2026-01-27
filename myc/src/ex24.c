#include <stdio.h>
#include "dbg.h"
#include <stdlib.h>

#define MAX_DATA 100

typedef enum EyeColor {
    BLUE_EYES, GREEN_EYES, BROWN_EYES,
    BLACK_EYES, OTHER_EYES
} EyeColor;

const char *EYE_COLOR_NAMES[] = {
    "Blue", "Green", "Brown", "Black", "Other"
};

typedef struct Person {
    int age;
    char first_name[MAX_DATA];
    char last_name[MAX_DATA];
    EyeColor eyes;
    float income;
} Person;


int main(int argc, char *argv[])
{
    Person you = {.age = 0};
    int i = 0;
    char *in = NULL;
    char data[MAX_DATA] = {0};

    printf("What's your First Name? ");
    in = fgets(you.first_name, MAX_DATA-1, stdin);
    check(in != NULL, "Failed to read first name.");
    // 移除换行符和空白字符
    char *end = you.first_name + strlen(you.first_name) - 1;
    while(end >= you.first_name && (*end == '\n' || *end == '\r' || *end == ' ' || *end == '\t')) {
        *end = '\0';
        end--;
    }

    printf("What's your Last Name? ");
    in = fgets(you.last_name, MAX_DATA-1, stdin);
    check(in != NULL, "Failed to read last name.");
    end = you.last_name + strlen(you.last_name) - 1;
    while(end >= you.last_name && (*end == '\n' || *end == '\r' || *end == ' ' || *end == '\t')) {
        *end = '\0';
        end--;
    }


    printf("How old are you? ");
    int rc = scanf("%d", &you.age);
    check(rc > 0, "You have to enter a number.");
    //int rc = fscanf(stdin, "%d", &you.age);
    /*
    in = fgets(data, MAX_DATA-1, stdin);
    check(in != NULL, "You have to enter a number.");
    you.age = atoi(data);
    check(you.age > 0 && you.age < 150, "You have to enter a number.");
    */

    printf("What color are your eyes:\n");
    for(i = 0; i <= OTHER_EYES; i++) {
        printf("%d) %s\n", i+1, EYE_COLOR_NAMES[i]);
    }
    printf("> ");

    int eyes = -1;
    rc = scanf("%d", &eyes);
    check(rc > 0, "You have to enter a number.");
   // rc = fscanf(stdin, "%d", &eyes);
   /*
    in = fgets(data, MAX_DATA-1, stdin);
    check(in != NULL, "You have to enter a number.");
    eyes = atoi(data);
    check(eyes > 0, "You have to enter a number.");
    */

    you.eyes = eyes - 1;
    check(you.eyes <= OTHER_EYES && you.eyes >= 0, "Do it right, that's not an option.");
    printf("How much do you make an hour? ");
    //rc = fscanf(stdin, "%f", &you.income);
    rc = scanf("%f", &you.income);
    check(rc > 0, "You have to enter a number.");
    /*
    in = fgets(data, MAX_DATA-1, stdin);
    check(in != NULL, "You have to enter a number.");
    you.income = atof(data);
    check(you.income > 0, "Enter a floating point number.");
    */
    printf("----- RESULTS -----\n");

    printf("First Name: %s\n", you.first_name);
    printf("Last Name: %s\n", you.last_name);
    printf("Age: %d\n", you.age);
    printf("Eyes: %s\n", EYE_COLOR_NAMES[you.eyes]);
    printf("Income: %f\n", you.income);

    return 0;
error:

    return -1;
}