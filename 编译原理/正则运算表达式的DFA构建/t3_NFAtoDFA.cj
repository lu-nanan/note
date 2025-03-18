import std.collection.*


var DriverType : ArrayList<String> = ArrayList<String>(["NULL_DRIVER", "CHAR", "CHARSET"])

var StateType : ArrayList<String> = ArrayList<String>(["UNMATCH", "MATCH"])

var LexemeCategoryType : ArrayList<String> = ArrayList<String>(["ID", "NUM", "STR", "OP"])

var graphId : Int32 = 0

class State {
    var stateId : Int32
    var stateType : String
    var category : String

    public init(stateId : Int32, stateType : String, category : String) {
        this.stateId = stateId
        this.stateType = stateType
        this.category = category
    }
}

class Edge {
    var startState : Int32
    var nextState : Int32
    var driverType : String
    var driverId : Int32

    public init(startState : Int32, nextState : Int32, driverType : String, driverId : Int32) {
        this.startState = startState
        this.nextState = nextState
        this.driverType = driverType
        this.driverId = driverId
    }
}

class Graph {
    var graphId : Int32
    var numOfStates : Int32
    var pEdgeTable : ArrayList<Edge>
    var pStateTable : ArrayList<State>

    public init(graphId : Int32, numOfStates : Int32, pEdgeTable : ArrayList<Edge>, pStateTable : ArrayList<State>) {
        this.graphId = graphId
        this.numOfStates = numOfStates
        this.pEdgeTable = pEdgeTable
        this.pStateTable = pStateTable
    }

}

func createNewGraph() : Graph {
    var numOfStates : Int32 = 0
    var pEdgeTable : ArrayList<Edge> = ArrayList<Edge>()
    var pStateTable : ArrayList<State> = ArrayList<State>()
    var graph : Graph = Graph(graphId, numOfStates, pEdgeTable, pStateTable)
    graphId += 1
    return graph
}

func addEdge(graph : Graph, startState : Int32, nextState : Int32, driverType : String, driverId : Int32) : Unit {
    var edge : Edge = Edge(startState, nextState, driverType, driverId)
    graph.pEdgeTable.append(edge)
}

func addState(graph : Graph, id : Int32, stateType : String, category : String) : Unit {
    if (stateType == "MATCH") {
        graph.pStateTable.append(State(id, stateType, category))
    }
}

func remapStates(graph : Graph, offset : Int32) : Unit{
    for (e in graph.pEdgeTable) {
        e.startState += offset
        e.nextState += offset
    }
    for (s in graph.pStateTable) {
        s.stateId += offset
    }
}

func mergeStates(dest : Graph, src : Graph, offset : Int32, newType : String) : Unit {
    for (s in src.pStateTable) {
        addState(dest, s.stateId + offset, newType, s.category)
    }
}

func printGraph(graph : Graph) : Unit {
    print("Graph: ")
    print(graph.graphId)
    print(" has ")
    print(graph.numOfStates)
    print(" states.")
    println()
    println("Edges:")
    for(s in graph.pStateTable) {
        print("State: ")
        print(s.stateId)
        print(" ")
        print(s.stateType)
        println()
    }
    for (e in graph.pEdgeTable) {
        print(e.startState)
        print(" -> ")
        print(e.nextState)
        print(":")
        if (e.driverType == "NULL_DRIVER") {
            print("NULL")
        } else if (e.driverType == "CHAR") {
            print("CHAR")
            print(" [")
            print(Rune(e.driverId))
            print("]")
        } else if (e.driverType == "CHARSET") {
            print("CHARSET")
        } else {
            print("UNKNOWN")
        }
        println()
    }
    println()
    println("MATCH States:")
    for (s in graph.pStateTable) {
        if (s.stateType == "MATCH") {
            print("State: ")
            print(s.stateId)
            println()
        }
    }
    println("---------------------------------------------------")

}

func generateBasicNFA(dType : String, dId : Rune) : Graph {
    var nfa : Graph = createNewGraph()
    nfa.numOfStates = 2
    var charInt : Int32 = Int32(UInt32(dId))
    addEdge(nfa, 0, 1, dType, charInt)
    addState(nfa, 1, "MATCH", "ID")

    return nfa
}

