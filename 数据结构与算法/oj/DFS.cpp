#include <iostream>
#include <vector>
using namespace std;

void dfs(vector<vector<int>> &graph, vector<bool> &visited, int node)
{
    visited[node] = true;
    for (int neighbor : graph[node])
    {
        if (!visited[neighbor])
        {
            dfs(graph, visited, neighbor);
        }
    }
}

bool isConnected(vector<vector<int>> &graph)
{
    int n = graph.size();
    vector<bool> visited(n, false);

    dfs(graph, visited, 0);

    for (bool v : visited)
    {
        if (!v)
        {
            return false;
        }
    }
    return true;
}

int main()
{
    // 测试案例 1: 连通图
    vector<vector<int>> graph1 = {
        {1, 2},
        {0, 2},
        {0, 1, 3},
        {2}};
    cout << "测试案例 1: " << (isConnected(graph1) ? "连通" : "不连通") << endl;

    // 测试案例 2: 不连通图
    vector<vector<int>> graph2 = {
        {1, 2},
        {0, 2},
        {0, 1},
        {4},
        {3}};
    cout << "测试案例 2: " << (isConnected(graph2) ? "连通" : "不连通") << endl;

    return 0;
}