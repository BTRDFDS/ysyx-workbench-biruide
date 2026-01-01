#include <ex32.h>
#include <dbg.h>

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
    
    if(list2->count == 0) {
        List_destroy(list2);
        return;
    }
    
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
    
    free(list2);

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
