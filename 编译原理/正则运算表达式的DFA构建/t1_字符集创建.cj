import std.sort.*
import std.random.*
import std.collection.*
import std.math.*

class CharSet {
    var indexId : Int32
    var segmentId : Int32
    var fromChar : Rune
    var toChar : Rune

    public init(indexId : Int32, segmentId : Int32, fromChar : Rune, toChar : Rune) {
        this.indexId = indexId
        this.segmentId = segmentId
        this.fromChar = fromChar
        this.toChar = toChar
    }
};

var pCharSetTable = LinkedList<CharSet>()

var nextCharSetId : Int32 = 1

class Segment {
    var from : Rune
    var to : Rune

    public init(from : Rune, to : Rune) {
        this.from = from
        this.to = to
    }

    public func setFrom(from : Rune) {
        this.from = from
    }

    public func setTo(to : Rune) {
        this.to = to
    }
}


// 辅助函数：合并段
func mergeSegments(segments : ArrayList<Segment>) : ArrayList<Segment> {
    
    var len : Int64 = segments.size

    if (len == 0) {
        return ArrayList<Segment>()
    }

    segments.sortBy() {a : Segment, b : Segment =>
        if (a.from < b.from) {
            return Ordering.LT
        } else if (a.from > b.from) {
            return Ordering.GT
        } else {
            if (a.to < b.to) {
                return Ordering.LT
            } else if (a.to > b.to) {
                return Ordering.GT
            } else {
                return Ordering.EQ
            }
        }
    }

    var merged : ArrayList<Segment> = ArrayList<Segment>()
    merged.append(segments[0])

    for (i in 1..len) {

        var cur : Segment = segments[i]


        if (UInt32(cur.from) <= (UInt32(merged[merged.size - 1].to) + 1)) {
            if (cur.to > merged[merged.size - 1].to) {
                merged[merged.size - 1].setTo(cur.to)
            }
        } else {
            merged.append(cur);
        }
    }

    return merged
}

// 辅助函数：获取一个字符集的所有段
func getSegments(charSetId : Int32) : ArrayList<Segment> {
    var segments : ArrayList<Segment> = ArrayList<Segment>()
    for (charSet in pCharSetTable) {
        if (charSet.indexId == charSetId) {
            segments.append(Segment(charSet.fromChar, charSet.toChar))
        }
    }

    segments.sortBy() {a : Segment, b : Segment =>
        if (a.from < b.from) {
            return Ordering.LT
        } else if (a.from > b.from) {
            return Ordering.GT
        } else {
            if (a.to < b.to) {
                return Ordering.LT
            } else if (a.to > b.to) {
                return Ordering.GT
            } else {
                return Ordering.EQ
            }
        }
    }

    return segments
}

// 测试合并段
func testMergeSegments() : Unit {
    var segments : ArrayList<Segment> = ArrayList<Segment>()
    segments.append(Segment(r'a',r'a'))
    segments.append(Segment(r'b',r'b'))
    segments.append(Segment(r'e',r'f'))
    segments.append(Segment(r'g',r'h'))
    segments.append(Segment(r'i',r'l'))
    segments.append(Segment(r'j',r'k'))

    var merged : ArrayList<Segment> = mergeSegments(segments)

    if (merged.size == 2 && merged[0].from == r'a' && merged[0].to == r'b' && merged[1].from == r'e' && merged[1].to == r'l') {
        println("testMergeSegments passed")
    } else {
        println("testMergeSegments failed")
        println(merged.size)
        for (segment in merged) {
            print(segment.from)
            print(" ")
            print(segment.to)
            println()
        }
    }
}

// 重置全局状态
func resetTestEnv() {
    pCharSetTable.clear()
    nextCharSetId = 1
}

// 范围运算
func range(fromChar : Rune, toChar : Rune) : Int32 {
    let from : Rune
    let to : Rune
    if (fromChar > toChar) {
        from = toChar
        to = fromChar
    } else {
        from = fromChar
        to = toChar
    }
    let newId : Int32 = nextCharSetId;
    nextCharSetId += 1
    let charSet : CharSet = CharSet(newId, 0, from, to)
    pCharSetTable.append(charSet)
    return newId
}

// 测试范围运算
func testRange() : Unit {
    resetTestEnv()
    let id : Int32 = range(r'a',r'c')
    var segments : ArrayList<Segment> = getSegments(id)
    if (segments.size == 1 && segments[0].from == r'a' && segments[0].to == r'c') {
        println("testRange passed")
    } else {
        println("testRange failed")
        println(segments.size)
        for (segment in segments) {
            println(segment.from)
            println(segment.to)
        }
    }
    return
}

// 并运算(字符与字符)
func union(c1 : Rune, c2 : Rune) : Int32 {
    var segments : ArrayList<Segment> = ArrayList<Segment>()
    if (c1 < c2) {
        segments.append(Segment(c1, c1))
        segments.append(Segment(c2, c2))
    } else {
        segments.append(Segment(c2, c2))
        segments.append(Segment(c1, c1))
    }

    var merged : ArrayList<Segment> = mergeSegments(segments)

    var newId : Int32 = nextCharSetId
    nextCharSetId += 1
    var i : Int32 = 1
    for (segment in merged) {
        let charSet : CharSet = CharSet(newId, i, segment.from, segment.to)
        pCharSetTable.append(charSet)
        i += 1
    }
    
    return newId
}

// 测试字符的并运算（相邻字符）
func testUnionCharAdjacent() : Unit {
    resetTestEnv()
    let id : Int32 = union(r'a',r'b')
    var segments : ArrayList<Segment> = getSegments(id)
    if (segments.size == 1 && segments[0].from == r'a' && segments[0].to == r'b') {
        println("testUnionCharAdjacent passed")
    } else {
        println("testUnionCharAdjacent failed")
        println(segments.size)
        for (segment in segments) {
            println(segment.from)
            println(segment.to)
        }
    }
}

