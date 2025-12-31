#include <unistd.h>

int main(int argc, char *argv[])
{
    int i = 0;
    int *p = NULL;

    while(i < 100) {
        usleep(3000);
        i++;
        if(i == 50) {
            *p = 100;
        }
    }

    return 0;
}