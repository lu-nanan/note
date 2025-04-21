macro package myenum_enhance

import std.ast.*
import std.collection.*

public macro ToStringEnum(input: Tokens): Tokens {
    let enumm = EnumDecl(input)
    // match表达式
    var matchExprs = Array<MatchExpr>(2, { _ => MatchExpr()})
    for (expr in matchExprs) {
        expr.selector = RefExpr(quote(this))
        expr.lParen = Token(TokenKind.LPAREN)
        expr.rParen = Token(TokenKind.RPAREN)
    }
    // 构造case
    let matchCaseSet = Array<ArrayList<MatchCase>>(2, {_ => ArrayList<MatchCase>()})
    for (constr in enumm.constructors) {
        let matchCases = Array<MatchCase>(2, {_ => MatchCase()}) // 0: case Red => "Red" | 1： case Red => "Enum.Red"
        let enumPatt = EnumPattern()
        let litConstBuilders = Array<StringBuilder>(2, {_ => StringBuilder()})
        // 添加 "Enum."
        litConstBuilders[1].append(enumm.identifier.value)
        litConstBuilders[1].append(r'.')

        litConstBuilders |> forEach{i => i.append(constr.identifier.value)}
        enumPatt.constructor = parseExpr(constr.identifier.toTokens())
        // 组装 MatchCase
        var flag = false
        let constrArgSize = constr.typeArguments.size
        for (item in constr.typeArguments |> enumerate) {
            if (!flag) {
                litConstBuilders |> forEach{i => i.append(r"(")}
                flag = true
            }
            let id = Token(TokenKind.IDENTIFIER, "v" + item[0].toString())
            enumPatt.patterns.append(TypePattern(quote($id: $(item[1]))))

            litConstBuilders[0].append("\${${id.toTokens()}.toString()}")
            match (item[1]) {
                case r: RefType where r.identifier.value == enumm.identifier.value =>
                litConstBuilders[1].append("\${${id.toTokens()}.toString(true)}")
                case p: TypeNode => 
                litConstBuilders[1].append("\${${id.toTokens()}.toString()}")
            }

            if (item[0] != constrArgSize - 1) {
                litConstBuilders |> forEach{i => i.append(", ")}
            }
        }
        if (flag) {
            litConstBuilders |> forEach{i => i.append(r')')}
        }
        for (((mat, lit), set) in matchCases |> zip(litConstBuilders) |> zip(matchCaseSet)) {
            mat.patterns.append(enumPatt)
            mat.block.nodes.append(LitConstExpr(quote($(lit.toString()))))
            set.append(mat)
        }
    }
    for ((expr, set) in matchExprs |> zip(matchCaseSet)) {
        set |> forEach{i => expr.matchCases.append(i)}
    }
    // toString(): String函数
    let block = Block()
    block.nodes.append(matchExprs[0])
    let toString = FuncDecl(quote(
        public func toString(): String {
            $block
        }))
    // toString(b: Bool): String函数
    let block1 = Block()
    block1.nodes.append(matchExprs[1])
    let toStringBool = FuncDecl(quote(
        public func toString(b: Bool): String {
            if (b) {
                $block1
            } else {
                this.toString()
            }
        }))
    // 将函数加入枚举
    let funcs = ArrayList<String>()
    for (decl in enumm.decls) {
        match (decl) {
            // case d: FuncDecl => funcSet.put(d.identifier.toTokens().toString())
            case d: FuncDecl => funcs.append(d.identifier.value)
            case _ => ()
        }
    }
    if (!funcs.contains("toString")) {
        enumm.decls.append(toString)
        enumm.decls.append(toStringBool)
    }
    // 继承接口
    let intfs = ArrayList<String>()
    for (i in enumm.superTypes) {
        match (i) {
            case r: RefType => intfs.append(r.toTokens().toString())
            case r: TypeNode => ()
        }
    }
    if (!intfs.contains("ToString")) {
        enumm.superTypes.append(RefType(quote(ToString)))
    }

    enumm.toTokens()
}