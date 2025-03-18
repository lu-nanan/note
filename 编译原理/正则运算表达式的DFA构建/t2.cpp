#include <iostream>
#include <vector>
#include <list>
#include <algorithm>

using namespace std;

// 枚举类型定义
enum DriverType { NULL_DRIVER, CHAR, CHARSET };
enum StateType { UNMATCH, MATCH };
enum LexemeCategory { ID, NUM, STR, OP }; // 示例词法类别，根据实际情况扩展

// 状态类定义
class State {
public:
    int stateId;
    StateType type;
    LexemeCategory category;
    
    State(int id, StateType t, LexemeCategory c = static_cast<LexemeCategory>(0))
        : stateId(id), type(t), category(c) {}
};

// 边类定义
class Edge {
public:
    int startState;
    int nextState;
    DriverType type;
    int driverId; // 当type为CHAR时存储字符，CHARSET时存储字符集ID
    
    Edge(int start, int next, DriverType t, int id)
        : startState(start), nextState(next), type(t), driverId(id) {}
};

// 图类定义
class Graph {
public:
    int graphId;
    int numOfStates;
    list<Edge*> *pEdgeTable;
    list<State*> *pStateTable;
    
    Graph() : numOfStates(0), pEdgeTable(new list<Edge*>()), pStateTable(new list<State*>()) {}
    
    ~Graph() {
        for (auto e : *pEdgeTable) delete e;
        for (auto s : *pStateTable) delete s;
        delete pEdgeTable;
        delete pStateTable;
    }
};

// 辅助函数声明
Graph* createNewGraph();
void addEdge(Graph* g, int start, int end, DriverType t, int id);
void addState(Graph* g, int id, StateType t, LexemeCategory c);
void mergeStates(Graph* dest, Graph* src, int offset, StateType newType);
void remapStates(Graph* g, int offset);

// 基本NFA生成
Graph* generateBasicNFA(DriverType driverType, int driverId) {
    Graph* nfa = createNewGraph();
    nfa->numOfStates = 2;
    
    // 添加边
    addEdge(nfa, 0, 1, driverType, driverId);
    
    // 添加结束状态（只有结束状态需要存储）
    addState(nfa, 1, MATCH, static_cast<LexemeCategory>(driverId));
    
    return nfa;
}

Graph* copyGraph(const Graph* src) {
    Graph* dest = createNewGraph();
    dest->numOfStates = src->numOfStates;
    
    // 复制边
    for (auto e : *src->pEdgeTable) {
        addEdge(dest, e->startState, e->nextState, e->type, e->driverId);
    }
    
    // 复制状态（仅MATCH状态）
    for (auto s : *src->pStateTable) {
        if (s->type == MATCH) {
            addState(dest, s->stateId, s->type, s->category);
        }
    }
    return dest;
}


Graph* unionNFA(Graph* pNFA1, Graph* pNFA2) {
    // 创建副本以避免修改原图
    Graph* copy1 = copyGraph(pNFA1);
    Graph* copy2 = copyGraph(pNFA2);
    
    Graph* newNFA = createNewGraph();
    const int offset1 = 1;
    const int offset2 = copy1->numOfStates + 1;
    
    newNFA->numOfStates = copy1->numOfStates + copy2->numOfStates + 2;
    
    // 添加新起始的ε边
    addEdge(newNFA, 0, offset1, NULL_DRIVER, 0);
    addEdge(newNFA, 0, offset2, NULL_DRIVER, 0);
    
    // 合并副本的边（需偏移）
    remapStates(copy1, offset1);
    remapStates(copy2, offset2);
    newNFA->pEdgeTable->splice(newNFA->pEdgeTable->end(), *copy1->pEdgeTable);
    newNFA->pEdgeTable->splice(newNFA->pEdgeTable->end(), *copy2->pEdgeTable);
    
    // 添加新结束状态
    const int newEnd = newNFA->numOfStates - 1;
    for (auto s : *copy1->pStateTable) {
        addEdge(newNFA, s->stateId, newEnd, NULL_DRIVER, 0);
    }
    for (auto s : *copy2->pStateTable) {
        addEdge(newNFA, s->stateId, newEnd, NULL_DRIVER, 0);
    }
    addState(newNFA, newEnd, MATCH, copy1->pStateTable->front()->category);
    
    delete copy1; delete copy2;  // 清理副本
    return newNFA;
}

