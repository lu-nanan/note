#include <set>
#include <queue>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <list>
#include <algorithm>
#include <map>
using namespace std;

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

// 新增深拷贝函数
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

// 辅助函数：对 vector 进行排序和去重
vector<int> normalize(vector<int> v) {
    sort(v.begin(), v.end());
    v.erase(unique(v.begin(), v.end()), v.end());
    return v;
}

// ε-closure 实现
vector<int> epsilon_closure(const Graph* nfa, const vector<int>& states) {
    vector<int> closure = normalize(states);
    queue<int> q;
    for (int s : closure) q.push(s);

    while (!q.empty()) {
        int current = q.front();
        q.pop();

        for (Edge* edge : *nfa->pEdgeTable) {
            if (edge->startState == current && edge->type == NULL_DRIVER) {
                if (!binary_search(closure.begin(), closure.end(), edge->nextState)) {
                    closure.push_back(edge->nextState);
                    closure = normalize(closure); // 保持有序且唯一
                    q.push(edge->nextState);
                }
            }
        }
    }
    return closure;
}

// Move 实现
vector<int> move(const Graph* nfa, const vector<int>& states, char c) {
    vector<int> result;
    for (int s : states) {
        for (Edge* edge : *nfa->pEdgeTable) {
            if (edge->startState == s && edge->type == CHAR && (char)edge->driverId == c) {
                result.push_back(edge->nextState);
            }
        }
    }
    return normalize(result);
}

// Dtran 实现
vector<int> DTran(const Graph* nfa, const vector<int>& T, char a) {
    vector<int> moved = move(nfa, T, a);
    return epsilon_closure(nfa, moved);
}

// NFA 转 DFA 实现
// Graph* NFA_to_DFA(Graph* pNFA) {
//     Graph* dfa = createNewGraph();
    
//     // 收集字母表（使用 vector + 手动去重）
//     vector<char> alphabet;
//     for (Edge* e : *pNFA->pEdgeTable) {
//         if (e->type == CHAR) {
//             char c = (char)e->driverId;
//             if (find(alphabet.begin(), alphabet.end(), c) == alphabet.end()) {
//                 alphabet.push_back(c);
//             }
//         }
//     }

//     map<vector<int>, int> stateMap;
//     int stateId = 0;
//     queue<vector<int>> processQueue;

//     // 初始状态处理
//     vector<int> startSet = epsilon_closure(pNFA, {0});
//     startSet = normalize(startSet);
    
//     stateMap[startSet] = stateId++;
//     processQueue.push(startSet);
//     dfa->numOfStates = 1;

//     // 检查初始接受状态
//     bool isAccept = false;
//     LexemeCategory cat;
//     for (int s : startSet) {
//         for (State* state : *pNFA->pStateTable) {
//             if (state->stateId == s && state->type == MATCH) {
//                 isAccept = true;
//                 cat = state->category;
//                 break;
//             }
//         }
//         if (isAccept) break;
//     }
//     addState(dfa, 0, isAccept ? MATCH : UNMATCH, isAccept ? cat : ID);

//     // 主处理循环
//     while (!processQueue.empty()) {
//         vector<int> current = processQueue.front();
//         processQueue.pop();
//         int currentId = stateMap[current];

//         for (char c : alphabet) {
//             vector<int> newState = DTran(pNFA, current, c);
//             if (newState.empty()) continue;

//             newState = normalize(newState); // 确保状态唯一性

//             if (stateMap.find(newState) == stateMap.end()) {
//                 stateMap[newState] = stateId++;
//                 processQueue.push(newState);
//                 dfa->numOfStates++;

//                 // 检查接受状态
//                 bool accept = false;
//                 LexemeCategory newCat;
//                 for (int s : newState) {
//                     for (State* state : *pNFA->pStateTable) {
//                         if (state->stateId == s && state->type == MATCH) {
//                             accept = true;
//                             newCat = state->category;
//                             break;
//                         }
//                     }
//                     if (accept) break;
//                 }
//                 addState(dfa, stateMap[newState], accept ? MATCH : UNMATCH, accept ? newCat : ID);
//             }

//             addEdge(dfa, currentId, stateMap[newState], CHAR, c);
//         }
//     }

//     return dfa;
// }


string getStateKey(const vector<int>& states) {
    vector<int> sorted = states;
    sort(sorted.begin(), sorted.end());
    ostringstream oss;
    for (size_t i = 0; i < sorted.size(); ++i) {
        if (i != 0) oss << ",";
        oss << sorted[i];
    }
    return oss.str();
}

