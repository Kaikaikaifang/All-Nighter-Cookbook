/**
 * @project        : docs
 * @file           : oj1_2.cpp
 * @dir            : ~/projects/docs/Homework/Algorithms/oj
 * @date           : 2024/03/10
 * @author         : Kaikai
 * @brief          : 链式结构
 * */

#include <iostream>

struct Node
{
    int data;
    Node *next;
};

bool find(Node *head, int val)
{
    Node *current = head;
    while (current)
    {
        if (current->data == val)
        {
            return true;
        }
        current = current->next;
    }
    return false;
}

Node *removeCommonElements(Node *A, Node *B, Node *C)
{
    Node dummy;
    Node *tail = &dummy;
    while (A)
    {
        if (!find(B, A->data) || !find(C, A->data))
        {
            tail->next = new Node{A->data, nullptr};
            tail = tail->next;
        }
        A = A->next;
    }
    return dummy.next;
}

void ReverseListWhile(Node *head)
{
    Node *prior = head;
    Node *curr = head->next;
    Node *next = head->next->next;
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

Node *joinLinks(Node *A, Node *B)
{
    Node *result = new Node{-1, nullptr};
    Node *tail = result;
    Node *head_A = new Node{-1, A};
    Node *head_B = new Node{-1, B};
    ReverseListWhile(head_A);
    ReverseListWhile(head_B);
    while (head_A->next || head_B->next)
    {
        if (!head_B->next || (head_A->next && head_A->next->data > head_B->next->data))
        {
            tail->next = new Node{head_A->next->data, nullptr};
            head_A = head_A->next;
        }
        else
        {
            tail->next = new Node{head_B->next->data, nullptr};
            head_B = head_B->next;
        }
        tail = tail->next;
    }
    return result->next;
}

int main()
{
    // 链式结构测试
    Node *A = new Node{1, new Node{2, new Node{3, new Node{4, new Node{5, nullptr}}}}};
    Node *B = new Node{2, new Node{4, new Node{5, nullptr}}};
    Node *C = new Node{3, new Node{5, nullptr}};
    Node *result = removeCommonElements(A, B, C);
    result = joinLinks(A, B);
    while (result)
    {
        std::cout << result->data << " ";
        result = result->next;
    }
    std::cout << std::endl;

    return 0;
}
