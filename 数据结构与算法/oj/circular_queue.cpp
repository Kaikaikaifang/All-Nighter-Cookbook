#include <iostream>
using namespace std;

class CircularQueue {
private:
    int m;       // 数组长度
    int rear;    // 队尾指针
    int quelen;  // 队列当前长度
    int* arr;    // 存储队列元素的数组

public:
    CircularQueue(int size) : m(size), rear(0), quelen(0) {
        arr = new int[m];
    }

    ~CircularQueue() {
        delete[] arr;
    }

    bool isFull() {
        return quelen == m;
    }

    bool isEmpty() {
        return quelen == 0;
    }

    void enqueue(int value) {
        if (isFull())
            throw std::overflow_error("Queue is full");
        arr[rear] = value;
        rear = (rear + 1) % m;
        ++quelen;
    }

    int dequeue() {
        if (isEmpty())
            throw std::underflow_error("Queue is empty");
        int front = (rear - quelen + m) % m;  // 计算队头指针
        int value = arr[front];
        quelen--;
        return value;
    }
};

int main() {
    CircularQueue cq(5); // 创建一个大小为5的循环队列

    // 入队
    cq.enqueue(1);
    cq.enqueue(2);
    cq.enqueue(3);
    cq.enqueue(4);
    cq.enqueue(5);

    // 出队
    std::cout << "Dequeue: " << cq.dequeue() << std::endl; // 应该输出 1
    std::cout << "Dequeue: " << cq.dequeue() << std::endl; // 应该输出 2

    // 再次入队
    cq.enqueue(6);
    cq.enqueue(7);
    
    std::cout << "Is queue full? " << (cq.isFull() ? "Yes" : "No") << std::endl; // 应该输出 "Yes
    // 继续出队
    while (!cq.isEmpty()) {
        std::cout << "Dequeue: " << cq.dequeue() << std::endl;  // 应该输出 3 4 5 6 7
    }

    return 0;
}