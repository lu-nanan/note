package t2;

import std.collection.*
import myenum_enhance.*

@ToStringEnum
@EquatableEnum
enum SymbolType {
    TERMINAL | NONTERMINAL | NULL_SYMBOL
}

@ToStringEnum
@EquatableEnum
enum LexemeType {
    ID | NUM | RELOP | IF | ELSE | NULL | EOF
}

@ToStringEnum
@EquatableEnum
enum ItemCategory { 
    CORE | NONCORE 
}

@ToStringEnum
@EquatableEnum
enum ActionCategory { 
    SHIFT | REDUCE |ACCEPT
}

open class GrammarSymbol<: Hashable & Equatable<GrammarSymbol>{
    
    var name : String       //name of the symbol
    var symbolType : SymbolType  //type of the symbol

    public init(name : String, symbolType : SymbolType) {
        this.name = name
        this.symbolType = symbolType
    }

    public func hashCode(): Int64 {
        var s : String = name + symbolType.toString()
        return s.hashCode()
    }

    public operator func ==(rhs: GrammarSymbol): Bool {
        return this.name == rhs.name && this.symbolType == rhs.symbolType
    }

    public operator func !=(rhs: GrammarSymbol): Bool {
        return this.name != rhs.name && this.symbolType == rhs.symbolType
    }
}

class TerminalSymbol <: GrammarSymbol & Hashable & Equatable<TerminalSymbol>{

    var category : LexemeType    //category of the symbol
    
    public init(name : String, c : LexemeType) {
        super(name, TERMINAL)
        this.category = c
    }
    
    // public func hashCode(): Int64 {
    //     var s : String = name + symbolType.toString() + category.toString()
    //     return s.hashCode()
    // }

    public operator func ==(rhs: TerminalSymbol): Bool {
        return this.name == rhs.name && this.symbolType == rhs.symbolType && this.category == rhs.category
    }

    public operator func !=(rhs: TerminalSymbol): Bool {
        return this.name != rhs.name && this.symbolType == rhs.symbolType && this.category == rhs.category
    }
}

class Production <: Hashable & Equatable<Production>{

    var productionId : Int32                                // id of the production
    var bodysize : Int32
    var pBodySymbolTable : ArrayList<GrammarSymbol>         // production set
    var pFirstSet : HashSet<TerminalSymbol>                 // first set of the production
    var head : NonTerminalSymbol

    public init(productionId : Int32) {
        this.head = NonTerminalSymbol("null")
        this.bodysize = 0
        this.productionId = productionId
        this.pBodySymbolTable = ArrayList<GrammarSymbol>()
        this.pFirstSet = HashSet<TerminalSymbol>()
    }

    public func addBodySymbol(symbol : GrammarSymbol) : Unit {
        this.pBodySymbolTable.append(symbol)
        this.bodysize += 1
    }

    public func toString(): String {
        var s : String = "Production " + productionId.toString() + " : " + head.name + " -> "
        for (p in this.pBodySymbolTable) {
            s += p.name + " "
        }
        return s
    }

    public func hashCode() : Int64 {
        return productionId.hashCode()
    }

    public operator func ==(rhs: Production): Bool {
        return this.productionId == rhs.productionId && this.bodysize == rhs.bodysize
    }

    public operator func !=(rhs: Production): Bool {
        return this.productionId != rhs.productionId && this.bodysize != rhs.bodysize
    }
}

class NonTerminalSymbol <: GrammarSymbol & Hashable & Equatable<NonTerminalSymbol>{

    var numOfProduction : Int32                           // number of productions of the nonterminal symbol
    var pProductionTable : ArrayList<Production>            // production table of the nonterminal symbol
    var pFirstSet : HashSet<TerminalSymbol>                 // first set of the nonterminal symbol
    var pFollowSet : HashSet<TerminalSymbol>
    var pDependentSetInFollow : HashSet<NonTerminalSymbol>  //follow Dependency set
    var canDeriveEpsilon : Bool

    public init(name : String) {
        super(name, NONTERMINAL)
        this.numOfProduction = 0
        this.canDeriveEpsilon = false
        this.pProductionTable = ArrayList<Production>()
        this.pFirstSet = HashSet<TerminalSymbol>()
        this.pFollowSet = HashSet<TerminalSymbol>()
        this.pDependentSetInFollow = HashSet<NonTerminalSymbol>()
    }

    // public func hashCode(): Int64 {
    //     var s : String = name + symbolType.toString() + this.numOfProduction.toString() + this.canDeriveEpsilon.toString()
    //     return s.hashCode()
    // }

    public operator func ==(rhs: NonTerminalSymbol): Bool {
        return this.name == rhs.name && this.symbolType == rhs.symbolType && this.numOfProduction == rhs.numOfProduction && this.canDeriveEpsilon == rhs.canDeriveEpsilon
    }

    public operator func !=(rhs: NonTerminalSymbol): Bool {
        return this.name != rhs.name && this.symbolType == rhs.symbolType && this.numOfProduction != rhs.numOfProduction && this.canDeriveEpsilon != rhs.canDeriveEpsilon 
    }

    func toString(): String {
        var s : String = "NonTerminalSymbol " + name + " : "
        for (p in this.pProductionTable) {
            s += p.toString() + "\n"
        }
        return s
    }

    func addProduction(p : Production) : Unit {
        this.pProductionTable.append(p)
    }
}

class LR0Item <: Hashable & Equatable<LR0Item> {
    var nonTerminalSymbol : NonTerminalSymbol
    var production : Production
    var dotPosition : Int64
    var category : ItemCategory

    public init(nonTerminalSymbol : NonTerminalSymbol, production : Production, dotPosition : Int64, category : ItemCategory) {
        this.nonTerminalSymbol = nonTerminalSymbol
        this.production = production
        this.dotPosition = dotPosition
        this.category = category
    }

    public func toString(): String {
        var s : String = nonTerminalSymbol.name + " -> "
        for (i in 0..production.bodysize) {
            if (i == Int32(dotPosition)) {
                s += "."
            }
            s += production.pBodySymbolTable[Int64(i)].name + " "
        }
        if (dotPosition == Int64(production.bodysize)) {
            s += "."
        }
        return s
    }

    public func hashCode(): Int64 {
        var s : String = nonTerminalSymbol.toString() + production.toString() + dotPosition.toString()
        return s.hashCode()
    }

