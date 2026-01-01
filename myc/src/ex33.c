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
    #define max 1000
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

    // should work on a list that needs sorting
    int rc = List_bubble_sort(words, (List_compare)strcmp);
    mu_assert(rc == 0, "Bubble sort failed.");
    mu_assert(is_sorted(words), "Words are not sorted after bubble sort.");

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

    // should work on a list that needs sorting
    List *res = List_merge_sort(words, (List_compare)strcmp);
    mu_assert(is_sorted(res), "Words are not sorted after merge sort.");

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

char *all_tests()
{
    testWord = create_wordsB();
    mu_suite_start();
    clock_t start, end;
    double cpu_time_used;
    start = clock();
    mu_run_test(test_bubble_sort);
    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("%f s\n", cpu_time_used);

    start = clock();
    mu_run_test(test_merge_sort);
    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("%f s\n", cpu_time_used);

    mu_run_test(test_list_insert_sorted);

    return NULL;
}

RUN_TESTS(all_tests);