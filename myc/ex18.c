#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
/** Our old friend die from ex17. */
void die(const char *message)
{
    if(errno) {
        perror(message);
    } else {
        printf("ERROR: %s\n", message);
    }

    exit(1);
}

// a typedef creates a fake type, in this
// case for a function pointer
typedef int (*compare_cb)(int a, int b);
typedef int* (*funCd)(int *numbers, int count, compare_cb cmp);
/**
 * A classic bubble sort function that uses the
 * compare_cb to do the sorting.
 */
int *bubble_sort(int *numbers, int count, compare_cb cmp)
{
    int temp = 0;
    int i = 0;
    int j = 0;
    int *target = malloc(count * sizeof(int));
    if(!target) die("Memory error.");
    if(numbers == NULL) die("Memory error");

    memcpy(target, numbers, count * sizeof(int));

    for(i = 0; i < count; i++) {
        for(j = 0; j < count - 1; j++) {
            if(cmp(target[j], target[j+1]) > 0) {
                temp = target[j+1];
                target[j+1] = target[j];
                target[j] = temp;
            }
        }
    }

    return target;
}

int* insertionSort(int *numbers, int count, compare_cb cmp) {
    if(numbers == NULL) die("Memory error");
    if(cmp == NULL) die("Memory error");
    int *target = malloc(count * sizeof(int));
    if(!target) die("Memory error.");
    memcpy(target, numbers, count * sizeof(int));
    for (int i = 1; i < count; i++) {
        int temp = target[i];  // 当前待插入的元素
        int j = i;
        // 向右移动大于temp的元素
        while (j > 0 && cmp(target[j - 1], temp) > 0) {
            target[j] = target[j - 1];
            j--;
        }
        target[j] = temp;  // 插入元素到正确位置
    }
    return target;
}


int sorted_order(int a, int b)
{
    return a - b;
}

int reverse_order(int a, int b)
{
    return b - a;
}

int strange_order(int a, int b)
{
    if(a == 0 || b == 0) {
        return 0;
    } else {
        return a % b;
    }
}

/**
 * Used to test that we are sorting things correctly
 * by doing the sort and printing it out.
 */
void test_sorting(int *numbers, int count, compare_cb cmp,funCd fun)
{
    int i = 0;
    int *sorted = fun(numbers, count, cmp);

    if(!sorted) die("Failed to sort as requested.");

    for(i = 0; i < count; i++) {
        printf("%d ", sorted[i]);
    }
    printf("\n");

    unsigned char *data = (unsigned char *)cmp;

    for(i = 0; i < 25; i++) {
        printf("%02x:", data[i]);
    }
    printf("\n");
    
    free(sorted);
}


int main(int argc, char *argv[])
{
    if(argc < 2) die("USAGE: ex18 4 3 1 5 6");

    int count = argc - 1;
    int i = 0;
    char **inputs = argv + 1;

    int *numbers = malloc(count * sizeof(int));
    if(!numbers) die("Memory error.");

    for(i = 0; i < count; i++) {
        numbers[i] = atoi(inputs[i]);
    }

    test_sorting(numbers, count, sorted_order ,bubble_sort);
    test_sorting(numbers, count, sorted_order ,insertionSort);
    test_sorting(numbers, count, reverse_order,bubble_sort);
    test_sorting(numbers, count, reverse_order,insertionSort);
    test_sorting(numbers, count, strange_order,bubble_sort);
    test_sorting(numbers, count, strange_order,insertionSort);
    //test_sorting(numbers, count, printf("\n"));
    //test_sorting(numbers, count, NULL);

    free(numbers);
    return 0;
}