Graph* product(Graph* pNFA1, Graph* pNFA2) {
    Graph* copy1 = copyGraph(pNFA1);
    Graph* copy2 = copyGraph(pNFA2);
    
    Graph* newNFA = createNewGraph();
    const int offset = copy1->numOfStates;
    newNFA->numOfStates = copy1->numOfStates + copy2->numOfStates;
    
    // 合并第一个子图（状态设为 UNMATCH）
    newNFA->pEdgeTable->splice(newNFA->pEdgeTable->end(), *copy1->pEdgeTable);
    mergeStates(newNFA, copy1, 0, UNMATCH);
    
    // 合并第二个子图（状态设为 MATCH）
    remapStates(copy2, offset);  // 偏移第二个子图的状态
    newNFA->pEdgeTable->splice(newNFA->pEdgeTable->end(), *copy2->pEdgeTable);
    mergeStates(newNFA, copy2, 0, MATCH);  // 注意offset改为0
    
    // 连接第一个子图的结束状态到第二个子图的起始状态
    for (auto s : *copy1->pStateTable) {
        if (s->type == MATCH) {
            addEdge(newNFA, s->stateId, offset, NULL_DRIVER, 0);  // 连接到第二个子图的起始（偏移后）
        }
    }
    
    delete copy1; delete copy2;
    return newNFA;
}

Graph* closure(Graph* pNFA) {
    Graph* newNFA = createNewGraph();
    const int offset = 1;
    newNFA->numOfStates = pNFA->numOfStates + 2;

    addEdge(newNFA, 0, offset, NULL_DRIVER, 0);
    addEdge(newNFA, 0, newNFA->numOfStates - 1, NULL_DRIVER, 0);

    remapStates(pNFA, offset);
    newNFA->pEdgeTable->splice(newNFA->pEdgeTable->end(), *pNFA->pEdgeTable);
    mergeStates(newNFA, pNFA, 0, UNMATCH); // offset改为0

    const int newEnd = newNFA->numOfStates - 1;
    for (auto s : *pNFA->pStateTable) {
        addEdge(newNFA, s->stateId, offset, NULL_DRIVER, 0);
        addEdge(newNFA, s->stateId, newEnd, NULL_DRIVER, 0);
    }

    addState(newNFA, newEnd, MATCH, pNFA->pStateTable->front()->category);
    return newNFA;
}

Graph* plusClosure(Graph* pNFA) {
    Graph* newNFA = createNewGraph();
    newNFA->numOfStates = pNFA->numOfStates + 1;
    
    addEdge(newNFA, 0, 1, NULL_DRIVER, 0);
    
    remapStates(pNFA, 1);
    newNFA->pEdgeTable->splice(newNFA->pEdgeTable->end(), *pNFA->pEdgeTable);
    mergeStates(newNFA, pNFA, 0, UNMATCH); // offset改为0
    
    const int newEnd = newNFA->numOfStates - 1;
    for (auto s : *pNFA->pStateTable) {
        addEdge(newNFA, s->stateId, 1, NULL_DRIVER, 0);
        addEdge(newNFA, s->stateId, newEnd, NULL_DRIVER, 0);
    }
    addState(newNFA, newEnd, MATCH, pNFA->pStateTable->front()->category);
    
    return newNFA;
}

