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

func testgenerateBasicNFA() {
    println("====  Testing generateBasicNFA()  ====")
    var nfa : Graph = generateBasicNFA("CHAR", r'a')
    printGraph(nfa)
    println("---------------------------------------------------")
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

func testunionNFA() {
    println("====  Testing unionNFA()  ====")
    var nfa1 : Graph = generateBasicNFA("CHAR", r'a')
    var nfa2 : Graph = generateBasicNFA("CHAR", r'b')
    var nfa3 : Graph = unionNFA(nfa1, nfa2)
    printGraph(nfa3)
    println("---------------------------------------------------")
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

func testproduct() {
    println("====  Testing product()  ====")
    var nfa1 : Graph = generateBasicNFA("CHAR", r'a')
    var nfa2 : Graph = generateBasicNFA("CHAR", r'b')
    var nfa3 : Graph = product(nfa1, nfa2)
    printGraph(nfa3)
    println("---------------------------------------------------")
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

func testclosure() {
    println("====  Testing closure()  ====")
    var nfa1 : Graph = generateBasicNFA("CHAR", r'a')
    var nfa2 : Graph = closure(nfa1)
    printGraph(nfa2)
    println("---------------------------------------------------")
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

func testplusClosure() {
    println("====  Testing plusClosure()  ====")
    var nfa1 : Graph = generateBasicNFA("CHAR", r'a')
    var nfa2 : Graph = plusClosure(nfa1)
    printGraph(nfa2)
    println("---------------------------------------------------")
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

func testzerOrOne() {
    println("====  Testing zerOrOne()  ====")
    var nfa1 : Graph = generateBasicNFA("CHAR", r'a')
    var nfa2 : Graph = zerOrOne(nfa1)
    printGraph(nfa2)
    println("---------------------------------------------------")
}

main() {
    testgenerateBasicNFA()
    testunionNFA()
    testproduct()
    testclosure()
    testplusClosure()
    testzerOrOne()
}