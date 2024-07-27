/**
 * @project        : docs
 * @file           : inlink.cpp
 * @dir            : ~/projects/docs/Homework/Algorithms/oj
 * @date           : 2024/03/09
 * @author         : Kaikai
 * @brief          : 单向链表（递增排列）插入元素 翻转链表
 * */
#include <iostream>
using namespace std;

#define MAX_SIZE 100

/// @brief 单向链表
struct ListNode
{
    int val;
    ListNode *next;
    ListNode(int x) : val(x), next(nullptr) {}
};

/// @brief 创建单链表
/// @param 指定长度
ListNode *CreateList(int length)
{
    ListNode *head = new ListNode(-1); // 头结点的值可以设为任意值，这里设为-1
    ListNode *tail = head;
    for (int i = 1; i <= length; ++i)
    {
        ListNode *newNode = new ListNode(i * 10);
        tail->next = newNode;
        tail = newNode;
    }
    return head;
}

/// @brief 在带头结点的单链表中插入值为 val 的结点
/// @param head 头节点
/// @param val 值
/// @param inc 递增 True or 递减 False
void InsertNode(ListNode *head, int val, bool inc = true)
{
    ListNode *newNode = new ListNode(val);
    ListNode *p = head;
    while (p->next != nullptr && inc ? p->next->val < val : p->next->val > val)
    {
        p = p->next;
    }
    newNode->next = p->next;
    p->next = newNode;
}

ListNode *Reverse(ListNode *node)
{
    if (node->next == NULL) // 尾节点
    {
        return node;
    }
    ListNode *tail = Reverse(node->next);
    node->next->next = node;
    return tail;
}
/// @brief 反转链表
/// @param head 头节点，反转前后头节点不变
void ReverseList(ListNode *head)
{
    ListNode *tail = Reverse(head);
    head->next->next = NULL;
    head->next = tail;
}

void ReverseListWhile(ListNode *head)
{
    ListNode *prior = head;
    ListNode *curr = head->next;
    ListNode *next = head->next->next;
    while (next != nullptr)
    {
        curr->next = prior;
        prior = curr;
        curr = next;
        next = curr->next;
    }
    curr->next = prior;
    head->next->next = NULL;
    head->next = curr;
}

/// @brief 打印带头结点的单链表
/// @param head 头节点（值不参与打印）
void PrintList(ListNode *head)
{
    ListNode *p = head->next;
    while (p)
    {
        cout << p->val << " ";
        p = p->next;
    }
    cout << endl;
}

int main()
{
    int length = 10;
    ListNode *head = CreateList(length); // 创建带头结点的单链表
    int insert_data;
    cout << "Before Insert: ";
    PrintList(head); // 打印链表
    cout << "Data: ";
    cin >> insert_data; // 输入插入位置和被插入元素值
    cout << "After Insert: ";
    InsertNode(head, insert_data); // 插入结点
    PrintList(head);               // 打印链表
    cout << "After Reverse(Inter): ";
    ReverseList(head);
    PrintList(head);
    cout << "After Reverse(While): ";
    ReverseListWhile(head);
    PrintList(head);
    return 0;
}