func copyGraph(g : Graph) :  Graph {
    var g2 : Graph = createNewGraph()
    g2.numOfStates = g.numOfStates

    for (e in g.pEdgeTable) {
        addEdge(g2, e.startState, e.nextState, e.driverType, e.driverId)
    }

    for (s in g.pStateTable) {
        if (s.stateType == "MATCH") {
            addState(g2, s.stateId, s.stateType, s.category)
        }
    }

    return g2
}

func unionNFA(pNFA1 : Graph, pNFA2 : Graph) : Graph {
    var copy1 : Graph = copyGraph(pNFA1)
    var copy2 : Graph = copyGraph(pNFA2)

    var newNFA : Graph = createNewGraph()
    let offset1 : Int32 = 1;
    let offset2 : Int32 = 1 + copy1.numOfStates

    newNFA.numOfStates = copy1.numOfStates + copy2.numOfStates + 2

    addEdge(newNFA, 0, offset1, "NULL_DRIVER", 0)
    addEdge(newNFA, 0, offset2, "NULL_DRIVER", 0)

    remapStates(copy1, offset1)
    remapStates(copy2, offset2)

    for (e in copy1.pEdgeTable) {
        addEdge(newNFA, e.startState, e.nextState, e.driverType, e.driverId)
    }

    for (e in copy2.pEdgeTable) {
        addEdge(newNFA, e.startState, e.nextState, e.driverType, e.driverId)
    }

    let newEnd : Int32 = newNFA.numOfStates - 1
    
    for (s in copy1.pStateTable) {
        addEdge(newNFA, s.stateId, newEnd, "NULL_DRIVER", 0)
    }

    for (s in copy2.pStateTable) {
        addEdge(newNFA, s.stateId, newEnd, "NULL_DRIVER", 0)
    }

    addState(newNFA, newEnd, "MATCH", "ID")

    return newNFA
}

func product(pNFA1 : Graph, pNFA2 : Graph) : Graph {
    var copy1 : Graph = copyGraph(pNFA1)
    var copy2 : Graph = copyGraph(pNFA2)

    var newNFA : Graph = createNewGraph()
    let offset : Int32 = copy1.numOfStates;
    newNFA.numOfStates = copy1.numOfStates + copy2.numOfStates

    for (e in copy1.pEdgeTable) {
        addEdge(newNFA, e.startState, e.nextState, e.driverType, e.driverId)
    }

    mergeStates(newNFA, copy1, 0, "UNMATCH")

    remapStates(copy2, offset)
    for (e in copy2.pEdgeTable) {
        addEdge(newNFA, e.startState, e.nextState, e.driverType, e.driverId)
    }
    mergeStates(newNFA, copy2, 0, "MATCH")

    for (s in copy1.pStateTable) {
        if (s.stateType == "MATCH") {
            addEdge(newNFA, s.stateId, offset, "NULL_DRIVER", 0)
        }
    }

    return newNFA
}

func closure(pNFA : Graph) {
    var copy : Graph = copyGraph(pNFA)
    var newNFA : Graph = createNewGraph()
    let offset : Int32 = 1;
    newNFA.numOfStates = copy.numOfStates + 2

    addEdge(newNFA, 0, offset, "NULL_DRIVER", 0)
    addEdge(newNFA, 0, newNFA.numOfStates - 1, "NULL_DRIVER", 0)

    remapStates(copy, offset)

    for (e in copy.pEdgeTable) {
        addEdge(newNFA, e.startState, e.nextState, e.driverType, e.driverId)
    }

    mergeStates(newNFA, copy, 0, "UNMATCH")

    let newEnd : Int32 = newNFA.numOfStates - 1

    for (s in copy.pStateTable) {
        addEdge(newNFA, s.stateId, offset, "NULL_DRIVER", 0)
        addEdge(newNFA, s.stateId, newEnd, "NULL_DRIVER", 0)
    }

    addState(newNFA, newEnd, "MATCH", "ID")

    return newNFA
}

