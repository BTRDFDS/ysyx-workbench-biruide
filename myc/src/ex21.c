//探究变量类型
#include<stdio.h>
#include<stdint.h>
int main(){
    printf("long double:%ld\n",sizeof(long double));
    printf("double:%ld\n",sizeof(double));
    printf("float:%ld\n",sizeof(float));
    printf("long:%ld\n",sizeof(long));
    printf("int:%ld\n",sizeof(int));
    printf("short:%ld\n",sizeof(short));
    printf("char:%ld\n",sizeof(char));
    printf("int8_t:%ld\n",sizeof(int8_t));
    printf("int16_t:%ld\n",sizeof(int16_t));
    printf("int32_t:%ld\n",sizeof(int32_t));
    printf("int64_t:%ld\n",sizeof(int64_t));
    printf("uint8_t:%ld\n",sizeof(uint8_t));
    printf("INT8_MAX:%dto%d\n",INT8_MIN,INT8_MAX);
    printf("INT16_MAX:%dto%d\n",INT16_MIN,INT16_MAX);
    printf("INT32_MAX:%dto%d\n",INT32_MIN,INT32_MAX);
    printf("INT64_MAX:%ldto%ld\n",INT64_MIN,INT64_MAX);
    printf("UINT8_MAX:%d\n",UINT8_MAX);
    printf("UINT16_MAX:%d\n",UINT16_MAX);
    printf("UINT32_MAX:%u\n",UINT32_MAX);
    printf("UINT64_MAX:%lu\n",UINT64_MAX);
    printf("\n");

    char ch2 = 2;
    short sh2 = 3;
    auto res1 = ch2 + sh2;
    printf("char(2) + short(3) = %d\n", res1);
    
    int i2 = 5;
    float f2 = 3.5f;
    auto res2 = i2 + f2;
    printf("int(5) + float(3.5) = %f\n", res2);
    
    float f3 = 10.0f;
    long double ld3 = 20.5L;
    auto res3 = f3 + ld3;
    printf("float(%f) + long double(%f) = %Lf\n",f3,ld3,res3);
    printf("\n");

    int num1 = 100;
    int num2 = 50;
    int unary_neg = -num1;
    int binary_sub = num1 - num2;
    printf("-%d(-num1) = %d(unary_neg)\n", num1, unary_neg, num1);
    printf("%d(num1) - %d(num2) = %d\n", num1, num2, binary_sub, num1, num2);
    printf("\n");
    
    int a = 10;
    int an = ++a;
    int b = 20;
    int bn = --b;
    printf("++10 → a=%d，an=%d\n", a, an);
    printf("--20 → b=%d，bn=%d\n", b, bn);
    printf("\n");
    
    int c = 10;
    int cn = c++;
    int d = 20;
    int dn = d--;
    printf("10++ → c=%d，cn=%d\n", c, cn);
    printf("20-- → d=%d，dn=%d\n", d, dn);
    printf("\n");

    int signed_i = -5;
    unsigned int unsigned_i = 3;
    unsigned int res4 = signed_i + unsigned_i;
    printf("signed int(-5) + unsigned int(3) = %u（unsigned int）\n", res4);
    printf("\n");
    return 0;
}