// 测试字符的并运算（不相邻字符）
func testUnionCharDisjoint() : Unit {
    resetTestEnv()
    let id : Int32 = union(r'a',r'c')
    var segments : ArrayList<Segment> = getSegments(id)
    if (segments.size == 2 && segments[0].from == r'a' && segments[0].to == r'a' && segments[1].from == r'c' && segments[1].to == r'c') {
        println("testUnionCharDisjoint passed")
    } else {
        println("testUnionCharDisjoint failed")
        println(segments.size)
        for (segment in segments) {
            println(segment.from)
            println(segment.to)
        }
    }
}

// 并运算(字符集与字符)
func union(charSetId : Int32, c : Rune) {
    let segments : ArrayList<Segment> = ArrayList<Segment>()
    
    for (charSet in pCharSetTable) {
        if (charSet.indexId == charSetId) {
            segments.append(Segment(charSet.fromChar, charSet.toChar))
        }
    }
    segments.append(Segment(c, c))

    let merged : ArrayList<Segment> = mergeSegments(segments)
    
    let newId : Int32 = nextCharSetId
    nextCharSetId += 1

    var i : Int32 = 1

    for (segment in merged) {
        let charSet : CharSet = CharSet(newId, i, segment.from, segment.to)
        pCharSetTable.append(charSet)
        i += 1
    }
    
    return newId
}

// 测试字符集和字符的并运算
func testUnionCharSetAndChar() : Unit {
    resetTestEnv()
    let baseId : Int32 = range(r'a',r'c')
    let newId : Int32 = union(baseId, r'd')
    var segments : ArrayList<Segment> = getSegments(newId)
    if (segments.size == 1 && segments[0].from == r'a' && segments[0].to == r'd') {
        println("testUnionCharSetAndChar passed")
    } else {
        println("testUnionCharSetAndChar failed")
        println(segments.size)
        for (segment in segments) {
            print(segment.from)
            print("  ")
            print(segment.to)
            println("")
        }
    }
}

// 并运算(字符集与字符集)
func union(charSetId1 : Int32, charSetId2 : Int32) {
    let segments : ArrayList<Segment> = ArrayList<Segment>()
    
    for (charSet in pCharSetTable) {
        if (charSet.indexId == charSetId1 || charSet.indexId == charSetId2) {
            segments.append(Segment(charSet.fromChar, charSet.toChar))
        }
    }

    let merged : ArrayList<Segment> = mergeSegments(segments)

    let newId : Int32 = nextCharSetId
    nextCharSetId += 1

    var i : Int32 = 1
    for (segment in merged) {
        let charSet : CharSet = CharSet(newId, i, segment.from, segment.to)
        pCharSetTable.append(charSet)
        i += 1
    }

    return newId
}

// 测试字符集的并运算
func testUnionCharSetAndCharSet() : Unit {
    resetTestEnv()
    let baseId1 : Int32 = range(r'a',r'c')
    let baseId2 : Int32 = range(r'b',r'd')
    let newId : Int32 = union(baseId1, baseId2)
    var segments : ArrayList<Segment> = getSegments(newId)
    if (segments.size == 1 && segments[0].from == r'a' && segments[0].to == r'd') {
        println("testUnionCharSetAndCharSet passed")
    } else {
        println("testUnionCharSetAndCharSet failed")
        println(segments.size)
        for (segment in segments) {
            print(segment.from)
            print("  ")
            print(segment.to)
            println("")
        }
    }
}

// 差运算
func difference(charSetId : Int32, c : Rune) : Int32 {
    let segments : ArrayList<Segment> = ArrayList<Segment>()
    
    for (charSet in pCharSetTable) {
        if (charSet.indexId == charSetId) {
            segments.append(Segment(charSet.fromChar, charSet.toChar))
        }
    }

    let newSegments : ArrayList<Segment> = ArrayList<Segment>()

    for (segment in segments) {
        if (segment.to < c || segment.from > c) {
            newSegments.append(segment)
        } else {
            if (segment.from < c) {
                newSegments.append(Segment(segment.from, Rune(UInt32(c) - 1)))
            }
            if (segment.to > c) {
                newSegments.append(Segment(Rune(UInt32(c) + 1), segment.to))
            }
        }
    }

    let merged : ArrayList<Segment> = mergeSegments(newSegments)
    let newId : Int32 = nextCharSetId
    nextCharSetId += 1

    var i : Int32 = 1
    for (segment in merged) {
        let charSet : CharSet = CharSet(newId, i, segment.from, segment.to)
        pCharSetTable.append(charSet)
        i += 1
    }

    return newId
}

// 测试差运算
func testDifference() : Unit {
    resetTestEnv()
    let baseId : Int32 = range(r'a', r'z')
    let newId : Int32 = difference(baseId, r'i')
    let segments : ArrayList<Segment> = getSegments(newId)
    if (segments.size == 2 && segments[0].from == r'a' && segments[0].to == r'h' && segments[1].from == r'j' && segments[1].to == r'z') {
        println("testDifference passed")
    } else {
        println("testDifference failed")
        println(segments.size)
        for (segment in segments) {
            print(segment.from)
            print("  ")
            print(segment.to)
            println("")
        }
    }
}

main() {
    testMergeSegments()
    testRange()
    testUnionCharAdjacent()
    testUnionCharDisjoint()
    testUnionCharSetAndChar()
    testUnionCharSetAndCharSet()
    testDifference()
}