func plusClosure(pNFA : Graph) : Graph {
    var copy : Graph = copyGraph(pNFA)

    var newNFA : Graph = createNewGraph()
    newNFA.numOfStates = copy.numOfStates
    
    for (e in copy.pEdgeTable) {
        addEdge(newNFA, e.startState, e.nextState, e.driverType, e.driverId)
    }
    mergeStates(newNFA, copy, 0, "UNMATCH")

    let newEnd : Int32 = newNFA.numOfStates - 1
    for (s in copy.pStateTable) {
        addEdge(newNFA, s.stateId, 0, "NULL_DRIVER", 0)
    }

    addState(newNFA, newEnd, "MATCH", "ID")

    return newNFA
}

func zerOrOne(pNFA : Graph) : Graph {
    var copy : Graph = copyGraph(pNFA)
    var newNFA : Graph = createNewGraph()
    newNFA.numOfStates = copy.numOfStates + 2

    addEdge(newNFA, 0, 1, "NULL_DRIVER", 0)
    addEdge(newNFA, 0, newNFA.numOfStates - 1, "NULL_DRIVER", 0)

    remapStates(copy, 1)
    for (e in copy.pEdgeTable) {
        addEdge(newNFA, e.startState, e.nextState, e.driverType, e.driverId)
    }
    mergeStates(newNFA, copy, 0, "UNMATCH")

    let newEnd : Int32 = newNFA.numOfStates - 1
    for (s in copy.pStateTable) {
        addEdge(newNFA, s.stateId, newEnd, "NULL_DRIVER", 0)
    }

    addState(newNFA, newEnd, "MATCH", "ID")

    return newNFA
}

func normalize(v : ArrayList<Int32>) : ArrayList<Int32> {
    v.sortBy() { a : Int32, b : Int32 =>
        if (a < b) {
            return Ordering.LT
        } else if (a == b) {
            return Ordering.EQ
        } else {
            return Ordering.GT
        }
    }

    for (i in 0..v.size - 1) {
        if (v[i] != -999) {
            for (j in i..v.size - 1) {
                if (i != j && v[j] == v[i]) {
                    v[j] = -999
                }
            }
        } else {
            continue   
        }
    }

    v.removeIf { a : Int32 =>
        a == -999
    }

    return v
}

func isExist(closure : ArrayList<Int32>, state : Int32) : Bool {
    for (s in closure) {
        if (s == state) {
            return true
        }
    }
    return false
}

func isExist(closure : ArrayList<Rune>, state : Int32) : Bool {
    for (s in closure) {
        if (Int32(UInt32(s)) == state) {
            return true
        }
    }
    return false
}

func epsilon_closure(nfa : Graph, states : ArrayList<Int32>) : ArrayList<Int32> {
    var closure : ArrayList<Int32> = normalize(states)
    var q : ArrayList<Int32> = ArrayList<Int32>()
    for (s in closure) {
        q.append(s)
    }

    while (!q.isEmpty()) {
        var curr : Int32 = q[0]
        q.remove(0)

        for (e in nfa.pEdgeTable) {
            if (e.startState == curr && e.driverType == "NULL_DRIVER") {
                if (!isExist(closure, e.nextState)) {
                    closure.append(e.nextState)
                    closure = normalize(closure)
                    q.append(e.nextState)
                }
            }
        }
    }

    return closure
}


func move(nfa : Graph, states : ArrayList<Int32>, c : Rune) : ArrayList<Int32> {
    var result : ArrayList<Int32> = ArrayList<Int32>()

    for (s in states) {
        for (e in nfa.pEdgeTable) {
            if (e.startState == s && e.driverType == "CHAR" && e.driverId == Int32(UInt32(c))) {
                result.append(e.nextState)
            }
        }
    }

    result = normalize(result)
    return result
}

func DTran(nfa : Graph, T : ArrayList<Int32>, a : Rune) : ArrayList<Int32> {
    var moved : ArrayList<Int32> = move(nfa, T, a)
    return epsilon_closure(nfa, moved)
}

// func NFAtoDFA(nfa : Graph) : Graph {
//     var dfa : Graph = createNewGraph()

//     var alphabet : ArrayList<Rune> = ArrayList<Rune>()