    public operator func ==(rhs: LR0Item): Bool {
        return this.nonTerminalSymbol == rhs.nonTerminalSymbol && this.production == rhs.production && this.dotPosition == rhs.dotPosition
    }

    public operator func !=(rhs: LR0Item): Bool {
        return this.nonTerminalSymbol != rhs.nonTerminalSymbol && this.production != rhs.production && this.dotPosition != rhs.dotPosition
    }
}

func itemSetsEqual(set1 : ItemSet, set2 : ItemSet) : Bool {
    if (set1.itemSet.size != set2.itemSet.size) {
        return false
    }
    for (item in set1.itemSet) {
        if (!set2.itemSet.contains(item)) {
            return false
        }
    }
    return true
}

class ItemSet <: Hashable & Equatable<ItemSet> {
    var stateId : Int32
    var itemSet : HashSet<LR0Item>

    public init(stateId : Int32) {
        this.stateId = stateId
        this.itemSet = HashSet<LR0Item>()
    }

    public func toString(): String {
        var s : String = "ItemSet " + stateId.toString() + " : "
        for (item in this.itemSet) {
            s += item.toString() + "\n"
        }
        return s
    }

    public func hashCode(): Int64 {
        return this.toString().hashCode()
    }

    public operator func ==(rhs: ItemSet): Bool {
        return stateId == rhs.stateId && itemSetsEqual(this, rhs)
    }

    public operator func !=(rhs: ItemSet): Bool {
        return stateId != rhs.stateId || !itemSetsEqual(this, rhs)
    }

}

class TransitionEdge {
    var driverSymbol : GrammarSymbol
    var fromItemSet : ItemSet
    var toItemSet : ItemSet

    public init(driverSymbol : GrammarSymbol, fromItemSet : ItemSet, toItemSet : ItemSet) {
        this.driverSymbol = driverSymbol
        this.fromItemSet = fromItemSet
        this.toItemSet = toItemSet
    }
}

class DFA {
    var itemSet : ItemSet
    var pEdgeTable : ArrayList<TransitionEdge>
    var pItemSetTable : ArrayList<ItemSet>

    public init(itemSet : ItemSet) {
        this.itemSet = itemSet
        this.pEdgeTable = ArrayList<TransitionEdge>()
        this.pItemSetTable = ArrayList<ItemSet>()
        pItemSetTable.append(itemSet)
    }
}

class ActionCell {
    var stateId : Int32
    var terminalSymbolName : String
    var actionType : ActionCategory
    var id : Int32

    public init(stateId : Int32, terminalSymbolName : String, actionType : ActionCategory, id : Int32) {
        this.stateId = stateId
        this.terminalSymbolName = terminalSymbolName
        this.actionType = actionType
        this.id = id
    }
}

class GotoCell {
    var stateId : Int32
    var nonTerminalSymbolName : String
    var nextStateid : Int32

    public init(stateId : Int32, nonTerminalSymbolName : String, nextStateid : Int32) {
        this.stateId = stateId
        this.nonTerminalSymbolName = nonTerminalSymbolName
        this.nextStateid = nextStateid
    }
}

class ProductionInfo {
    var indexId : Int32
    var headName : String
    var bodysize : Int32

    public init(indexId : Int32, headName : String, bodysize : Int32) {
        this.indexId = indexId
        this.headName = headName
        this.bodysize = bodysize
    }
}

func computeProductionFirstSet(production : Production, canDriveEpsilonMap : HashMap<NonTerminalSymbol, Bool>) : Unit {
    production.pFirstSet.clear()
    
    var canDeriveEpsilon : Bool = true

    for (symbol in production.pBodySymbolTable) {
        if (symbol.symbolType == SymbolType.TERMINAL) {
            // static cast
            var temp : TerminalSymbol = TerminalSymbol(symbol.name, LexemeType.NULL)
            production.pFirstSet.put(temp)
            canDeriveEpsilon = false
            break
        } else if (symbol.symbolType == SymbolType.NONTERMINAL) {
            //static_cast
            var nonTerminal : NonTerminalSymbol = (symbol as NonTerminalSymbol).getOrThrow()
            
            for (term in nonTerminal.pFirstSet) {
                production.pFirstSet.put(term)
            }
            if (!canDriveEpsilonMap.contains(nonTerminal)) {
                canDeriveEpsilon = false
                break
            } else {
                if (!canDriveEpsilonMap[nonTerminal]) {
                    canDeriveEpsilon = false
                    break
                }
            }
        }
    }
}

func computeAllFirstSets(grammarSymbols : ArrayList<GrammarSymbol>, canDriveEpsilonMap : HashMap<NonTerminalSymbol, Bool>) : Unit {
    var changed : Bool = true
    while (changed) {
        changed = false
        for (symbol in grammarSymbols) {
            if (symbol.symbolType == SymbolType.NONTERMINAL) {
                var nonTerminal : NonTerminalSymbol = (symbol as NonTerminalSymbol).getOrThrow()
                var oldFirstSize : Int32 = Int32(nonTerminal.pFirstSet.size)
                var oldCanDeriveEpsilon : Bool = nonTerminal.canDeriveEpsilon
                nonTerminal.canDeriveEpsilon = false
                for (production in nonTerminal.pProductionTable) {
                    if (production.bodysize == 0) {
                        nonTerminal.canDeriveEpsilon = true
                    } else {
                        computeProductionFirstSet(production, canDriveEpsilonMap)
                        for (terminal in production.pFirstSet) {
                            nonTerminal.pFirstSet.put(terminal)
                        }
                        var prodcanDeriveEpsilon : Bool = true
                        for (prodSymbol in production.pBodySymbolTable) {
                            if (prodSymbol.symbolType == SymbolType.TERMINAL) {
                                prodcanDeriveEpsilon = false
                                break
                            } else if (prodSymbol.symbolType == SymbolType.NONTERMINAL) {
                                var prodNonTerminal : NonTerminalSymbol = (prodSymbol as NonTerminalSymbol).getOrThrow()
                                if (!canDriveEpsilonMap.contains(prodNonTerminal)) {
                                    prodcanDeriveEpsilon = false
                                    break
                                } else {
                                    if (!canDriveEpsilonMap[prodNonTerminal]) {
                                        prodcanDeriveEpsilon = false
                                        break
                                    }
                                }
                            }
                        }
                        if (prodcanDeriveEpsilon) {
                            nonTerminal.canDeriveEpsilon = true
                        }
                    }
                }
                if (Int32(nonTerminal.pFirstSet.size) > oldFirstSize || nonTerminal.canDeriveEpsilon != oldCanDeriveEpsilon) {
                    changed = true
                }
            }
        }
        for (symbol in grammarSymbols) {
            if (symbol.symbolType == SymbolType.NONTERMINAL) {
                var nonTerminal : NonTerminalSymbol = (symbol as NonTerminalSymbol).getOrThrow()
                canDriveEpsilonMap.put(nonTerminal, nonTerminal.canDeriveEpsilon)
            }
        }
    }
}