Graph* NFA_to_DFA(Graph* pNFA) {
    Graph* dfa = createNewGraph();
    
    // 收集字母表（使用 vector + 手动去重）
    vector<char> alphabet;
    for (Edge* e : *pNFA->pEdgeTable) {
        if (e->type == CHAR) {
            char c = (char)e->driverId;
            if (find(alphabet.begin(), alphabet.end(), c) == alphabet.end()) {
                alphabet.push_back(c);
            }
        }
    }

    // 使用 string 作为键
    map<string, int> stateMap;          // key: 状态集合的字符串表示
    map<int, vector<int>> stateData;    // 存储 DFA 状态对应的 NFA 状态集合
    int stateId = 0;
    queue<int> processQueue;           // 存储 DFA 状态ID

    // 初始状态处理
    vector<int> startSet = epsilon_closure(pNFA, {0});
    string startKey = getStateKey(startSet);
    
    stateMap[startKey] = stateId;
    stateData[stateId] = startSet;
    processQueue.push(stateId);
    dfa->numOfStates = 1;
    stateId++;

    // 检查初始接受状态（逻辑不变）
    bool isAccept = false;
    LexemeCategory cat;
    for (int s : startSet) {
        for (State* state : *pNFA->pStateTable) {
            if (state->stateId == s && state->type == MATCH) {
                isAccept = true;
                cat = state->category;
                break;
            }
        }
        if (isAccept) break;
    }
    addState(dfa, 0, isAccept ? MATCH : UNMATCH, isAccept ? cat : ID);

    // 主处理循环
    while (!processQueue.empty()) {
        int currentId = processQueue.front();
        processQueue.pop();
        vector<int> currentStates = stateData[currentId];

        for (char c : alphabet) {
            vector<int> newStates = DTran(pNFA, currentStates, c);
            if (newStates.empty()) continue;

            // 获取唯一键
            string newKey = getStateKey(newStates);

            // 检查是否为新状态
            if (stateMap.find(newKey) == stateMap.end()) {
                stateMap[newKey] = stateId;
                stateData[stateId] = newStates;
                processQueue.push(stateId);
                dfa->numOfStates++;

                // 检查接受状态
                bool accept = false;
                LexemeCategory newCat;
                for (int s : newStates) {
                    for (State* state : *pNFA->pStateTable) {
                        if (state->stateId == s && state->type == MATCH) {
                            accept = true;
                            newCat = state->category;
                            break;
                        }
                    }
                    if (accept) break;
                }
                addState(dfa, stateId, accept ? MATCH : UNMATCH, accept ? newCat : ID);
                stateId++;
            }

            // 添加边
            int nextId = stateMap[newKey];
            addEdge(dfa, currentId, nextId, CHAR, c);
        }
    }

    return dfa;
}

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

int main() {
    // 创建基本字符的NFA（假设LexemeCategory::OP为3）
    Graph* a = generateBasicNFA(CHAR, 'a');
    a->pStateTable->front()->category = OP;
    
    Graph* b = generateBasicNFA(CHAR, 'b');
    b->pStateTable->front()->category = OP;
    
    // 构造 a|b
    Graph* a_or_b = unionNFA(a, b);
    
    // 构造 (a|b)*
    Graph* closure_ab = closure(a_or_b);
    
    // 构造 abb 的串联
    Graph* a1 = generateBasicNFA(CHAR, 'a');
    a1->pStateTable->front()->category = OP;
    Graph* b1 = generateBasicNFA(CHAR, 'b');
    b1->pStateTable->front()->category = OP;
    Graph* b2 = generateBasicNFA(CHAR, 'b');
    b2->pStateTable->front()->category = OP;
    
    Graph* temp = product(closure_ab, a1);
    temp = product(temp, b1);
    Graph* final_nfa = product(temp, b2);
    
    // 转换为 DFA
    Graph* dfa = NFA_to_DFA(final_nfa);
    printGraph(final_nfa);   
    // 打印DFA结构
    printGraph(dfa);
    
    // 检查接受状态
    for (State* s : *dfa->pStateTable) {
        if (s->type == MATCH) {
            cout << "Accepting state: " << s->stateId 
                 << " with category: " << s->category << endl;
        }
    }
    
    return 0;
}