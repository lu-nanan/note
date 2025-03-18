#include <algorithm>
#include <vector>
#include <list>
#include <cassert>
#include <iostream>

using namespace std;

// 假设CharSet和相关的表已经定义如下：
class CharSet {
public:
    int indexId;
    int segmentId;
    char fromChar;
    char toChar;
};

list<CharSet*> *pCharSetTable; // 全局字符集表
int nextCharSetId = 1; // 假设初始ID从1开始

struct Segment {
    char from;
    char to;
    Segment(char f, char t) : from(f), to(t) {}
};

// 辅助函数：合并段
vector<Segment> mergeSegments(vector<Segment>& segments) {
    if (segments.empty()) return {};
    
    // 按from排序，若from相同则按to排序
    sort(segments.begin(), segments.end(), [](const Segment& a, const Segment& b) {
        if (a.from != b.from) return a.from < b.from;
        return a.to < b.to;
    });
    
    vector<Segment> merged;
    merged.push_back(segments[0]);
    
    for (size_t i = 1; i < segments.size(); ++i) {
        Segment& last = merged.back();
        Segment current = segments[i];
        
        if (current.from <= last.to + 1) {
            // 合并相邻或重叠的段
            last.to = max(last.to, current.to);
        } else {
            merged.push_back(current);
        }
    }
    
    return merged;
}

// 范围运算
int range(char fromChar, char toChar) {
    if (fromChar > toChar) swap(fromChar, toChar);
    
    int newId = nextCharSetId++;
    CharSet* cs = new CharSet{newId, 0, fromChar, toChar};
    pCharSetTable->push_back(cs);
    return newId;
}

// 字符的并运算
int union_op(char c1, char c2) {
    vector<Segment> segments;
    segments.emplace_back(min(c1, c2), min(c1, c2));
    segments.emplace_back(max(c1, c2), max(c1, c2));
    
    vector<Segment> merged = mergeSegments(segments);
    
    int newId = nextCharSetId++;
    for (size_t i = 0; i < merged.size(); ++i) {
        CharSet* cs = new CharSet{newId, static_cast<int>(i), merged[i].from, merged[i].to};
        pCharSetTable->push_back(cs);
    }
    return newId;
}

// 字符集与字符的并运算
int union_op(int charSetId, char c) {
    vector<Segment> segments;
    for (auto cs : *pCharSetTable) {
        if (cs->indexId == charSetId)
            segments.emplace_back(cs->fromChar, cs->toChar);
    }
    segments.emplace_back(c, c);
    
    vector<Segment> merged = mergeSegments(segments);
    
    int newId = nextCharSetId++;
    for (size_t i = 0; i < merged.size(); ++i) {
        CharSet* cs = new CharSet{newId, static_cast<int>(i), merged[i].from, merged[i].to};
        pCharSetTable->push_back(cs);
    }
    return newId;
}

// 字符集之间的并运算
int union_op(int charSetId1, int charSetId2) {
    vector<Segment> segments;
    for (auto cs : *pCharSetTable) {
        if (cs->indexId == charSetId1 || cs->indexId == charSetId2)
            segments.emplace_back(cs->fromChar, cs->toChar);
    }
    
    vector<Segment> merged = mergeSegments(segments);
    
    int newId = nextCharSetId++;
    for (size_t i = 0; i < merged.size(); ++i) {
        CharSet* cs = new CharSet{newId, static_cast<int>(i), merged[i].from, merged[i].to};
        pCharSetTable->push_back(cs);
    }
    return newId;
}

// 字符集与字符的差运算
int difference(int charSetId, char c) {
    vector<Segment> oldSegments;
    for (auto cs : *pCharSetTable) {
        if (cs->indexId == charSetId)
            oldSegments.emplace_back(cs->fromChar, cs->toChar);
    }
    
    vector<Segment> newSegments;
    for (auto seg : oldSegments) {
        if (seg.to < c || seg.from > c) {
            newSegments.push_back(seg);
        } else {
            if (seg.from < c)
                newSegments.emplace_back(seg.from, c - 1);
            if (seg.to > c)
                newSegments.emplace_back(c + 1, seg.to);
        }
    }
    
    vector<Segment> merged = mergeSegments(newSegments);
    
    int newId = nextCharSetId++;
    for (size_t i = 0; i < merged.size(); ++i) {
        CharSet* cs = new CharSet{newId, static_cast<int>(i), merged[i].from, merged[i].to};
        pCharSetTable->push_back(cs);
    }
    return newId;
}