func computeAllFollowSets(grammarSymbols : ArrayList<GrammarSymbol>, rootSymbol : NonTerminalSymbol, canDeriveEpsilonMap : HashMap<NonTerminalSymbol, Bool>) : Unit {
    var eof : TerminalSymbol = TerminalSymbol("$", LexemeType.EOF)
    for (symbol in grammarSymbols) {
        if (symbol.symbolType == SymbolType.TERMINAL && symbol.name == "$") {
            eof = (symbol as TerminalSymbol).getOrThrow()
            rootSymbol.pFollowSet.put(eof)
            break
        }
    }
    var changed : Bool = true
    while (changed) {
        changed = false
        for (symbol in grammarSymbols) {
            if (symbol.symbolType == SymbolType.NONTERMINAL) {
                var nt : NonTerminalSymbol = (symbol as NonTerminalSymbol).getOrThrow()
                var oldFollowSize : Int32 = Int32(nt.pFollowSet.size)
                for (sym in grammarSymbols) {
                    if (sym.symbolType == SymbolType.NONTERMINAL) {
                        var head : NonTerminalSymbol = (sym as NonTerminalSymbol).getOrThrow()
                        for (production in head.pProductionTable) {
                            var i : Int64 = 0
                            while (i < production.pBodySymbolTable.size) {
                                var bodySymbol : GrammarSymbol = production.pBodySymbolTable[i]
                                if (bodySymbol == (nt as GrammarSymbol).getOrThrow()) {
                                    var addFollow : Bool = true
                                    var j : Int64 = i + 1
                                    while (j < production.pBodySymbolTable.size && addFollow) {
                                        var nextSymbol : GrammarSymbol = production.pBodySymbolTable[j]
                                        if (nextSymbol.symbolType == SymbolType.TERMINAL) {
                                            var terminal : TerminalSymbol = (nextSymbol as TerminalSymbol).getOrThrow()
                                            nt.pFollowSet.put(terminal)
                                            addFollow = false
                                        } else if (nextSymbol.symbolType == SymbolType.NONTERMINAL) {
                                            var nextNt : NonTerminalSymbol = (nextSymbol as NonTerminalSymbol).getOrThrow()
                                            for (terminal in nextNt.pFirstSet) {
                                                nt.pFollowSet.put(terminal)
                                            }
                                            if (!canDeriveEpsilonMap[nextNt]) {
                                                addFollow = false
                                            }
                                        }
                                        j += 1
                                    }
                                    if (addFollow) {
                                        for (terminal in head.pFollowSet) {
                                            nt.pFollowSet.put(terminal)
                                        }
                                    }
                                }
                                i += 1                                 
                            }
                        }
                    }
                }
                if (Int32(nt.pFollowSet.size) > oldFollowSize) {
                    changed = true
                }
            }
        }
    }
}

func getClosure(itemSet : ItemSet) : Unit {
    var workList : ArrayList<LR0Item> = ArrayList<LR0Item>()
    
    // 初始化工作队列
    for (item in itemSet.itemSet) {
        workList.append(item)
    }
    
    while (!workList.isEmpty()) {
        var currentItem : LR0Item = workList.remove(0)
        
        if (currentItem.dotPosition < Int64(currentItem.production.bodysize)) {
            var nextSymbol : GrammarSymbol = currentItem.production.pBodySymbolTable[currentItem.dotPosition]
            if (nextSymbol.symbolType == SymbolType.NONTERMINAL) {
                var nt : NonTerminalSymbol = (nextSymbol as NonTerminalSymbol).getOrThrow()
                for (prod in nt.pProductionTable) {
                    var newItem : LR0Item = LR0Item(nt, prod, 0, ItemCategory.NONCORE)
                    if (itemSet.itemSet.put(newItem)) {
                        workList.append(newItem)
                    }
                }
            }
        }
    }
}

func testGetClosure() : Unit {
    // 定义终结符
    var lparen : TerminalSymbol = TerminalSymbol("(", LexemeType.RELOP)
    var rparen : TerminalSymbol = TerminalSymbol(")", LexemeType.RELOP)
    var plus : TerminalSymbol = TerminalSymbol("+", LexemeType.RELOP)
    var star : TerminalSymbol = TerminalSymbol("*", LexemeType.RELOP)
    var id : TerminalSymbol = TerminalSymbol("id", LexemeType.ID)
    
    // 定义非终结符
    var E : NonTerminalSymbol = NonTerminalSymbol("E")
    var T : NonTerminalSymbol = NonTerminalSymbol("T")
    var F : NonTerminalSymbol = NonTerminalSymbol("F")
    
    // 定义产生式
    var p1 : Production = Production(1)
    p1.head = E
    p1.addBodySymbol(E)
    p1.addBodySymbol(plus)
    p1.addBodySymbol(T)
    E.pProductionTable.append(p1)
    
    var p2 : Production = Production(2)
    p2.head = E
    p2.addBodySymbol(T)
    E.pProductionTable.append(p2)
    
    var p3 : Production = Production(3)
    p3.head = T
    p3.addBodySymbol(T)
    p3.addBodySymbol(star)
    p3.addBodySymbol(F)
    T.pProductionTable.append(p3)
    
    var p4 : Production = Production(4)
    p4.head = T
    p4.addBodySymbol(F)
    T.pProductionTable.append(p4)
    
    var p5 : Production = Production(5)
    p5.head = F
    p5.addBodySymbol(lparen)
    p5.addBodySymbol(E)
    p5.addBodySymbol(rparen)
    F.pProductionTable.append(p5)
    
    var p6 : Production = Production(6)
    p6.head = F
    p6.addBodySymbol(id)
    F.pProductionTable.append(p6)
    
    // 创建初始项目集
    var itemSet : ItemSet = ItemSet(0)
    var initialItem : LR0Item = LR0Item(E, p1, 0, ItemCategory.CORE)
    itemSet.itemSet.put(initialItem)
    
    // 计算闭包
    getClosure(itemSet)
    
    // 输出结果
    println("Closure of ItemSet:")
    for (item in itemSet.itemSet) {
        println(item.production.toString() + ", dot at " + item.dotPosition.toString() + ", category: " + item.category.toString())
    }
}



