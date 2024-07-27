#include <iostream>
#include <vector>
#include <string>
using namespace std;

class Undergraduate
{
public:
    string name;
    string class_name;

    Undergraduate(string n, string c) : name(n), class_name(c) {}
};

class Graduate
{
public:
    string name;
    string class_name;
    vector<Undergraduate> undergraduates;

    Graduate(string n, string c) : name(n), class_name(c) {}

    void addUndergraduate(Undergraduate u)
    {
        undergraduates.push_back(u);
    }
};

class Teacher
{
public:
    string name;
    string title;
    vector<Graduate> graduates;
    vector<Undergraduate> directUndergraduates;

    Teacher(string n, string t) : name(n), title(t) {}

    void addGraduate(Graduate g)
    {
        graduates.push_back(g);
    }

    void addUndergraduate(Undergraduate u)
    {
        directUndergraduates.push_back(u);
    }
};

void countStudents(Teacher teacher)
{
    int numGraduates = teacher.graduates.size();
    int numUndergraduates = teacher.directUndergraduates.size();

    // 统计每个研究生带的本科生
    for (const auto &grad : teacher.graduates)
    {
        numUndergraduates += grad.undergraduates.size();
    }

    cout << "Teacher: " << teacher.name << endl;
    cout << "Title: " << teacher.title << endl;
    cout << "Number of Graduates: " << numGraduates << endl;
    cout << "Number of Undergraduates: " << numUndergraduates << endl;
}

int main()
{
    // 创建示例数据
    // 1. 导师带研究生
    Teacher teacher("Dr. Smith", "Professor");

    Graduate grad1("Alice", "CS2021");
    grad1.addUndergraduate(Undergraduate("Bob", "CS2023"));
    grad1.addUndergraduate(Undergraduate("Charlie", "CS2023"));

    Graduate grad2("David", "CS2022");
    grad2.addUndergraduate(Undergraduate("Eve", "CS2023"));

    teacher.addGraduate(grad1);
    teacher.addGraduate(grad2);
    teacher.addUndergraduate(Undergraduate("Fiona", "CS2023"));

    // 计算并显示统计结果
    countStudents(teacher);

    // 2. 导师不带研究生
    Teacher teacher2("Dr. Brown", "Associate Professor");
    teacher2.addUndergraduate(Undergraduate("Grace", "CS2023"));
    teacher2.addUndergraduate(Undergraduate("Henry", "CS2023"));

    countStudents(teacher2);
    return 0;
}