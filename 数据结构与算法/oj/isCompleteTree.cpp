#include <iostream>
#include <queue>
using namespace std;

struct TreeNode
{
    int val;
    TreeNode *left;
    TreeNode *right;
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

bool isCompleteTree(TreeNode *root)
{
    if (!root)
        return true; // 空树被视为完全二叉树

    queue<TreeNode *> q;
    q.push(root);
    bool end = false; // 标记是否遇到了第一个空节点

    while (!q.empty())
    {
        TreeNode *current = q.front();
        q.pop();

        if (current)
        {
            if (end)
                return false; // 如果已经遇到空节点，但是仍然发现非空节点，则不是完全二叉树
            q.push(current->left);
            q.push(current->right);
        }
        else
        {
            end = true; // 遇到第一个空节点
        }
    }

    return true;
}

void testIsCompleteTree()
{
    // 创建测试用例 1: 完全二叉树
    TreeNode *root1 = new TreeNode(1);
    root1->left = new TreeNode(2);
    root1->right = new TreeNode(3);
    root1->left->left = new TreeNode(4);
    root1->left->right = new TreeNode(5);
    root1->right->left = new TreeNode(6);

    // 测试用例 2: 非完全二叉树
    TreeNode *root2 = new TreeNode(1);
    root2->left = new TreeNode(2);
    root2->right = new TreeNode(3);
    root2->left->left = new TreeNode(4);
    root2->right->right = new TreeNode(6); // 缺失右子树的左孩子

    cout << "Test Case 1 - Expected: True, Got: " << (isCompleteTree(root1) ? "True" : "False") << endl;
    cout << "Test Case 2 - Expected: False, Got: " << (isCompleteTree(root2) ? "True" : "False") << endl;

    // 清理内存
    delete root1->left->left;
    delete root1->left->right;
    delete root1->right->left;
    delete root1->left;
    delete root1->right;
    delete root1;

    delete root2->left->left;
    delete root2->right->right;
    delete root2->left;
    delete root2->right;
    delete root2;
}

int main()
{
    testIsCompleteTree();
    return 0;
}