//     for (e in nfa.pEdgeTable) {
//         if (e.driverType == "CHAR") {
//             if (!isExist(alphabet, e.driverId)) {
//                 alphabet.append(Rune(e.driverId))
//             }
//         }
//     }

//     var stateMap : HashMap<ArrayList<Int32>, Int32> = HashMap<ArrayList<Int32>, Int32>()
//     var stateId : Int32 = 0
//     var processeQueue : LinkedList<ArrayList<Int32>> = LinkedList<ArrayList<Int32>>()

//     var startSet : ArrayList<Int32> = epsilon_closure(nfa, ArrayList<Int32>{[0]})

//     startSet = normalize(startSet)

//     stateMap[startSet] = stateId ++;
//     processeQueue.append(startSet)
//     dfa.numOfStates = 1

//     var isAccept : Bool = false
//     var cat : String
//     for (s in startSet) {
//         for (state in nfa.pStateTable) {
//             if (state.stateId == s && state.stateType == "MATCH") {
//                 isAccept = true
//                 cat = state.stateCategory
//                 break;
//             }
//         }
//         if (isAccept) {
//             break;
//         }
//     }
//     if (isAccept) {
//         addState(dfa, 0, "MATCH", cat)
//     } else {
//         addState(dfa, 0, "UNMATCH", "ID")
//     }

//     while (!processeQueue.isEmpty()) {
//         let curr : ArrayList<Int32> = processeQueue.popfirst()
//         var currId : Int32 = stateMap[curr]

//         for (a in alphabet) {
//             var newState : ArrayList<Int32> = DTran(nfa, curr, a)
//             if (newState.size == 0) {
//                 continue
//             }

//             newState = normalize(newState)

//             if (stateMap.contains(newState)) {
//                 stateMap[newState] = stateId ++
//                 processeQueue.append(newState)
//                 dfa.numOfStates ++

//                 var accept : Bool = false
//                 var newCat : String
//                 for (s in newState) {
//                     for (state in nfa.pStateTable) {
//                         if (state.stateId == s && state.stateType == "MATCH") {
//                             isAccept = true
//                             newCat = state.stateCategory
//                             break;
//                         }
//                     }
//                     if (accept) {
//                         break;
//                     }
//                 }
//                 if (accept) {
//                     addState(dfa, stateMap[newState], "MATCH", newCat)
//                 } else {
//                     addState(dfa, stateMap[newState], "UNMATCH", "ID")
//                 }
//             }

//             addEdge(dfa, currId, stateMap[newState], "CHAR", a)
//         }
//     }

//     return dfa
// }

func getStateKey(state : ArrayList<Int32>) : String {
    return state.toString()
}

func NFAtoDFA(nfa : Graph) : Graph {
    var dfa : Graph = createNewGraph()

    var alphabet : ArrayList<Rune> = ArrayList<Rune>()

    for (e in nfa.pEdgeTable) {
        if (e.driverType == "CHAR") {
            if (!isExist(alphabet, e.driverId)) {
                alphabet.append(Rune(e.driverId))
            }
        }
    }

    var stateMap : HashMap<String, Int32> = HashMap<String, Int32>()
    var stateData : HashMap<Int32, ArrayList<Int32>> = HashMap<Int32, ArrayList<Int32>>()
    var stateId : Int32 = 0
    var processeQueue : ArrayList<Int32> = ArrayList<Int32>()


    var state0 : ArrayList<Int32> = ArrayList<Int32>()
    state0.append(0)
    var startSet : ArrayList<Int32> = epsilon_closure(nfa, state0)
    var startKey : String = getStateKey(startSet)

    stateMap[startKey] = stateId;
    stateData[stateId] = startSet
    processeQueue.append(stateId)
    dfa.numOfStates = 1
    stateId += 1

    var isAccept : Bool = false
    var cat : String = ""
    for (s in startSet) {
        for (state in nfa.pStateTable) {
            if (state.stateId == s && state.stateType == "MATCH") {
                isAccept = true
                cat = state.category
                break;
            }
        }
        if (isAccept) {
            break;
        }
    }
    if (isAccept) {
        addState(dfa, 0, "MATCH", cat)
    } else {
        addState(dfa, 0, "UNMATCH", "ID")
    }

    while (!processeQueue.isEmpty()) {
        let currId : Int32 = processeQueue[0]
        processeQueue.remove(0)

        var curr : ArrayList<Int32> = stateData[currId]


        for (a in alphabet) {
            var newState : ArrayList<Int32> = DTran(nfa, curr, a)
            if (newState.size == 0) {
                continue
            }
            
            var newKey : String = getStateKey(newState)

            if (!stateMap.contains(newKey)) {
                stateMap[newKey] = stateId
                stateData[stateId] = newState
                processeQueue.append(stateId)
                dfa.numOfStates ++

                var accept : Bool = false
                var newCat : String = ""
                for (s in newState) {
                    for (state in nfa.pStateTable) {
                        if (state.stateId == s && state.stateType == "MATCH") {
                            accept = true
                            newCat = state.category
                            break;
                        }
                    }
                    if (accept) {
                        break;
                    }
                }
                if (accept) {
                    addState(dfa, stateId, "MATCH", newCat)
                } else {
                    addState(dfa, stateId, "UNMATCH", "ID")
                }
                stateId += 1
            }
            var nextId : Int32 = stateMap[newKey]
            addEdge(dfa, currId, nextId, "CHAR", Int32(UInt32(a)))
        }
    }

    
    return dfa
}