func exhaustTransition(itemSet : ItemSet, pItemSetTable : ArrayList<ItemSet>, pEdgeTable : ArrayList<TransitionEdge>) : Unit {
    var transitionMap : HashMap<GrammarSymbol, ArrayList<LR0Item>> = HashMap<GrammarSymbol, ArrayList<LR0Item>>()

    // Build transition map
    for (item in itemSet.itemSet) {
        if (item.dotPosition < Int64(item.production.bodysize)) {
            var driver : GrammarSymbol = item.production.pBodySymbolTable[item.dotPosition]
            var nextItem : LR0Item = LR0Item(item.nonTerminalSymbol, item.production, item.dotPosition + 1, item.category)
            var items : ArrayList<LR0Item>
            if (!transitionMap.contains(driver)) {
                items = ArrayList<LR0Item>()
                transitionMap.put(driver, items)
            } else {
                items = transitionMap[driver]
            }
            items.append(nextItem)
        }
    }

    // Process each transition
    for ((driver,coreItems) in transitionMap) {
        var newItemSet : ItemSet = ItemSet(Int32(pItemSetTable.size))
        for (item in coreItems) {
            newItemSet.itemSet.put(item)
        }
        getClosure(newItemSet)

        var isNew : Bool = true
        var existingSet : ItemSet = ItemSet(0)
        for (existing in pItemSetTable) {
            if (itemSetsEqual(existing, newItemSet)) {
                isNew = false
                existingSet = existing
                break
            }
        }

        if (isNew) {
            pItemSetTable.append(newItemSet)
            existingSet = newItemSet
        }
        var edge : TransitionEdge = TransitionEdge(driver, itemSet, existingSet)
        pEdgeTable.append(edge)
    }
}

func testExhaustTransition() : Unit {
    // Define terminals
    var lparen : TerminalSymbol = TerminalSymbol("(", LexemeType.RELOP)
    var rparen : TerminalSymbol = TerminalSymbol(")", LexemeType.RELOP)
    var plus : TerminalSymbol = TerminalSymbol("+", LexemeType.RELOP)
    var star : TerminalSymbol = TerminalSymbol("*", LexemeType.RELOP)
    var id : TerminalSymbol = TerminalSymbol("id", LexemeType.ID)
    
    // Define non-terminals
    var E : NonTerminalSymbol = NonTerminalSymbol("E")
    var T : NonTerminalSymbol = NonTerminalSymbol("T")
    var F : NonTerminalSymbol = NonTerminalSymbol("F")
    
    // Define productions
    var p1 : Production = Production(1)
    p1.head = E
    p1.addBodySymbol(E)
    p1.addBodySymbol(plus)
    p1.addBodySymbol(T)
    E.pProductionTable.append(p1)
    
    var p2 : Production = Production(2)
    p2.head = E
    p2.addBodySymbol(T)
    E.pProductionTable.append(p2)
    
    var p3 : Production = Production(3)
    p3.head = T
    p3.addBodySymbol(T)
    p3.addBodySymbol(star)
    p3.addBodySymbol(F)
    T.pProductionTable.append(p3)
    
    var p4 : Production = Production(4)
    p4.head = T
    p4.addBodySymbol(F)
    T.pProductionTable.append(p4)
    
    var p5 : Production = Production(5)
    p5.head = F
    p5.addBodySymbol(lparen)
    p5.addBodySymbol(E)
    p5.addBodySymbol(rparen)
    F.pProductionTable.append(p5)
    
    var p6 : Production = Production(6)
    p6.head = F
    p6.addBodySymbol(id)
    F.pProductionTable.append(p6)
    
    // Create initial item set I0
    var I0 : ItemSet = ItemSet(0)
    var initialItem : LR0Item = LR0Item(E, p1, 0, ItemCategory.CORE)
    I0.itemSet.put(initialItem)
    getClosure(I0)
    
    // Initialize tables
    var pItemSetTable : ArrayList<ItemSet> = ArrayList<ItemSet>()
    pItemSetTable.append(I0)
    var pEdgeTable : ArrayList<TransitionEdge> = ArrayList<TransitionEdge>()
    
    // Call exhaustTransition
    exhaustTransition(I0, pItemSetTable, pEdgeTable)
    
    // Print results
    println("Item Sets:")
    for (set in pItemSetTable) {
        println("State " + set.stateId.toString() + ":")
        for (item in set.itemSet) {
            println("  " + item.production.toString() + ", dot at " + item.dotPosition.toString())
        }
    }
    println("Transition Edges:")
    for (edge in pEdgeTable) {
        println("From " + edge.fromItemSet.stateId.toString() + " on " + edge.driverSymbol.name + " to " + edge.toItemSet.stateId.toString())
    }
}

func containsItemSet(workList : ArrayList<ItemSet>, itemSet : ItemSet) : Bool {
    for (set in workList) {
        if (itemSetsEqual(set, itemSet)) {
            return true
        }
    }
    return false
}


func buildLR0DFA(rootSymbol : NonTerminalSymbol) : DFA {
    // 创建增广文法
    var SPrime : NonTerminalSymbol = NonTerminalSymbol("S'")
    var initialProd : Production = Production(0)
    initialProd.head = SPrime
    initialProd.addBodySymbol(rootSymbol)
    SPrime.pProductionTable.append(initialProd)
    SPrime.numOfProduction = 1

    // 初始化起始项目集
    var startupItemSet : ItemSet = ItemSet(0)
    var initialItem : LR0Item = LR0Item(SPrime, initialProd, 0, ItemCategory.CORE)
    startupItemSet.itemSet.put(initialItem)
    getClosure(startupItemSet)

    // 初始化 DFA
    var dfa : DFA = DFA(startupItemSet)
    var workList : ArrayList<ItemSet> = ArrayList<ItemSet>()
    var processed : HashSet<ItemSet> = HashSet<ItemSet>()
    workList.append(startupItemSet)

    // 构建 DFA
    while (!workList.isEmpty()) {
        var currentItemSet : ItemSet = workList.remove(0)  
        exhaustTransition(currentItemSet, dfa.pItemSetTable, dfa.pEdgeTable)
        processed.put(currentItemSet)  // 标记为已处理
        for (edge in dfa.pEdgeTable) {
            if (itemSetsEqual(edge.fromItemSet, currentItemSet)) {
                if (!processed.contains(edge.toItemSet) && !containsItemSet(workList, edge.toItemSet)) {
                    workList.append(edge.toItemSet)
                }
            }
        }
    }

    return dfa
}