Graph* zerOrOne(Graph* pNFA) {
    Graph* newNFA = createNewGraph();
    const int offset = 1;
    newNFA->numOfStates = pNFA->numOfStates + 2;

    addEdge(newNFA, 0, offset, NULL_DRIVER, 0);
    addEdge(newNFA, 0, newNFA->numOfStates - 1, NULL_DRIVER, 0);

    remapStates(pNFA, offset);
    newNFA->pEdgeTable->splice(newNFA->pEdgeTable->end(), *pNFA->pEdgeTable);
    mergeStates(newNFA, pNFA, 0, UNMATCH); // offset改为0

    const int newEnd = newNFA->numOfStates - 1;
    for (auto s : *pNFA->pStateTable) {
        addEdge(newNFA, s->stateId, newEnd, NULL_DRIVER, 0);
    }

    addState(newNFA, newEnd, MATCH, pNFA->pStateTable->front()->category);
    return newNFA;
}

// 辅助函数实现
Graph* createNewGraph() {
    static int graphId = 0;
    Graph* g = new Graph();
    g->graphId = graphId++;
    return g;
}

void addEdge(Graph* g, int start, int end, DriverType t, int id) {
    g->pEdgeTable->push_back(new Edge(start, end, t, id));
}

void addState(Graph* g, int id, StateType t, LexemeCategory c) {
    if (t == MATCH || c != static_cast<LexemeCategory>(0)) {
        g->pStateTable->push_back(new State(id, t, c));
    }
}

void remapStates(Graph* g, int offset) {
    for (auto& e : *g->pEdgeTable) {
        e->startState += offset;
        e->nextState += offset;
    }
    for (auto& s : *g->pStateTable) {
        s->stateId += offset;
    }
}

void mergeStates(Graph* dest, Graph* src, int offset, StateType newType) {
    for (auto s : *src->pStateTable) {
        addState(dest, s->stateId + offset, newType, s->category);
    }
}

void printGraph(Graph* g) {
    cout << "Graph " << g->graphId << " has " << g->numOfStates << " states." << endl;
    
    // 打印所有边
    cout << "Edges:" << endl;
    for (auto e : *g->pEdgeTable) {
        cout << "  " << e->startState << " -> " << e->nextState << " [";
        switch(e->type) {
            case NULL_DRIVER: cout << "ε"; break;
            case CHAR: cout << "CHAR '" << (char)e->driverId << "'"; break;
            case CHARSET: cout << "CHARSET " << e->driverId; break;
            default: cout << "UNKNOWN";
        }
        cout << "]" << endl;
    }
    
    // 打印所有匹配状态
    cout << "Match States:" << endl;
    for (auto s : *g->pStateTable) {
        if (s->type == MATCH) {
            cout << "  State " << s->stateId << " (Category: " << s->category << ")" << endl;
        }
    }
    cout << "------------------------" << endl;
}

// 测试函数
int main() {
    // 测试基础NFA（单个字符）
    cout << "==== Basic NFA (CHAR 'a') ====" << endl;
    Graph* basic = generateBasicNFA(CHAR, 'a');
    printGraph(basic);
    
    // 测试并运算
    cout << "\n==== Union of 'a' and 'b' ====" << endl;
    Graph* a = generateBasicNFA(CHAR, 'a');
    Graph* b = generateBasicNFA(CHAR, 'b');
    Graph* u = unionNFA(a, b);
    printGraph(u);
    
    // 测试连接运算
    cout << "\n==== Concatenation of 'a' and 'b' ====" << endl;
    Graph* a1 = generateBasicNFA(CHAR, 'a');
    Graph* b1 = generateBasicNFA(CHAR, 'b');
    Graph* p = product(a1, b1); // 注意：此处a和b已被合并到u中，可能需要新建实例
    printGraph(p);
    
    // 测试正闭包
    cout << "\n==== Plus Closure of 'a' ====" << endl;
    Graph* a_plus = plusClosure(generateBasicNFA(CHAR, 'a'));
    printGraph(a_plus);
    
    // 测试Kleene闭包
    cout << "\n==== Kleene Closure of 'a' ====" << endl;
    Graph* a_star = closure(generateBasicNFA(CHAR, 'a'));
    printGraph(a_star);
    
    // 测试零或一
    cout << "\n==== Zero or One of 'a' ====" << endl;
    Graph* a_optional = zerOrOne(generateBasicNFA(CHAR, 'a'));
    printGraph(a_optional);
        
    return 0;
}