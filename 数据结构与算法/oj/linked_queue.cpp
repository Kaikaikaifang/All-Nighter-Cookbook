#include <iostream>
using namespace std;

class LinkedQueue {
private:
    struct Node {
        int data;
        Node* next;
        Node(int data) : data(data), next(nullptr) {}
    };

    Node* rear;  // 队尾指针

public:
    LinkedQueue() {
        // 初始化带头节点的循环链表
        rear = new Node(0);
        rear->next = rear;
    }

    ~LinkedQueue() {
        while (!isEmpty()) {
            dequeue();
        }
        delete rear;
    }

    bool isEmpty() {
        return rear->next == rear;
    }

    void enqueue(int value) {
        Node* newNode = new Node(value);
        newNode->next = rear->next;
        rear->next = newNode;
        rear = newNode;
    }

    int dequeue() {
        if (isEmpty())
            throw std::underflow_error("Queue is empty");
        Node* front = rear->next->next;
        int value = front->data;
        rear->next->next = front->next;
        if (front == rear) {  // 如果队列只有一个元素
            rear = rear->next;
        }
        delete front;
        return value;
    }
};

int main() {
    LinkedQueue lq; // 创建一个队列

    // 入队
    lq.enqueue(1);
    lq.enqueue(2);
    lq.enqueue(3);

    // 出队
    std::cout << "Dequeue: " << lq.dequeue() << std::endl; // 应该输出 1
    std::cout << "Dequeue: " << lq.dequeue() << std::endl; // 应该输出 2

    // 检查队列是否为空
    std::cout << "Is queue empty? " << (lq.isEmpty() ? "Yes" : "No") << std::endl; // 应该输出 No

    // 继续出队
    std::cout << "Dequeue: " << lq.dequeue() << std::endl; // 应该输出 3

    // 再次检查队列是否为空
    std::cout << "Is queue empty? " << (lq.isEmpty() ? "Yes" : "No") << std::endl; // 应该输出 Yes

    return 0;
}