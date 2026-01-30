#include <ex32.h>
#include <dbg.h>

//ex32是功能函数，a是全部测试，b是原本的测试

List *List_create()
{
    return calloc(1, sizeof(List));
}

void List_destroy(List *list)
{
    LIST_FOREACH(list, first, next, cur) {
        if(cur->prev) {
            free(cur->prev);
        }
    }

    free(list->last);
    free(list);
}


void List_clear(List *list)
{
    if(list==NULL) return;
    while(list->count>0){
        List_pop(list);
    }
    LIST_FOREACH(list, first, next, cur) {
        free(cur->value);
    }
}


void List_clear_destroy(List *list)
{
    List_clear(list);
    List_destroy(list);
}


void List_push(List *list, void *value)
{
    ListNode *node = calloc(1, sizeof(ListNode));
    check_mem(node);

    node->value = value;

    if(list->last == NULL) {
        list->first = node;
        list->last = node;
    } else {
        list->last->next = node;
        node->prev = list->last;
        list->last = node;
    }

    list->count++;

error:
    return;
}

void *List_pop(List *list)
{
    ListNode *node = list->last;
    return node != NULL ? List_remove(list, node) : NULL;
}

void List_unshift(List *list, void *value)
{
    ListNode *node = calloc(1, sizeof(ListNode));
    check_mem(node);

    node->value = value;

    if(list->first == NULL) {
        list->first = node;
        list->last = node;
    } else {
        node->next = list->first;
        list->first->prev = node;
        list->first = node;
    }

    list->count++;

error:
    return;
}

void *List_shift(List *list)
{
    ListNode *node = list->first;
    return node != NULL ? List_remove(list, node) : NULL;
}

void *List_remove(List *list, ListNode *node)
{
    void *result = NULL;

    check(list->first && list->last, "List is empty.");
    check(node, "node can't be NULL");

    if(node == list->first && node == list->last) {
        list->first = NULL;
        list->last = NULL;
    } else if(node == list->first) {
        list->first = node->next;
        check(list->first != NULL, "Invalid list, somehow got a first that is NULL.");
        list->first->prev = NULL;
    } else if (node == list->last) {
        list->last = node->prev;
        check(list->last != NULL, "Invalid list, somehow got a next that is NULL.");
        list->last->next = NULL;
    } else {
        ListNode *after = node->next;
        ListNode *before = node->prev;
        after->prev = before;
        before->next = after;
    }

    list->count--;
    result = node->value;
    free(node);

error:
    return result;
}
void ListCopy(List *listFrom, List *listTo){
    check(listFrom != NULL, "ListFrom is NULL");
    check(listTo != NULL, "ListTo is NULL");

    List_clear(listTo);

    LIST_FOREACH(listFrom, first, next, cur) {
        List_push(listTo, cur->value);
    }

error:
    return;
}

void ListLink(List *list1, List *list2) {
    check(list1 != NULL, "list1 is NULL");
    check(list2 != NULL, "list2 is NULL");

    if(list2->count == 0) return;

    if(list1->last) {
        list1->last->next = list2->first;
        if(list2->first) {
            list2->first->prev = list1->last;
        }
    } else {
        list1->first = list2->first;
    }
    
    list1->last = list2->last;
    list1->count += list2->count;
    
    list2->first = NULL;
    list2->last = NULL;
    list2->count = 0;
    
error:
    return;
}

List *ListSplit(List *list, int count) {
    check(list != NULL, "NULL");
    check(count >= 0 && count <= list->count, "Invalid count");
    
    if(count == 0 || count == list->count) return NULL;
    
    List *new_list = List_create();
    check_mem(new_list);
    
    ListNode *node = list->first;
    for(int i = 0; i < count - 1; i++) {
        node = node->next;
    }
    
    new_list->first = node->next;
    new_list->last = list->last;
    new_list->count = list->count - count;
    
    if(node->next) {
        node->next->prev = NULL;
    }
    node->next = NULL;
    
    list->last = node;
    list->count = count;
    
    return new_list;

error:
    if(new_list) List_destroy(new_list);
    return NULL;
}

void ListNode_swap(ListNode *a, ListNode *b)
{
    void *temp = a->value;
    a->value = b->value;
    b->value = temp;
}

int List_bubble_sort(List *list, List_compare cmp)
{
    int sorted = 1;

    if(List_count(list) <= 1) {
        return 0;  // already sorted
    }

    do {
        sorted = 1;
        LIST_FOREACH(list, first, next, cur) {
            if(cur->next) {
                if(cmp(cur->value, cur->next->value) > 0) {
                    ListNode_swap(cur, cur->next);
                    sorted = 0;
                }
            }
        }
    } while(!sorted);

    return 0;
}

List *List_merge(List *left, List *right, List_compare cmp)
{
    List *result = List_create();
    void *val = NULL;

    while(List_count(left) > 0 || List_count(right) > 0) {
        if(List_count(left) > 0 && List_count(right) > 0) {
            if(cmp(List_first(left), List_first(right)) <= 0) {
                val = List_shift(left);
            } else {
                val = List_shift(right);
            }

            List_push(result, val);
        } else if(List_count(left) > 0) {
            val = List_shift(left);
            List_push(result, val);
        } else if(List_count(right) > 0) {
            val = List_shift(right);
            List_push(result, val);
        }
    }

    return result;
}

List *List_merge_sort(List *list, List_compare cmp)
{
    if(List_count(list) <= 1) {
        return list;
    }

    List *left = List_create();
    List *right = List_create();
    int middle = List_count(list) / 2;

    LIST_FOREACH(list, first, next, cur) {
        if(middle > 0) {
            List_push(left, cur->value);
        } else {
            List_push(right, cur->value);
        }

        middle--;
    }

    List *sort_left = List_merge_sort(left, cmp);
    List *sort_right = List_merge_sort(right, cmp);

    if(sort_left != left) List_destroy(left);
    if(sort_right != right) List_destroy(right);

    return List_merge(sort_left, sort_right, cmp);
}
