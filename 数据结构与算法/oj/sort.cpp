#include <iostream>
#include <vector>
using namespace std;

/* 合并左子数组和右子数组 */
void merge(vector<pair<string, int>> &nums, int left, int mid, int right)
{
    // 左子数组区间为 [left, mid], 右子数组区间为 [mid+1, right]
    // 创建一个临时数组 tmp ，用于存放合并后的结果
    vector<pair<string, int>> tmp(right - left + 1);
    // 初始化左子数组和右子数组的起始索引
    int i = left, j = mid + 1, k = 0;
    // 当左右子数组都还有元素时，进行比较并将较小的元素复制到临时数组中
    while (i <= mid && j <= right)
    {
        if (nums[i].second <= nums[j].second)
            tmp[k++] = nums[i++];
        else
            tmp[k++] = nums[j++];
    }
    // 将左子数组和右子数组的剩余元素复制到临时数组中
    while (i <= mid)
    {
        tmp[k++] = nums[i++];
    }
    while (j <= right)
    {
        tmp[k++] = nums[j++];
    }
    // 将临时数组 tmp 中的元素复制回原数组 nums 的对应区间
    for (k = 0; k < tmp.size(); k++)
    {
        nums[left + k] = tmp[k];
    }
}

/* 归并排序 */
void mergeSort(vector<pair<string, int>> &nums, int left, int right)
{
    // 终止条件
    if (left >= right)
        return; // 当子数组长度为 1 时终止递归
    // 划分阶段
    int mid = (left + right) / 2;    // 计算中点
    mergeSort(nums, left, mid);      // 递归左子数组
    mergeSort(nums, mid + 1, right); // 递归右子数组
    // 合并阶段
    merge(nums, left, mid, right);
}

/* 选取三个候选元素的中位数 */
int medianThree(vector<pair<string, int>> &nums, int left, int mid, int right)
{
    int l = nums[left].second, m = nums[mid].second, r = nums[right].second;
    if ((l <= m && m <= r) || (r <= m && m <= l))
        return mid; // m 在 l 和 r 之间
    if ((m <= l && l <= r) || (r <= l && l <= m))
        return left; // l 在 m 和 r 之间
    return right;
}

/* 元素交换 */
void swap(vector<pair<string, int>> &nums, int i, int j)
{
    pair<string, int> tmp = nums[i];
    nums[i] = nums[j];
    nums[j] = tmp;
}

/* 哨兵划分（三数取中值） */
int partition(vector<pair<string, int>> &nums, int left, int right)
{
    // 选取三个候选元素的中位数
    int med = medianThree(nums, left, (left + right) / 2, right);
    // 将中位数交换至数组最左端
    swap(nums, left, med);
    // 以 nums[left] 为基准数
    int i = left, j = right;
    while (i < j)
    {
        while (i < j && nums[j].second >= nums[left].second)
            j--; // 从右向左找首个小于基准数的元素
        while (i < j && nums[i].second <= nums[left].second)
            i++;          // 从左向右找首个大于基准数的元素
        swap(nums, i, j); // 交换这两个元素
    }
    swap(nums, i, left); // 将基准数交换至两子数组的分界线
    return i;            // 返回基准数的索引
}

/* 快速排序（尾递归优化） */
void quickSort(vector<pair<string, int>> &nums, int left, int right)
{
    // 子数组长度为 1 时终止
    while (left < right)
    {
        // 哨兵划分操作
        int pivot = partition(nums, left, right);
        // 对两个子数组中较短的那个执行快速排序
        if (pivot - left < right - pivot)
        {
            quickSort(nums, left, pivot - 1); // 递归排序左子数组
            left = pivot + 1;                 // 剩余未排序区间为 [pivot + 1, right]
        }
        else
        {
            quickSort(nums, pivot + 1, right); // 递归排序右子数组
            right = pivot - 1;                 // 剩余未排序区间为 [left, pivot - 1]
        }
    }
}

/**
 * 学生成绩排序
 * 输入为长度为 50 的由学号和成绩组成的数组，按照成绩从高到低排序
 * 打印排序后的学号和成绩，每行 10 个学生
 */
int main()
{
    // 输入学生学号和成绩
    // clang-format off
    vector<pair<string, int>> students = {
        {"21009100001", 90}, {"21009100002", 85}, {"21009100003", 88}, {"21009100004", 92}, {"21009100005", 87},
        {"21009100006", 95}, {"21009100007", 78}, {"21009100008", 82}, {"21009100009", 85}, {"21009100010", 91},
        {"21009100011", 89}, {"21009100012", 93}, {"21009100013", 84}, {"21009100014", 87}, {"21009100015", 90},
        {"21009100016", 92}, {"21009100017", 95}, {"21009100018", 78}, {"21009100019", 82}, {"21009100020", 85},
        {"21009100021", 89}, {"21009100022", 93}, {"21009100023", 84}, {"21009100024", 87}, {"21009100025", 90},
        {"21009100026", 92}, {"21009100027", 95}, {"21009100028", 78}, {"21009100029", 82}, {"21009100030", 85},
        {"21009100031", 89}, {"21009100032", 93}, {"21009100033", 84}, {"21009100034", 87}, {"21009100035", 90},
        {"21009100036", 92}, {"21009100037", 95}, {"21009100038", 78}, {"21009100039", 82}, {"21009100040", 85},
        {"21009100041", 89}, {"21009100042", 93}, {"21009100043", 84}, {"21009100044", 87}, {"21009100045", 90},
        {"21009100046", 92}, {"21009100047", 99}, {"21009100048", 78}, {"21009100049", 82}, {"21009100050", 85}
    };
    // students 用于 快速排序 students_copy 用于 归并排序
    vector<pair<string, int>> students_copy = students;

    // clang-format on

    // 快速排序
    cout << "Quick Sort:";
    cout << endl;
    // 将学生按照成绩从低到高排序
    quickSort(students, 0, students.size() - 1);
    // 打印从高到低排序后的学号和成绩
    for (int i = students.size() - 1; i >= 0; i--)
    {
        cout << students[i].first << " " << students[i].second << " ";
        if ((students.size() - i) % 10 == 0)
            cout << endl;
    }

    // 归并排序
    cout << endl;
    cout << "Merge Sort:";
    cout << endl;
    // 将学生按照成绩从低到高排序
    mergeSort(students_copy, 0, students_copy.size() - 1);
    // 打印从高到低排序后的学号和成绩
    for (int i = students_copy.size() - 1; i >= 0; i--)
    {
        cout << students_copy[i].first << " " << students_copy[i].second << " ";
        if ((students_copy.size() - i) % 10 == 0)
            cout << endl;
    }
    return 0;
}