// 辅助函数：获取指定字符集的所有段，按segmentId排序
vector<Segment> getSegments(int charSetId) {
    vector<Segment> segments;
    for (auto cs : *pCharSetTable) {
        if (cs->indexId == charSetId) {
            segments.emplace_back(cs->fromChar, cs->toChar);
        }
    }
    // 按segmentId排序以确保顺序
    sort(segments.begin(), segments.end(), [](const Segment& a, const Segment& b) {
        return a.from < b.from; // 按起始字符排序即可
    });
    return segments;
}

// 重置全局状态
void resetTestEnv() {
    // 释放内存
    for (auto cs : *pCharSetTable) delete cs;
    pCharSetTable->clear();
    nextCharSetId = 1; // 重置ID生成器
}

// 测试范围运算
void testRange() {
    resetTestEnv();
    int id = range('a', 'c');
    auto seg = getSegments(id);
    assert(seg.size() == 1);
    assert(seg[0].from == 'a' && seg[0].to == 'c');
    cout << "testRange passed." << endl;
}

// 测试字符的并运算（相邻字符）
void testUnionCharAdjacent() {
    resetTestEnv();
    int id = union_op('a', 'b');
    auto seg = getSegments(id);
    assert(seg.size() == 1);
    assert(seg[0].from == 'a' && seg[0].to == 'b');
    cout << "testUnionCharAdjacent passed." << endl;
}

// 测试字符的并运算（不相邻字符）
void testUnionCharDisjoint() {
    resetTestEnv();
    int id = union_op('a', 'c');
    auto seg = getSegments(id);
    assert(seg.size() == 2);
    assert(seg[0].from == 'a' && seg[0].to == 'a');
    assert(seg[1].from == 'c' && seg[1].to == 'c');
    cout << "testUnionCharDisjoint passed." << endl;
}

// 测试字符集与字符的并运算（扩展范围）
void testUnionCharSetAndChar() {
    resetTestEnv();
    int baseId = range('a', 'c');   // [a-c]
    int newId = union_op(baseId, 'd'); // 合并后应为[a-d]
    auto seg = getSegments(newId);
    assert(seg.size() == 1);
    assert(seg[0].from == 'a' && seg[0].to == 'd');
    cout << "testUnionCharSetAndChar passed." << endl;
}

// 测试字符集之间的并运算（重叠范围）
void testUnionCharSetsOverlap() {
    resetTestEnv();
    int id1 = range('a', 'c');  // [a-c]
    int id2 = range('b', 'd');  // [b-d]
    int mergedId = union_op(id1, id2); // 合并后应为[a-d]
    auto seg = getSegments(mergedId);
    assert(seg.size() == 1);
    assert(seg[0].from == 'a' && seg[0].to == 'd');
    cout << "testUnionCharSetsOverlap passed." << endl;
}

// 测试字符集差运算（减去中间字符）
void testDifference() {
    resetTestEnv();
    int baseId = range('a', 'z');   // [a-z]
    int newId = difference(baseId, 'i'); // 应分割为 [a-h] 和 [j-z]
    auto seg = getSegments(newId);
    assert(seg.size() == 2);
    assert(seg[0].from == 'a' && seg[0].to == 'h');
    assert(seg[1].from == 'j' && seg[1].to == 'z');
    cout << "testDifference passed." << endl;
}

int main() {
    // 初始化全局字符集表
    pCharSetTable = new list<CharSet*>();
    
    // 执行测试用例
    testRange();
    testUnionCharAdjacent();
    testUnionCharDisjoint();
    testUnionCharSetAndChar();
    testUnionCharSetsOverlap();
    testDifference();
    
    // 清理内存
    resetTestEnv();
    delete pCharSetTable;
    return 0;
}