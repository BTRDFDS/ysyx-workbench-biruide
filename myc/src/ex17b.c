#include<stdio.h>
#include<stdlib.h>
#define size 16
int top = -1;
int stack[size];
void push(int e){
    if(top == size-1){
        printf("栈满\n");
    }
    else{
        top++;
        stack[top] = e;
    }
}
int pop(){
    if(top == -1){
        printf("栈空\n");
        return -1;
    }
    else{
        int e = stack[top];
        top--;
        return e;
    }
}
int main(){
    int i,j;
    for(i = 0; i < 10; i++){
        j = rand()%9999;
        printf("#%d->%d\n", i,j);
        push(j);
    }
    for(i = 0; i < 10; i++){
        printf("%d<-%d\n", i,pop());
    }
    return 0;
}