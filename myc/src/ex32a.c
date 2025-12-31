#include "minunit.h"
#include <ex32.h>
#include <assert.h>

static List *list = NULL;
static List *list2 = NULL;

char *test1 = "test1 data";
char *test2 = "test2 data";
char *test3 = "test3 data";
char *test4 = "test4 data";
char *test5 = "test5 data";
char *test6 = "test6 data";
char *test7 = "test7 data";


char *test_create()
{
    list = List_create();
    list2 = List_create();  // 新增
    mu_assert(list != NULL, "Failed to create list.");
    mu_assert(list2 != NULL, "Failed to create list2.");  // 新增

    return NULL;
}


char *test_destroy()
{
    List_clear_destroy(list);
    List_clear_destroy(list2);

    return NULL;

}


char *test_push_pop()
{
    List_push(list, test1);
    mu_assert(List_last(list) == test1, "Wrong last value.");

    List_push(list, test2);
    mu_assert(List_last(list) == test2, "Wrong last value");

    List_push(list, test3);
    mu_assert(List_last(list) == test3, "Wrong last value.");
    mu_assert(List_count(list) == 3, "Wrong count on push.");
    
    List_push(list, test4);
    mu_assert(List_last(list) == test4, "Wrong last value.");
    mu_assert(List_count(list) == 4, "Wrong count on push.");

    List_push(list, test5);
    mu_assert(List_last(list) == test5, "Wrong last value.");
    mu_assert(List_count(list) == 5, "Wrong count on push.");

    List_push(list, test6);
    mu_assert(List_last(list) == test6, "Wrong last value.");
    mu_assert(List_count(list) == 6, "Wrong count on push.");

    List_push(list, test7);
    mu_assert(List_last(list) == test7, "Wrong last value.");
    mu_assert(List_count(list) == 7, "Wrong count on push.");

    char *val = List_pop(list);
    mu_assert(val == test7, "Wrong value on pop.");

    val = List_pop(list);
    mu_assert(val == test6, "Wrong value on pop.");

    val = List_pop(list);
    mu_assert(val == test5, "Wrong value on pop.");

    val = List_pop(list);
    mu_assert(val == test4, "Wrong value on pop.");

    val = List_pop(list);
    mu_assert(val == test3, "Wrong value on pop.");

    val = List_pop(list);
    mu_assert(val == test2, "Wrong value on pop.");

    val = List_pop(list);
    mu_assert(val == test1, "Wrong value on pop.");
    mu_assert(List_count(list) == 0, "Wrong count after pop.");

    return NULL;
}

char *test_unshift()
{
    List_unshift(list, test1);
    mu_assert(List_first(list) == test1, "Wrong first value.");

    List_unshift(list, test2);
    mu_assert(List_first(list) == test2, "Wrong first value");

    List_unshift(list, test3);
    mu_assert(List_first(list) == test3, "Wrong last value.");
    mu_assert(List_count(list) == 3, "Wrong count on unshift.");

    return NULL;
}

char *test_remove()
{
    // we only need to test the middle remove case since push/shift
    // already tests the other cases

    char *val = List_remove(list, list->first->next);
    mu_assert(val == test2, "Wrong removed element.");
    mu_assert(List_count(list) == 2, "Wrong count after remove.");
    mu_assert(List_first(list) == test3, "Wrong first after remove.");
    mu_assert(List_last(list) == test1, "Wrong last after remove.");

    return NULL;
}


char *test_shift()
{
    mu_assert(List_count(list) != 0, "Wrong count before shift.");

    char *val = List_shift(list);
    mu_assert(val == test3, "Wrong value on shift.");

    val = List_shift(list);
    mu_assert(val == test1, "Wrong value on shift.");
    mu_assert(List_count(list) == 0, "Wrong count after shift.");

    return NULL;
}

char *test_copy()
{
    List_clear(list);
    List_clear(list2);

    List_push(list, test1);
    List_push(list, test2);
    List_push(list, test3);
    ListCopy(list, list2);
    mu_assert(List_count(list2) == 3, "Wrong count after copy.");
    mu_assert(List_first(list2) == test1, "Wrong first value after copy.");
    mu_assert(List_last(list2) == test3, "Wrong last value after copy.");
    return NULL;
}

char *test_link()
{
    List_clear(list);
    List_clear(list2);
    
    char *val1 = strdup("test1 data");
    char *val2 = strdup("test2 data");
    char *val3 = strdup("test3 data");
    char *val4 = strdup("test4 data");
    
    List_push(list, val1);
    List_push(list, val2);
    List_push(list2, val3);
    List_push(list2, val4);
    
    ListLink(list, list2);
    mu_assert(List_count(list) == 4, "Wrong count after join.");
    mu_assert(List_first(list) == val1, "Wrong first value after join.");
    mu_assert(List_last(list) == val4, "Wrong last value after join.");
    return NULL;
}



char *test_split()
{
    List_clear(list);

    List_push(list, test1);
    List_push(list, test2);
    List_push(list, test3);
    List_push(list, test4);
    List *new_list = ListSplit(list, 2);
    mu_assert(List_count(list) == 2, "Wrong count in original list after split.");
    mu_assert(List_first(list) == test1, "Wrong first value in original list.");
    mu_assert(List_last(list) == test2, "Wrong last value in original list.");
    mu_assert(List_count(new_list) == 2, "Wrong count in new list after split.");
    mu_assert(List_first(new_list) == test3, "Wrong first value in new list.");
    mu_assert(List_last(new_list) == test4, "Wrong last value in new list.");
    List_destroy(new_list);
    return NULL;
}






char *all_tests() {
    mu_suite_start();

    mu_run_test(test_create);
    mu_run_test(test_push_pop);
    mu_run_test(test_unshift);
    mu_run_test(test_remove);
    mu_run_test(test_shift);
    mu_run_test(test_copy);
    //mu_run_test(test_link);
    //mu_run_test(test_split);
    mu_run_test(test_destroy);

    return NULL;
}

RUN_TESTS(all_tests);
