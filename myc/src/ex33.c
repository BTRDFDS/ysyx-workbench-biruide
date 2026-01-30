#include "minunit.h"
#include <ex32.h>
#include <assert.h>
#include <string.h>
#include <time.h>
char *values[] = {"XXXX", "1234", "abcd", "xjvef", "NDSS"};
#define NUM_VALUES 5
List *testWord;

List *create_words()
{
    int i = 0;
    List *words = List_create();

    for(i = 0; i < NUM_VALUES; i++) {
        List_push(words, values[i]);
    }

    return words;
}
List *create_wordsB()
{
    #define max 10000
    List *words = List_create();
    for(int i = 0; i < max; i++) {
        char str[20];
        sprintf(str, "%d", rand() % max);
        List_push(words, strdup(str));
    }
    return words;
}

int is_sorted(List *words)
{
    LIST_FOREACH(words, first, next, cur) {
        if(cur->next && strcmp(cur->value, cur->next->value) > 0) {
            debug("%s %s", (char *)cur->value, (char *)cur->next->value);
            return 0;
        }
    }

    return 1;
}

char *test_bubble_sort()
{
    //List *words = create_wordsB();
    List *words = List_create();
    ListCopy(testWord, words);

    clock_t start, end;
    double cpu_time_used;
    start = clock();
    // should work on a list that needs sorting
    int rc = List_bubble_sort(words, (List_compare)strcmp);
    mu_assert(rc == 0, "Bubble sort failed.");
    mu_assert(is_sorted(words), "Words are not sorted after bubble sort.");
    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("%f s\n", cpu_time_used);

    // should work on an already sorted list
    rc = List_bubble_sort(words, (List_compare)strcmp);
    mu_assert(rc == 0, "Bubble sort of already sorted failed.");
    mu_assert(is_sorted(words), "Words should be sort if already bubble sorted.");

    List_destroy(words);

    // should work on an empty list
    words = List_create(words);
    rc = List_bubble_sort(words, (List_compare)strcmp);
    mu_assert(rc == 0, "Bubble sort failed on empty list.");
    mu_assert(is_sorted(words), "Words should be sorted if empty.");

    List_destroy(words);

    return NULL;
}

char *test_merge_sort()
{
    //List *words = create_wordsB();
    List *words = List_create();
    ListCopy(testWord, words);

    clock_t start, end;
    double cpu_time_used;
    start = clock();
    // should work on a list that needs sorting
    List *res = List_merge_sort(words, (List_compare)strcmp);
    mu_assert(is_sorted(res), "Words are not sorted after merge sort.");
    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("%f s\n", cpu_time_used);

    List *res2 = List_merge_sort(res, (List_compare)strcmp);
    mu_assert(is_sorted(res), "Should still be sorted after merge sort.");
    List_destroy(res2);
    List_destroy(res);

    List_destroy(words);
    return NULL;
}

int List_insert_sorted(List *list, void *value, List_compare cmp)
{
    if (!list || !cmp) return -1;
    ListNode *new_node = calloc(1, sizeof(ListNode));
    if (!new_node) return -1;
    new_node->value = value;
    
    if (!list->first) {
        list->first = new_node;
        list->last = new_node;
        return 0;
    }
    
    ListNode *cur = list->first;
    ListNode *prev = NULL;
    while (cur) {
        if (cmp(cur->value, value) > 0) {
            break;
        }
        prev = cur;
        cur = cur->next;
    }

    if (!prev) {
        new_node->next = list->first;
        list->first = new_node;
    }
    else if (!cur) {
        prev->next = new_node;
        list->last = new_node;
    }
    else {
        prev->next = new_node;
        new_node->next = cur;
    }
    
    return 0;
}
char *test_list_insert_sorted()
{
    List *words = List_create();
    for (int i = 0; i < NUM_VALUES; i++)
    {
        mu_assert(List_insert_sorted(words, values[i], (List_compare)strcmp) == 0, "Join failed.");
    }
    /*
    mu_assert(List_insert_sorted(words, values[0], (List_compare)strcmp) == 0, "Join failed.");
    mu_assert(List_insert_sorted(words, values[1], (List_compare)strcmp) == 0, "Join failed.");
    mu_assert(List_insert_sorted(words, values[2], (List_compare)strcmp) == 0, "Join failed.");
    mu_assert(List_insert_sorted(words, values[3], (List_compare)strcmp) == 0, "Join failed.");
    mu_assert(List_insert_sorted(words, values[4], (List_compare)strcmp) == 0, "Join failed.");
    */
    mu_assert(is_sorted(words), "Words are not sorted after insert sorted.");
    
    List_destroy(words);
    
    return NULL;
}

List *listMergeBottom(List *list, List_compare cmp)//归并排序
{
    if (!list||!cmp) {return NULL;}
    if(List_count(list)<=1) return list;
    int count = List_count(list);
    List *myList = list;
    List *newList = NULL;
    List *left = List_create();
    List *right = List_create();

    void *val = NULL;
    for(int size = 1;size < count; size *= 2){
        newList = List_create();
        while (myList && List_count(myList) > 0) {
            for (int i = 0; i < size && myList; i++){
                val = List_shift(myList);
                if (val) List_push(left, val);
            }
            for (int i = 0; i < size && myList; i++){
                val = List_shift(myList);
                if (val) List_push(right, val);
            }
            while (List_count(left) > 0 || List_count(right) > 0) {
                if (List_count(left) > 0 && List_count(right) > 0) {
                    if (cmp(List_first(left), List_first(right)) <= 0) {
                        List_push(newList, List_shift(left));
                    } else {
                        List_push(newList, List_shift(right));
                    }
                } else if (List_count(left) > 0) {
                    List_push(newList, List_shift(left));
                } else {
                    List_push(newList, List_shift(right));
                }
            }
        }
        myList = newList;
    }
    
    List_destroy(left);
    List_destroy(right);

    return myList;
}


char *testMergeBottom()
{
    List *words = List_create();
    ListCopy(testWord, words);
    
    clock_t start, end;
    double cpu_time_used;
    start = clock();
    List *res = listMergeBottom(words, (List_compare)strcmp);
    mu_assert(is_sorted(res), "Words are not sorted after bottom-up merge sort.");
    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("%f s\n", cpu_time_used);
    
    List *res2 = listMergeBottom(res, (List_compare)strcmp);
    mu_assert(is_sorted(res2), "Should still be sorted after bottom-up merge sort.");
    
    List_destroy(res);
    List_destroy(res2);
    List_destroy(words);
    
    return NULL;
}

char *all_tests()
{
    testWord = create_wordsB();
    mu_suite_start();

    //mu_run_test(test_bubble_sort);
    mu_run_test(test_merge_sort);
    mu_run_test(testMergeBottom);
    //mu_run_test(test_list_insert_sorted);

    return NULL;
}

RUN_TESTS(all_tests);