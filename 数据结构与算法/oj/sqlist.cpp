/**
 * @project        : docs
 * @file           : sqlist.cpp
 * @dir            : ~/projects/docs/Homework/Algorithms/oj
 * @date           : 2024/03/09
 * @author         : Kaikai
 * @brief          : 线性表逆置算法
 * */

#include <iostream>
using namespace std;

#define MAX_SIZE 100

/// @brief 线性表数据结构
typedef int Elemtype;
typedef struct
{
    Elemtype elem[MAX_SIZE];
    int length;
} Sqlist;

/// @brief 线性表逆置算法
/// @param l 线性表
/// @details 中间为界，前后交换
void ListReverse(Sqlist &l)
{
    for (int i = 0; i < l.length / 2; i++)
    {
        Elemtype temp = l.elem[i];
        l.elem[i] = l.elem[l.length - i - 1];
        l.elem[l.length - i - 1] = temp;
    }
}

/// @brief 入口
/// @return 0
int main()
{
    // 构造线性表
    Sqlist list;
    list.length = 5;
    for (int i = 0; i < list.length; i++)
    {
        list.elem[i] = i + 1;
    }

    // 打印原线性表
    cout << "Original list: ";
    for (int i = 0; i < list.length; i++)
    {
        cout << list.elem[i] << " ";
    }
    cout << endl;

    // 线性表逆置
    ListReverse(list);

    // 打印逆置后线性表
    cout << "Reversed list: ";
    for (int i = 0; i < list.length; i++)
    {
        cout << list.elem[i] << " ";
    }
    cout << endl;

    return 0;
}
