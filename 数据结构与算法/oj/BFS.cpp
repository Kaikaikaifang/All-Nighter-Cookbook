#include <iostream>
#include <vector>
#include <queue>
using namespace std;

void bfs(vector<vector<int>> &graph, vector<bool> &visited, int node)
{
    queue<int> q;
    q.push(node);
    visited[node] = true;

    while (!q.empty())
    {
        int curr = q.front();
        q.pop();

        for (int neighbor : graph[curr])
        {
            if (!visited[neighbor])
            {
                q.push(neighbor);
                visited[neighbor] = true;
            }
        }
    }
}

bool isConnected(vector<vector<int>> &graph)
{
    int n = graph.size();
    vector<bool> visited(n, false);

    bfs(graph, visited, 0);

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