func isSLR1(dfa : DFA) : Bool {
    for (itemSet in dfa.pItemSetTable) {
        var reduceProductions : HashSet<Production> = HashSet<Production>()
        var shiftTerminals : HashSet<TerminalSymbol> = HashSet<TerminalSymbol>()

        for (item in itemSet.itemSet) {
            if (item.dotPosition == Int64(item.production.bodysize)) {
                reduceProductions.put(item.production)
            } else if (item.dotPosition < Int64(item.production.bodysize)) {
                var nextSymbol : GrammarSymbol = item.production.pBodySymbolTable[item.dotPosition]
                if (nextSymbol.symbolType == SymbolType.TERMINAL) {
                    shiftTerminals.put((nextSymbol as TerminalSymbol).getOrThrow())
                }
            }
        }

        if (reduceProductions.size > 1) {
            return false
        }

        if (!reduceProductions.isEmpty() && !shiftTerminals.isEmpty()) {
            var reduceProd : Production = reduceProductions.iterator().next().getOrThrow()
            var nt : NonTerminalSymbol = reduceProd.head
            for (term in shiftTerminals) {
                if (nt.pFollowSet.contains(term)) {
                    return false
                }
            }
        }
    }
    return true
}

func testBuildLR0DFAAndIsSLR1() : Unit {
    // 定义终结符
    var lparen : TerminalSymbol = TerminalSymbol("(", LexemeType.RELOP)
    var rparen : TerminalSymbol = TerminalSymbol(")", LexemeType.RELOP)
    var plus : TerminalSymbol = TerminalSymbol("+", LexemeType.RELOP)
    var star : TerminalSymbol = TerminalSymbol("*", LexemeType.RELOP)
    var id : TerminalSymbol = TerminalSymbol("id", LexemeType.ID)
    
    // 定义非终结符
    var E : NonTerminalSymbol = NonTerminalSymbol("E")
    var T : NonTerminalSymbol = NonTerminalSymbol("T")
    var F : NonTerminalSymbol = NonTerminalSymbol("F")
    
    // 定义产生式
    var p1 : Production = Production(1)
    p1.head = E
    p1.addBodySymbol(E)
    p1.addBodySymbol(plus)
    p1.addBodySymbol(T)
    E.pProductionTable.append(p1)
    
    var p2 : Production = Production(2)
    p2.head = E
    p2.addBodySymbol(T)
    E.pProductionTable.append(p2)
    
    var p3 : Production = Production(3)
    p3.head = T
    p3.addBodySymbol(T)
    p3.addBodySymbol(star)
    p3.addBodySymbol(F)
    T.pProductionTable.append(p3)
    
    var p4 : Production = Production(4)
    p4.head = T
    p4.addBodySymbol(F)
    T.pProductionTable.append(p4)
    
    var p5 : Production = Production(5)
    p5.head = F
    p5.addBodySymbol(lparen)
    p5.addBodySymbol(E)
    p5.addBodySymbol(rparen)
    F.pProductionTable.append(p5)
    
    var p6 : Production = Production(6)
    p6.head = F
    p6.addBodySymbol(id)
    F.pProductionTable.append(p6)
    
    // 构建 DFA
    var dfa : DFA = buildLR0DFA(E)
    
    // 打印结果
    println("LR(0) DFA Item Sets:")
    for (set in dfa.pItemSetTable) {
        println("State " + set.stateId.toString() + ":")
        for (item in set.itemSet) {
            println("  " + item.production.toString() + ", dot at " + item.dotPosition.toString())
        }
    }
    println("Transition Edges:")
    for (edge in dfa.pEdgeTable) {
        println("From " + edge.fromItemSet.stateId.toString() + " on " + edge.driverSymbol.name + " to " + edge.toItemSet.stateId.toString())
    }

    if (isSLR1(dfa)) {
        println("The grammar is SLR(1).")
    } else {
        println("The grammar is not SLR(1).")
    }
}

func fillLRParseTable(dfa : DFA, pActionCellTable : ArrayList<ActionCell>, pGotoCellTable : ArrayList<GotoCell>) : Unit {
    // 处理转移边
    for (edge in dfa.pEdgeTable) {
        var from : ItemSet = edge.fromItemSet
        var to : ItemSet = edge.toItemSet
        var driver : GrammarSymbol = edge.driverSymbol

        if (driver.symbolType == SymbolType.TERMINAL) {
            pActionCellTable.append(ActionCell(from.stateId, driver.name, ActionCategory.SHIFT, to.stateId))
        } else if (driver.symbolType == SymbolType.NONTERMINAL) {
            pGotoCellTable.append(GotoCell(from.stateId, driver.name, to.stateId))
        }
    }

    // 处理归约项
    for (itemSet in dfa.pItemSetTable) {
        for (item in itemSet.itemSet) {
            if (item.dotPosition == Int64(item.production.bodysize)) {
                if (item.nonTerminalSymbol.name == "S'") {
                    pActionCellTable.append(ActionCell(itemSet.stateId, "$", ActionCategory.ACCEPT, 0))
                } else {
                    var nt : NonTerminalSymbol = item.nonTerminalSymbol
                    for (term in nt.pFollowSet) {
                        pActionCellTable.append(ActionCell(itemSet.stateId, term.name, ActionCategory.REDUCE, item.production.productionId))
                    }
                }
            }
        }
    }
}