func test() : Unit {
    var a : Graph = generateBasicNFA("CHAR", r'a')

    var b : Graph = generateBasicNFA("CHAR", r'b')

    var a_or_b : Graph = unionNFA(a, b)

    var closure_ab : Graph = closure(a_or_b)

    var a1 : Graph = generateBasicNFA("CHAR", r'a')
    var b1 : Graph = generateBasicNFA("CHAR", r'b')
    var b2 : Graph = generateBasicNFA("CHAR", r'b')

    var temp : Graph = product(closure_ab, a1)
    temp = product(temp, b1)
    var final_nfa : Graph = product(temp, b2)

    var dfa : Graph = NFAtoDFA(final_nfa)

    printGraph(final_nfa)
    printGraph(dfa)
}

func test2() : Unit {
    var a : Graph = generateBasicNFA("CHAR", r'a')
    for (i in "bcdefghijklmnopqrstuvwxyz") {
        var b : Graph = generateBasicNFA("CHAR", Rune(i))
        a = unionNFA(a, b)
    }
    var charC = closure(a)
    
    var num : Graph = generateBasicNFA("CHAR", r'0')
    for (i in 1..9) {
        var b : Graph = generateBasicNFA("CHAR", Rune(i + 48))
        num = unionNFA(num, b)
    }
    var numin0 = closure(num)

    var name : Graph = closure(unionNFA(charC, numin0))

    var temp : Graph = product(charC, numin0)

    var numOut0 : Graph = generateBasicNFA("CHAR", r'1')
    for (i in 2..9) {
        var b : Graph = generateBasicNFA("CHAR", Rune(i + 48))
        numOut0 = unionNFA(numOut0, b)
    }

    var number : Graph = product(numOut0, numin0)

    var op : Graph = generateBasicNFA("CHAR", r'+')
    var op1 : Graph = generateBasicNFA("CHAR", r'-')
    var op2 : Graph = generateBasicNFA("CHAR", r'*')
    var op3 : Graph = generateBasicNFA("CHAR", r'/')
    var op4 : Graph = generateBasicNFA("CHAR", r'%')
    var op5 : Graph = generateBasicNFA("CHAR",r'^')

    var op_nfa : Graph = unionNFA(op, op1)
    op_nfa = unionNFA(op_nfa, op2)
    op_nfa = unionNFA(op_nfa, op3)
    op_nfa = unionNFA(op_nfa, op4)
    op_nfa = unionNFA(op_nfa, op5)

    var Cal : Graph = unionNFA(number,closure(product(op_nfa, number)))

    var final : Graph = closure(unionNFA(unionNFA(name, Cal),number))
    printGraph(final)

    var dfa : Graph = NFAtoDFA(final)
    printGraph(dfa)

}

main() {
    test()
    test2()
}