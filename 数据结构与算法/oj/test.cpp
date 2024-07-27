#include <iostream>
using namespace std;

#define MAX_SIZE 100

typedef int Elemtype;
typedef struct
{
    Elemtype elem[MAX_SIZE];
    int length;
} Sqlist;

void ListReverse(Sqlist &l)
{
    for (int i = 0; i < l.length / 2; i++)
    {
        Elemtype temp = l.elem[i];
        l.elem[i] = l.elem[l.length - i - 1];
        l.elem[l.length - i - 1] = temp;
    }
}

int main()
{
    Sqlist list;
    list.length = 5;
    for (int i = 0; i < list.length; i++)
    {
        list.elem[i] = i + 1;
    }

    cout << "Original list: ";
    for (int i = 0; i < list.length; i++)
    {
        cout << list.elem[i] << " ";
    }
    cout << endl;

    ListReverse(list);

    cout << "Reversed list: ";
    for (int i = 0; i < list.length; i++)
    {
        cout << list.elem[i] << " ";
    }
    cout << endl;

    return 0;
}