func testFillLRParseTable() : Unit {
    // 定义终结符
    var lparen : TerminalSymbol = TerminalSymbol("(", LexemeType.RELOP)
    var rparen : TerminalSymbol = TerminalSymbol(")", LexemeType.RELOP)
    var plus : TerminalSymbol = TerminalSymbol("+", LexemeType.RELOP)
    var star : TerminalSymbol = TerminalSymbol("*", LexemeType.RELOP)
    var id : TerminalSymbol = TerminalSymbol("id", LexemeType.ID)
    var eof : TerminalSymbol = TerminalSymbol("$", LexemeType.EOF)

    // 定义非终结符
    var E : NonTerminalSymbol = NonTerminalSymbol("E")
    var T : NonTerminalSymbol = NonTerminalSymbol("T")
    var F : NonTerminalSymbol = NonTerminalSymbol("F")

    // 定义产生式
    var p1 : Production = Production(1)
    p1.head = E
    p1.addBodySymbol(E)
    p1.addBodySymbol(plus)
    p1.addBodySymbol(T)
    E.pProductionTable.append(p1)

    var p2 : Production = Production(2)
    p2.head = E
    p2.addBodySymbol(T)
    E.pProductionTable.append(p2)

    var p3 : Production = Production(3)
    p3.head = T
    p3.addBodySymbol(T)
    p3.addBodySymbol(star)
    p3.addBodySymbol(F)
    T.pProductionTable.append(p3)

    var p4 : Production = Production(4)
    p4.head = T
    p4.addBodySymbol(F)
    T.pProductionTable.append(p4)

    var p5 : Production = Production(5)
    p5.head = F
    p5.addBodySymbol(lparen)
    p5.addBodySymbol(E)
    p5.addBodySymbol(rparen)
    F.pProductionTable.append(p5)

    var p6 : Production = Production(6)
    p6.head = F
    p6.addBodySymbol(id)
    F.pProductionTable.append(p6)

    // 收集文法符号
    var grammarSymbols : ArrayList<GrammarSymbol> = ArrayList<GrammarSymbol>()
    grammarSymbols.append(E)
    grammarSymbols.append(T)
    grammarSymbols.append(F)
    grammarSymbols.append(lparen)
    grammarSymbols.append(rparen)
    grammarSymbols.append(plus)
    grammarSymbols.append(star)
    grammarSymbols.append(id)
    grammarSymbols.append(eof)

    // 计算 First 和 Follow 集
    var canDeriveEpsilonMap : HashMap<NonTerminalSymbol, Bool> = HashMap<NonTerminalSymbol, Bool>()
    computeAllFirstSets(grammarSymbols, canDeriveEpsilonMap)
    computeAllFollowSets(grammarSymbols, E, canDeriveEpsilonMap)

    // 构建 LR(0) DFA
    var dfa : DFA = buildLR0DFA(E)

    // 填充解析表
    var pActionCellTable : ArrayList<ActionCell> = ArrayList<ActionCell>()
    var pGotoCellTable : ArrayList<GotoCell> = ArrayList<GotoCell>()
    fillLRParseTable(dfa, pActionCellTable, pGotoCellTable)

    // 打印动作表
    println("Action Table:")
    for (cell in pActionCellTable) {
        var action : String = ""
        if (cell.actionType == ActionCategory.SHIFT) {
            action = "SHIFT " + cell.id.toString()
        } else if (cell.actionType == ActionCategory.REDUCE) {
            action = "REDUCE " + cell.id.toString()
        } else if (cell.actionType == ActionCategory.ACCEPT) {
            action = "ACCEPT"
        }
        println("State " + cell.stateId.toString() + ", " + cell.terminalSymbolName + ": " + action)
    }

    // 打印 GOTO 表
    println("Goto Table:")
    for (cell in pGotoCellTable) {
        println("State " + cell.stateId.toString() + ", " + cell.nonTerminalSymbolName + ": " + cell.nextStateid.toString())
    }
}

// 验证文法
// program → stmt-seq
// stmt-seq → stmt | stmt-seq ; stmt
// stmt → if-stmt | repeat-stmt | assign-stmt | read-stmt | write-stmt
// if-stmt → if ( exp ) then stmt-seq end | if ( exp ) then stmt-seq else stmt-seq end
// repeat-stmt → repeat stmt-seq until ( exp )
// assign-stmt → identifier := simple-exp
// read-stmt → read identifier
// write-stmt → write simple-exp
// exp → simple-exp relop simple-exp
// relop → < | > | = | <= | >= | <>
// simple-exp → term | simple-exp addop term
// term → factor | term mulop factor
// factor → ( simple-exp ) | identifier | number
// addop → + | -
// mulop → * | /

