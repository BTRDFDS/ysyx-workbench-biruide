#include <stdio.h>

int main(int argc, char *argv[])
{
	/**
    if(argc != 2) {
        printf("ERROR: You need one argument.\n");
        // this is how you abort a program
        return 1;
    }
    **/

    int i = 0;
    char letter;
    int j = 0;
    for(j = 1;j<argc;j++){
    for(i = 0,letter = argv[j][i]; argv[j][i] != '\0'; i++) {
        char letter = argv[j][i];
		if ((letter >= 'A' && letter <= 'Z')) {letter += 32;}
        switch(letter) {
            case 'a':
                printf("%d,%d: 'A'\n", j,i);
                break;

            case 'e':
                printf("%d,%d: 'E'\n", j,i);
                break;

            case 'i':
                printf("%d,%d: 'I'\n", j,i);
                break;

            case 'o':
                printf("%d,%d: 'O'\n", j,i);
                break;

            case 'u':
                printf("%d,%d: 'U'\n", j,i);
                break;

            case 'y':
                if(i > 2) {
                    // it's only sometimes Y
                    printf("%d,%d: 'Y'\n",j, i);
                }
                break;

            default:
                printf("%d,%d: %c is not a vowel\n",j, i, letter);
        }
        if(letter=='a'){printf("-%d,%d: 'A'\n", j,i);}
        else if(letter=='e'){printf("-%d,%d: 'E'\n", j,i);}
        else if(letter=='i'){printf("-%d,%d: 'I'\n", j,i);}
        else if(letter=='o'){printf("-%d,%d: 'O'\n", j,i);}
        else if(letter=='u'){printf("-%d,%d: 'U'\n", j,i);}
        else if(letter=='y'){printf("-%d,%d: 'Y'\n", j,i);}
        else{printf("-%d,%d: %c is not a vowel\n",j, i, letter);}
    }
	}
    return 0;
}
