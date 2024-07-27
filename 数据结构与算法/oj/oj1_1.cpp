/**
 * @project        : docs
 * @file           : oj1_1.cpp
 * @dir            : ~/projects/docs/Homework/Algorithms/oj
 * @date           : 2024/03/10
 * @author         : Kaikai
 * @brief          : 顺序结构
 * */

#include <vector>
#include <algorithm>
#include <iostream>

using namespace std;

std::vector<int> removeCommonElements(std::vector<int> &A, std::vector<int> &B, std::vector<int> &C)
{
    std::vector<int> result;
    for (int i = 0; i < A.size(); i++)
    {
        if (!std::binary_search(B.begin(), B.end(), A[i]) || !std::binary_search(C.begin(), C.end(), A[i]))
        {
            result.push_back(A[i]);
        }
    }
    return result;
}

vector<int> joinVectors(vector<int> &A, vector<int> &B)
{
    vector<int> result;
    int length = A.size() + B.size();
    int ptr_A = A.size() - 1;
    int ptr_B = B.size() - 1;
    for (int i = 0; i < length; i++)
    {
        if (ptr_B < 0 || (ptr_A >= 0 && A[ptr_A] > B[ptr_B]))
        {
            result.push_back(A[ptr_A]);
            ptr_A--;
        }
        else
        {
            result.push_back(B[ptr_B]);
            ptr_B--;
        }
    }
    return result;
}

int main()
{
    // 顺序结构测试
    std::vector<int> A = {1, 2, 3, 4, 5};
    std::vector<int> B = {2, 4};
    std::vector<int> C = {2, 5};
    std::vector<int> result = removeCommonElements(A, B, C);
    std::cout << std::endl;
    result = joinVectors(A, B);
    for (int i : result)
    {
        std::cout << i << " ";
    }
    return 0;
}