func testLRParserForTINY() : Unit {
    // Define terminals
    var ifSym : TerminalSymbol = TerminalSymbol("if", LexemeType.IF)
    var thenSym : TerminalSymbol = TerminalSymbol("then", LexemeType.NULL)
    var elseSym : TerminalSymbol = TerminalSymbol("else", LexemeType.ELSE)
    var endSym : TerminalSymbol = TerminalSymbol("end", LexemeType.NULL)
    var repeatSym : TerminalSymbol = TerminalSymbol("repeat", LexemeType.NULL)
    var untilSym : TerminalSymbol = TerminalSymbol("until", LexemeType.NULL)
    var readSym : TerminalSymbol = TerminalSymbol("read", LexemeType.NULL)
    var writeSym : TerminalSymbol = TerminalSymbol("write", LexemeType.NULL)
    var assignSym : TerminalSymbol = TerminalSymbol(":=", LexemeType.RELOP)
    var plusSym : TerminalSymbol = TerminalSymbol("+", LexemeType.RELOP)
    var minusSym : TerminalSymbol = TerminalSymbol("-", LexemeType.RELOP)
    var multSym : TerminalSymbol = TerminalSymbol("*", LexemeType.RELOP)
    var divSym : TerminalSymbol = TerminalSymbol("/", LexemeType.RELOP)
    var ltSym : TerminalSymbol = TerminalSymbol("<", LexemeType.RELOP)
    var gtSym : TerminalSymbol = TerminalSymbol(">", LexemeType.RELOP)
    var eqSym : TerminalSymbol = TerminalSymbol("=", LexemeType.RELOP)
    var leSym : TerminalSymbol = TerminalSymbol("<=", LexemeType.RELOP)
    var geSym : TerminalSymbol = TerminalSymbol(">=", LexemeType.RELOP)
    var neSym : TerminalSymbol = TerminalSymbol("<>", LexemeType.RELOP)
    var lparenSym : TerminalSymbol = TerminalSymbol("(", LexemeType.NULL)
    var rparenSym : TerminalSymbol = TerminalSymbol(")", LexemeType.NULL)
    var semiSym : TerminalSymbol = TerminalSymbol(";", LexemeType.NULL)
    var idSym : TerminalSymbol = TerminalSymbol("identifier", LexemeType.ID)
    var numSym : TerminalSymbol = TerminalSymbol("number", LexemeType.NUM)
    var eofSym : TerminalSymbol = TerminalSymbol("$", LexemeType.EOF)

    // Define non-terminals
    var program : NonTerminalSymbol = NonTerminalSymbol("program")
    var stmtSeq : NonTerminalSymbol = NonTerminalSymbol("stmt-seq")
    var stmt : NonTerminalSymbol = NonTerminalSymbol("stmt")
    var ifStmt : NonTerminalSymbol = NonTerminalSymbol("if-stmt")
    var repeatStmt : NonTerminalSymbol = NonTerminalSymbol("repeat-stmt")
    var assignStmt : NonTerminalSymbol = NonTerminalSymbol("assign-stmt")
    var readStmt : NonTerminalSymbol = NonTerminalSymbol("read-stmt")
    var writeStmt : NonTerminalSymbol = NonTerminalSymbol("write-stmt")
    var exp : NonTerminalSymbol = NonTerminalSymbol("exp")
    var relop : NonTerminalSymbol = NonTerminalSymbol("relop")
    var simpleExp : NonTerminalSymbol = NonTerminalSymbol("simple-exp")
    var term : NonTerminalSymbol = NonTerminalSymbol("term")
    var factor : NonTerminalSymbol = NonTerminalSymbol("factor")
    var addop : NonTerminalSymbol = NonTerminalSymbol("addop")
    var mulop : NonTerminalSymbol = NonTerminalSymbol("mulop")

    // Define productions
    var p1 : Production = Production(1)
    p1.head = program
    p1.addBodySymbol(stmtSeq)
    program.addProduction(p1)

    var p2 : Production = Production(2)
    p2.head = stmtSeq
    p2.addBodySymbol(stmt)
    stmtSeq.addProduction(p2)

    var p3 : Production = Production(3)
    p3.head = stmtSeq
    p3.addBodySymbol(stmtSeq)
    p3.addBodySymbol(semiSym)
    p3.addBodySymbol(stmt)
    stmtSeq.addProduction(p3)

    var p4 : Production = Production(4)
    p4.head = stmt
    p4.addBodySymbol(ifStmt)
    stmt.addProduction(p4)

    var p5 : Production = Production(5)
    p5.head = stmt
    p5.addBodySymbol(repeatStmt)
    stmt.addProduction(p5)

    var p6 : Production = Production(6)
    p6.head = stmt
    p6.addBodySymbol(assignStmt)
    stmt.addProduction(p6)

    var p7 : Production = Production(7)
    p7.head = stmt
    p7.addBodySymbol(readStmt)
    stmt.addProduction(p7)

    var p8 : Production = Production(8)
    p8.head = stmt
    p8.addBodySymbol(writeStmt)
    stmt.addProduction(p8)

    var p9 : Production = Production(9)
    p9.head = ifStmt
    p9.addBodySymbol(ifSym)
    p9.addBodySymbol(lparenSym)
    p9.addBodySymbol(exp)
    p9.addBodySymbol(rparenSym)
    p9.addBodySymbol(thenSym)
    p9.addBodySymbol(stmtSeq)
    p9.addBodySymbol(endSym)
    ifStmt.addProduction(p9)

    var p10 : Production = Production(10)
    p10.head = ifStmt
    p10.addBodySymbol(ifSym)
    p10.addBodySymbol(lparenSym)
    p10.addBodySymbol(exp)
    p10.addBodySymbol(rparenSym)
    p10.addBodySymbol(thenSym)
    p10.addBodySymbol(stmtSeq)
    p10.addBodySymbol(elseSym)
    p10.addBodySymbol(stmtSeq)
    p10.addBodySymbol(endSym)
    ifStmt.addProduction(p10)

    var p11 : Production = Production(11)
    p11.head = repeatStmt
    p11.addBodySymbol(repeatSym)
    p11.addBodySymbol(stmtSeq)
    p11.addBodySymbol(untilSym)
    p11.addBodySymbol(lparenSym)
    p11.addBodySymbol(exp)
    p11.addBodySymbol(rparenSym)
    repeatStmt.addProduction(p11)

    var p12 : Production = Production(12)
    p12.head = assignStmt
    p12.addBodySymbol(idSym)
    p12.addBodySymbol(assignSym)
    p12.addBodySymbol(simpleExp)
    assignStmt.addProduction(p12)

    var p13 : Production = Production(13)
    p13.head = readStmt
    p13.addBodySymbol(readSym)
    p13.addBodySymbol(idSym)
    readStmt.addProduction(p13)

    var p14 : Production = Production(14)
    p14.head = writeStmt
    p14.addBodySymbol(writeSym)
    p14.addBodySymbol(simpleExp)
    writeStmt.addProduction(p14)

    var p15 : Production = Production(15)
    p15.head = exp
    p15.addBodySymbol(simpleExp)
    p15.addBodySymbol(relop)
    p15.addBodySymbol(simpleExp)
    exp.addProduction(p15)

    var p16 : Production = Production(16)
    p16.head = relop
    p16.addBodySymbol(ltSym)
    relop.addProduction(p16)

    var p17 : Production = Production(17)
    p17.head = relop
    p17.addBodySymbol(gtSym)
    relop.addProduction(p17)

    var p18 : Production = Production(18)
    p18.head = relop
    p18.addBodySymbol(eqSym)
    relop.addProduction(p18)

    var p19 : Production = Production(19)
    p19.head = relop
    p19.addBodySymbol(leSym)
    relop.addProduction(p19)

    var p20 : Production = Production(20)
    p20.head = relop
    p20.addBodySymbol(geSym)
    relop.addProduction(p20)

    var p21 : Production = Production(21)
    p21.head = relop
    p21.addBodySymbol(neSym)
    relop.addProduction(p21)

    var p22 : Production = Production(22)
    p22.head = simpleExp
    p22.addBodySymbol(term)
    simpleExp.addProduction(p22)

    var p23 : Production = Production(23)
    p23.head = simpleExp
    p23.addBodySymbol(simpleExp)
    p23.addBodySymbol(addop)
    p23.addBodySymbol(term)
    simpleExp.addProduction(p23)

    var p24 : Production = Production(24)
    p24.head = term
    p24.addBodySymbol(factor)
    term.addProduction(p24)

    var p25 : Production = Production(25)
    p25.head = term
    p25.addBodySymbol(term)
    p25.addBodySymbol(mulop)
    p25.addBodySymbol(factor)
    term.addProduction(p25)

    var p26 : Production = Production(26)
    p26.head = factor
    p26.addBodySymbol(lparenSym)
    p26.addBodySymbol(simpleExp)
    p26.addBodySymbol(rparenSym)
    factor.addProduction(p26)

    var p27 : Production = Production(27)
    p27.head = factor
    p27.addBodySymbol(idSym)
    factor.addProduction(p27)

    var p28 : Production = Production(28)
    p28.head = factor
    p28.addBodySymbol(numSym)
    factor.addProduction(p28)

    var p29 : Production = Production(29)
    p29.head = addop
    p29.addBodySymbol(plusSym)
    addop.addProduction(p29)

    var p30 : Production = Production(30)
    p30.head = addop
    p30.addBodySymbol(minusSym)
    addop.addProduction(p30)

    var p31 : Production = Production(31)
    p31.head = mulop
    p31.addBodySymbol(multSym)
    mulop.addProduction(p31)

    var p32 : Production = Production(32)
    p32.head = mulop
    p32.addBodySymbol(divSym)
    mulop.addProduction(p32)

    // Collect grammar symbols
    var grammarSymbols : ArrayList<GrammarSymbol> = ArrayList<GrammarSymbol>()
    grammarSymbols.append(program)
    grammarSymbols.append(stmtSeq)
    grammarSymbols.append(stmt)
    grammarSymbols.append(ifStmt)
    grammarSymbols.append(repeatStmt)
    grammarSymbols.append(assignStmt)
    grammarSymbols.append(readStmt)
    grammarSymbols.append(writeStmt)
    grammarSymbols.append(exp)
    grammarSymbols.append(relop)
    grammarSymbols.append(simpleExp)
    grammarSymbols.append(term)
    grammarSymbols.append(factor)
    grammarSymbols.append(addop)
    grammarSymbols.append(mulop)
    grammarSymbols.append(ifSym)
    grammarSymbols.append(thenSym)
    grammarSymbols.append(elseSym)
    grammarSymbols.append(endSym)
    grammarSymbols.append(repeatSym)
    grammarSymbols.append(untilSym)
    grammarSymbols.append(readSym)
    grammarSymbols.append(writeSym)
    grammarSymbols.append(assignSym)
    grammarSymbols.append(plusSym)
    grammarSymbols.append(minusSym)
    grammarSymbols.append(multSym)
    grammarSymbols.append(divSym)
    grammarSymbols.append(ltSym)
    grammarSymbols.append(gtSym)
    grammarSymbols.append(eqSym)
    grammarSymbols.append(leSym)
    grammarSymbols.append(geSym)
    grammarSymbols.append(neSym)
    grammarSymbols.append(lparenSym)
    grammarSymbols.append(rparenSym)
    grammarSymbols.append(semiSym)
    grammarSymbols.append(idSym)
    grammarSymbols.append(numSym)
    grammarSymbols.append(eofSym)

    // Step 1: Compute First and Follow Sets
    println("=== First Sets ===")
    var canDeriveEpsilonMap : HashMap<NonTerminalSymbol, Bool> = HashMap<NonTerminalSymbol, Bool>()
    computeAllFirstSets(grammarSymbols, canDeriveEpsilonMap)
    for (symbol in grammarSymbols) {
        if (symbol.symbolType == SymbolType.NONTERMINAL) {
            var nt : NonTerminalSymbol = (symbol as NonTerminalSymbol).getOrThrow()
            print(nt.name + ": ")
            for (term in nt.pFirstSet) {
                print(term.name + " ")
            }
            println()
        }
    }

    println("=== Follow Sets ===")
    computeAllFollowSets(grammarSymbols, program, canDeriveEpsilonMap)
    for (symbol in grammarSymbols) {
        if (symbol.symbolType == SymbolType.NONTERMINAL) {
            var nt : NonTerminalSymbol = (symbol as NonTerminalSymbol).getOrThrow()
            print(nt.name + ": ")
            for (term in nt.pFollowSet) {
                print(term.name + " ")
            }
            println()
        }
    }

    // Step 2: Build LR(0) DFA (includes getClosure and exhaustTransition)
    println("=== DFA Item Sets ===")
    var dfa : DFA = buildLR0DFA(program)
    for (itemSet in dfa.pItemSetTable) {
        println("State " + itemSet.stateId.toString() + ":")
        for (item in itemSet.itemSet) {
            println("  " + item.toString())
        }
    }

    println("=== Transition Edges ===")
    for (edge in dfa.pEdgeTable) {
        println("From " + edge.fromItemSet.stateId.toString() + " on " + edge.driverSymbol.name + " to " + edge.toItemSet.stateId.toString())
    }

    // Step 3: Check if SLR(1)
    println("=== SLR(1) Check ===")
    var isSLR : Bool = isSLR1(dfa)
    if (isSLR) {
        println("The grammar is SLR(1)")
    } else {
        println("The grammar is not SLR(1)")
    }

    // Step 4: Fill Parse Tables
    println("=== Action Table ===")
    var pActionCellTable : ArrayList<ActionCell> = ArrayList<ActionCell>()
    var pGotoCellTable : ArrayList<GotoCell> = ArrayList<GotoCell>()
    fillLRParseTable(dfa, pActionCellTable, pGotoCellTable)
    for (cell in pActionCellTable) {
        var action : String = ""
        if (cell.actionType == ActionCategory.SHIFT) {
            action = "SHIFT " + cell.id.toString()
        } else if (cell.actionType == ActionCategory.REDUCE) {
            action = "REDUCE " + cell.id.toString()
        } else if (cell.actionType == ActionCategory.ACCEPT) {
            action = "ACCEPT"
        }
        println("State " + cell.stateId.toString() + ", " + cell.terminalSymbolName + ": " + action)
    }

    println("=== Goto Table ===")
    for (cell in pGotoCellTable) {
        println("State " + cell.stateId.toString() + ", " + cell.nonTerminalSymbolName + ": " + cell.nextStateid.toString())
    }
}


main() {
    // println("---------------------测试文法--------------------------")
    // println("E -> E + T | T")
    // println("T -> T * F | F")
    // println("F -> ( E ) | id")
    // println("------------------------------------------------------")
    // println("")
    // testGetClosure()
    // println("------------------------------------------------------")
    // println("")
    // testExhaustTransition()
    // println("------------------------------------------------------")
    // println("")
    // testBuildLR0DFAAndIsSLR1()
    // println("------------------------------------------------------")
    // println("")
    // testFillLRParseTable()
    testLRParserForTINY()
}




