package t1

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

open class GrammarSymbol<: Equatable<GrammarSymbol>{
    
    var name : String       //name of the symbol
    var symbolType : SymbolType  //type of the symbol

    public init(name : String, symbolType : SymbolType) {
        this.name = name
        this.symbolType = symbolType
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
    
    public func hashCode(): Int64 {
        var s : String = name + symbolType.toString() + category.toString()
        return s.hashCode()
    }

    public operator func ==(rhs: TerminalSymbol): Bool {
        return this.name == rhs.name && this.symbolType == rhs.symbolType && this.category == rhs.category
    }

    public operator func !=(rhs: TerminalSymbol): Bool {
        return this.name != rhs.name && this.symbolType == rhs.symbolType && this.category == rhs.category
    }
}

class Production {

    var productionId : Int32                                // id of the production
    var bodysize : Int32
    var pBodySymbolTable : ArrayList<GrammarSymbol>         // production set
    var pFirstSet : HashSet<TerminalSymbol>                 // first set of the production

    public init(productionId : Int32) {
        this.bodysize = 0
        this.productionId = productionId
        this.pBodySymbolTable = ArrayList<GrammarSymbol>()
        this.pFirstSet = HashSet<TerminalSymbol>()
    }

    public func addBodySymbol(symbol : GrammarSymbol) : Unit {
        this.pBodySymbolTable.append(symbol)
        this.bodysize += 1
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

    public func hashCode(): Int64 {
        var s : String = name + symbolType.toString() + this.numOfProduction.toString() + this.canDeriveEpsilon.toString()
        return s.hashCode()
    }

    public operator func ==(rhs: NonTerminalSymbol): Bool {
        return this.name == rhs.name && this.symbolType == rhs.symbolType && this.numOfProduction == rhs.numOfProduction && this.canDeriveEpsilon == rhs.canDeriveEpsilon
    }

    public operator func !=(rhs: NonTerminalSymbol): Bool {
        return this.name != rhs.name && this.symbolType == rhs.symbolType && this.numOfProduction != rhs.numOfProduction && this.canDeriveEpsilon != rhs.canDeriveEpsilon 
    }

    func addProduction(p : Production) : Unit {
        this.pProductionTable.append(p)
    }
}

// A utility function that gets or creates epsilon symbols
func getEpsilonSymbol() : TerminalSymbol {
    var epsilon : TerminalSymbol = TerminalSymbol("epsilon", LexemeType.NULL)
    return epsilon
}

//chech whether the FIRST set contains epsilon
func containsEpsilon(firstSet : HashSet<TerminalSymbol>) : Bool {
    for (symbol in firstSet) {
        if (symbol.name == "epsilon") {
            return true
        }
    }
    return false
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


func testProductionFirstSet() : Unit {
    println("testProductionFirstSet...")
    var a : TerminalSymbol = TerminalSymbol("a", LexemeType.ID)
    var A : NonTerminalSymbol = NonTerminalSymbol("A")
    A.pFirstSet.put(a)
    var p1 : Production = Production(1)
    p1.addBodySymbol(a)
    var epsilonMap : HashMap<NonTerminalSymbol, Bool> = HashMap<NonTerminalSymbol, Bool>()
    computeProductionFirstSet(p1, epsilonMap)

    epsilonMap.put(A, true)


    for (symbol in p1.pFirstSet) {
        println(symbol.name)
    }

}

// func computeAllFirstSets(grammarSymbols : ArrayList<GrammarSymbol>, canDriveEpsilonMap : HashMap<NonTerminalSymbol, Bool>) : Unit {
//     var changed : Bool = true
//     while (changed) {
//         changed = false
//         for (symbol in grammarSymbols) {
//             if (symbol.symbolType == SymbolType.NONTERMINAL) {
//                 var nonTerminal : NonTerminalSymbol = (symbol as NonTerminalSymbol).getOrThrow()
//                 var oldFirstSize : Int32 = Int32(nonTerminal.pFirstSet.size)
//                 var oldCanDeriveEpsilon : Bool = nonTerminal.canDeriveEpsilon
//                 nonTerminal.canDeriveEpsilon = false
//                 for (production in nonTerminal.pProductionTable) {
//                     if (production.bodysize == 0) {
//                         nonTerminal.canDeriveEpsilon = true
//                     } else {
//                         computeProductionFirstSet(production, canDriveEpsilonMap)
//                         for (terminal in production.pFirstSet) {
//                             nonTerminal.pFirstSet.put(terminal)
//                         }
//                         var prodcanDeriveEpsilon : Bool = true
//                         for (prodSymbol in production.pBodySymbolTable) {
//                             if (prodSymbol.symbolType == SymbolType.TERMINAL) {
//                                 prodcanDeriveEpsilon = false
//                                 break
//                             } else if (prodSymbol.symbolType == SymbolType.NONTERMINAL) {
//                                 var prodNonTerminal : NonTerminalSymbol = (prodSymbol as NonTerminalSymbol).getOrThrow()
//                                 if (!canDriveEpsilonMap[prodNonTerminal]) {
//                                     prodcanDeriveEpsilon = false
//                                     break
//                                 }
//                             }
//                         }
//                         if (prodcanDeriveEpsilon) {
//                             nonTerminal.canDeriveEpsilon = true
//                         }
//                     }
//                 }
//                 if (Int32(nonTerminal.pFirstSet.size) > oldFirstSize || nonTerminal.canDeriveEpsilon != oldCanDeriveEpsilon) {
//                     changed = true
//                 }
//             }
//         }
//         for (symbol in grammarSymbols) {
//             if (symbol.symbolType == SymbolType.NONTERMINAL) {
//                 var nonTerminal : NonTerminalSymbol = (symbol as NonTerminalSymbol).getOrThrow()
//                 canDriveEpsilonMap[nonTerminal] = nonTerminal.canDeriveEpsilon
//             }
//         }
//     }
// }

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

func testNonTerminalSymbol() : Unit {
    println("testNonTerminalSymbol...")
    var a : TerminalSymbol = TerminalSymbol("a", LexemeType.ID)
    var b : TerminalSymbol = TerminalSymbol("b", LexemeType.ID)
    var A : NonTerminalSymbol = NonTerminalSymbol("A")
    var p1 : Production = Production(1)
    p1.addBodySymbol(a)
    var p2 : Production = Production(2)
    p2.addBodySymbol(b)
    A.pProductionTable.append(p1)
    A.pProductionTable.append(p2)
    A.numOfProduction = 2
    var grammarSymbols : ArrayList<GrammarSymbol> = ArrayList<GrammarSymbol>()
    grammarSymbols.append(a)
    grammarSymbols.append(b)
    grammarSymbols.append(A)
    var canDriveEpsilonMap : HashMap<NonTerminalSymbol, Bool> = HashMap<NonTerminalSymbol, Bool>()
    computeAllFirstSets(grammarSymbols, canDriveEpsilonMap)

    for (t in A.pFirstSet) {
        println(t.name)
    }
}

// func computeAllFollowSets(grammarSymbols : ArrayList<GrammarSymbol>, rootSymbol : NonTerminalSymbol, canDriveEpsilonMap : HashMap<NonTerminalSymbol, Bool>) : Unit {
//     var eof : TerminalSymbol = TerminalSymbol("", LexemeType.EOF)
//     for (symbol in grammarSymbols) {
//         if (symbol.symbolType == SymbolType.TERMINAL && symbol.name == "$") {
//             eof = (symbol as TerminalSymbol).getOrThrow()
//             rootSymbol.pFollowSet.put(eof)
//             break;
//         }
//     }
//     bool changed : Bool = true
//     while (changed) {
//         changed = false
//         for (symbol in grammarSymbols) {
//             if (symbol.symbolType == SymbolType.NONTERMINAL) {
//                 var nonTerminal : NonTerminalSymbol = (symbol as NonTerminalSymbol).getOrThrow()
//                 var oldFollowSize : Int32 = Int32(nonTerminal.pFollowSet.size)

//                 for (sym in grammarSymbols) {
//                     if (sym.symbolType == SymbolType.NONTERMINAL) {
//                         var head : NonTerminalSymbol = (sym as NonTerminalSymbol).getOrThrow()
//                         for (production in head.pProductionTable) {
//                             for
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }


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


func testNonTerminalFollow() : Unit {
    println("testNonTerminalFollow")
    var a : TerminalSymbol = TerminalSymbol("a", LexemeType.ID)
    var b : TerminalSymbol = TerminalSymbol("b", LexemeType.ID)
    var eof : TerminalSymbol = TerminalSymbol("$", LexemeType.EOF)
    var S : NonTerminalSymbol = NonTerminalSymbol("S")
    var A : NonTerminalSymbol = NonTerminalSymbol("A")

    var p1 : Production = Production(1)
    p1.pBodySymbolTable.append(A)
    p1.pBodySymbolTable.append(b)
    S.pProductionTable.append(p1)
    S.numOfProduction = 1
    
    var p2 : Production = Production(2)
    p2.pBodySymbolTable.append(a)
    A.pProductionTable.append(p2)
    A.numOfProduction = 1

    var grammarSymbols : ArrayList<GrammarSymbol> = ArrayList<GrammarSymbol>()
    grammarSymbols.append(a)
    grammarSymbols.append(b)
    grammarSymbols.append(eof)
    grammarSymbols.append(S)
    grammarSymbols.append(A)
    
    var canDeriveEpsilonMap : HashMap<NonTerminalSymbol, Bool> = HashMap<NonTerminalSymbol, Bool>()
    computeAllFirstSets(grammarSymbols, canDeriveEpsilonMap)
    computeAllFollowSets(grammarSymbols, S, canDeriveEpsilonMap)

    for (symbol in A.pFollowSet) {
        println(symbol.name)
    }
}



func testArithmeticFirstSets() : Unit {
    println("Testing computeAllFirstSets for Arithmetic Grammar")

    // 定义终结符
    var id : TerminalSymbol = TerminalSymbol("id", LexemeType.ID)
    var lparen : TerminalSymbol = TerminalSymbol("(", LexemeType.RELOP)
    var rparen : TerminalSymbol = TerminalSymbol(")", LexemeType.RELOP)
    var plus : TerminalSymbol = TerminalSymbol("+", LexemeType.RELOP)
    var star : TerminalSymbol = TerminalSymbol("*", LexemeType.RELOP)
    var eof : TerminalSymbol = TerminalSymbol("$", LexemeType.EOF)

    // 定义非终结符
    var E : NonTerminalSymbol = NonTerminalSymbol("E")
    var T : NonTerminalSymbol = NonTerminalSymbol("T")
    var F : NonTerminalSymbol = NonTerminalSymbol("F")

    // 定义产生式
    var p1 : Production = Production(1)
    p1.addBodySymbol(E)
    p1.addBodySymbol(plus)
    p1.addBodySymbol(T)
    E.pProductionTable.append(p1)
    E.numOfProduction += 1

    var p2 : Production = Production(2)
    p2.addBodySymbol(T)
    E.pProductionTable.append(p2)
    E.numOfProduction += 1

    var p3 : Production = Production(3)
    p3.addBodySymbol(T)
    p3.addBodySymbol(star)
    p3.addBodySymbol(F)
    T.pProductionTable.append(p3)
    T.numOfProduction += 1

    var p4 : Production = Production(4)
    p4.addBodySymbol(F)
    T.pProductionTable.append(p4)
    T.numOfProduction += 1

    var p5 : Production = Production(5)
    p5.addBodySymbol(lparen)
    p5.addBodySymbol(E)
    p5.addBodySymbol(rparen)
    F.pProductionTable.append(p5)
    F.numOfProduction += 1

    var p6 : Production = Production(6)
    p6.addBodySymbol(id)
    F.pProductionTable.append(p6)
    F.numOfProduction += 1

    // 创建 grammarSymbols
    var grammarSymbols : ArrayList<GrammarSymbol> = ArrayList<GrammarSymbol>()
    grammarSymbols.append(id)
    grammarSymbols.append(lparen)
    grammarSymbols.append(rparen)
    grammarSymbols.append(plus)
    grammarSymbols.append(star)
    grammarSymbols.append(eof)
    grammarSymbols.append(E)
    grammarSymbols.append(T)
    grammarSymbols.append(F)

    // 计算 FIRST 集
    var canDeriveEpsilonMap : HashMap<NonTerminalSymbol, Bool> = HashMap<NonTerminalSymbol, Bool>()

    computeAllFirstSets(grammarSymbols, canDeriveEpsilonMap)

    // 检查 FIRST 集
    println("FIRST set of E:")
    for (t in E.pFirstSet) {
        println(t.name)
    }
    // 预期：( 和 id

    println("FIRST set of T:")
    for (t in T.pFirstSet) {
        println(t.name)
    }
    // 预期：( 和 id

    println("FIRST set of F:")
    for (t in F.pFirstSet) {
        println(t.name)
    }
    // 预期：( 和 id

    // 检查 canDeriveEpsilon
    println("Can E derive epsilon: " + E.canDeriveEpsilon.toString())
    println("Can T derive epsilon: " + T.canDeriveEpsilon.toString())
    println("Can F derive epsilon: " + F.canDeriveEpsilon.toString())
    // 预期：false, false, false
}

func testArithmeticProductionFirstSet() : Unit {
    println("Testing computeProductionFirstSet for Production F -> ( E )")

    // 定义终结符
    var lparen : TerminalSymbol = TerminalSymbol("(", LexemeType.RELOP)
    var rparen : TerminalSymbol = TerminalSymbol(")", LexemeType.RELOP)

    // 定义非终结符
    var E : NonTerminalSymbol = NonTerminalSymbol("E")
    var F : NonTerminalSymbol = NonTerminalSymbol("F")

    // 设置 E 的 FIRST 集（假设已计算）
    E.pFirstSet.put(lparen)
    var id : TerminalSymbol = TerminalSymbol("id", LexemeType.ID)
    E.pFirstSet.put(id)

    // 定义产生式 F -> ( E )
    var p5 : Production = Production(5)
    p5.addBodySymbol(lparen)
    p5.addBodySymbol(E)
    p5.addBodySymbol(rparen)
    F.pProductionTable.append(p5)
    F.numOfProduction += 1

    // 创建 grammarSymbols
    var grammarSymbols : ArrayList<GrammarSymbol> = ArrayList<GrammarSymbol>()
    grammarSymbols.append(lparen)
    grammarSymbols.append(rparen)
    grammarSymbols.append(id)
    grammarSymbols.append(E)
    grammarSymbols.append(F)

    // 计算 FIRST 集
    var canDeriveEpsilonMap : HashMap<NonTerminalSymbol, Bool> = HashMap<NonTerminalSymbol, Bool>()
    canDeriveEpsilonMap.put(E, false) // E 不能推导 epsilon
    canDeriveEpsilonMap.put(F, false)
    computeProductionFirstSet(p5, canDeriveEpsilonMap)

    // 检查 p5 的 FIRST 集
    println("FIRST set of Production F -> ( E ):")
    for (t in p5.pFirstSet) {
        println(t.name)
    }
    // 预期：(
}

func testArithmeticFollowSets() : Unit {
    println("Testing computeAllFollowSets for Arithmetic Grammar")

    // 定义终结符
    var id : TerminalSymbol = TerminalSymbol("id", LexemeType.ID)
    var lparen : TerminalSymbol = TerminalSymbol("(", LexemeType.RELOP)
    var rparen : TerminalSymbol = TerminalSymbol(")", LexemeType.RELOP)
    var plus : TerminalSymbol = TerminalSymbol("+", LexemeType.RELOP)
    var star : TerminalSymbol = TerminalSymbol("*", LexemeType.RELOP)
    var eof : TerminalSymbol = TerminalSymbol("$", LexemeType.EOF)

    // 定义非终结符
    var E : NonTerminalSymbol = NonTerminalSymbol("E")
    var T : NonTerminalSymbol = NonTerminalSymbol("T")
    var F : NonTerminalSymbol = NonTerminalSymbol("F")

    // 定义产生式
    var p1 : Production = Production(1)
    p1.addBodySymbol(E)
    p1.addBodySymbol(plus)
    p1.addBodySymbol(T)
    E.pProductionTable.append(p1)
    E.numOfProduction += 1

    var p2 : Production = Production(2)
    p2.addBodySymbol(T)
    E.pProductionTable.append(p2)
    E.numOfProduction += 1

    var p3 : Production = Production(3)
    p3.addBodySymbol(T)
    p3.addBodySymbol(star)
    p3.addBodySymbol(F)
    T.pProductionTable.append(p3)
    T.numOfProduction += 1

    var p4 : Production = Production(4)
    p4.addBodySymbol(F)
    T.pProductionTable.append(p4)
    T.numOfProduction += 1

    var p5 : Production = Production(5)
    p5.addBodySymbol(lparen)
    p5.addBodySymbol(E)
    p5.addBodySymbol(rparen)
    F.pProductionTable.append(p5)
    F.numOfProduction += 1

    var p6 : Production = Production(6)
    p6.addBodySymbol(id)
    F.pProductionTable.append(p6)
    F.numOfProduction += 1

    // 创建 grammarSymbols
    var grammarSymbols : ArrayList<GrammarSymbol> = ArrayList<GrammarSymbol>()
    grammarSymbols.append(id)
    grammarSymbols.append(lparen)
    grammarSymbols.append(rparen)
    grammarSymbols.append(plus)
    grammarSymbols.append(star)
    grammarSymbols.append(eof)
    grammarSymbols.append(E)
    grammarSymbols.append(T)
    grammarSymbols.append(F)

    // 计算 FIRST 和 FOLLOW 集
    var canDeriveEpsilonMap : HashMap<NonTerminalSymbol, Bool> = HashMap<NonTerminalSymbol, Bool>()
    computeAllFirstSets(grammarSymbols, canDeriveEpsilonMap)
    computeAllFollowSets(grammarSymbols, E, canDeriveEpsilonMap)

    // 检查 FOLLOW 集
    println("FOLLOW set of E:")
    for (t in E.pFollowSet) {
        println(t.name)
    }
    // 预期：+, ), $

    println("FOLLOW set of T:")
    for (t in T.pFollowSet) {
        println(t.name)
    }
    // 预期：*, +, ), $

    println("FOLLOW set of F:")
    for (t in F.pFollowSet) {
        println(t.name)
    }
    // 预期：*, +, ), $
}


main() {
    // testProductionFirstSet()
    // testNonTerminalSymbol()
    // testNonTerminalFollow()
    testArithmeticProductionFirstSet()

    testArithmeticFirstSets()

    testArithmeticFollowSets()
}