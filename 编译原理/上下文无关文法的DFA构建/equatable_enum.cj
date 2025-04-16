macro package myenum_enhance

import std.ast.*
import std.collection.{ArrayList, enumerate, filter, all}

public macro EquatableEnum(input: Tokens): Tokens {
    let enumm = EnumDecl(input)
    // match表达式
    let hashMatchExpr = MatchExpr()
    hashMatchExpr.selector = RefExpr(quote(this))
    hashMatchExpr.lParen = Token(TokenKind.LPAREN)
    hashMatchExpr.rParen = Token(TokenKind.RPAREN)
    // 基础类型无嵌套参数构造器
    let noNestedPrimConstr = enumm.constructors |>
        filter {
        i: Constructor => i.typeArguments |>
            all {
            i: TypeNode => match (i) {
                case a: PrimitiveType => true
                case _ => throw ASTException("All args of Constructor shall be primitive type")
            }
        }
    }
    // 构造case
    let noNestedPrimCases = ArrayList<MatchCase>()
    var hashIndex = 0i64
    for (constr in noNestedPrimConstr) {
        let matchCase = MatchCase()
        let blockNodes = matchCase.block.nodes
        let enumPatt = EnumPattern()

        blockNodes.append(VarDecl(quote(var hasher = DefaultHasher(res: $(hashIndex)))))
        enumPatt.constructor = parseExpr(constr.identifier.toTokens())

        for (item in constr.typeArguments |> enumerate) {
            let id = Token(TokenKind.IDENTIFIER, "v" + item[0].toString())
            enumPatt.patterns.append(TypePattern(quote($(id): $(item[1]))))
            blockNodes.append(CallExpr(quote(hasher.write($(id)))))
        }
        blockNodes.append(CallExpr(quote(hasher.finish())))

        matchCase.patterns.append(enumPatt)
        noNestedPrimCases.append(matchCase)
        hashIndex++
    }
    noNestedPrimCases.iterator().forEach {i => hashMatchExpr.matchCases.append(i)}
    // hashCode函数
    let block = Block()
    block.nodes.append(hashMatchExpr)
    let hashCode = FuncDecl(
        quote(
            
        public func hashCode(): Int64 {
            $block
        }))
    // == 函数
    let equal = FuncDecl(
        quote(
        public operator func ==(that: $(enumm.identifier)): Bool {
            this.hashCode() == that.hashCode()
        })
    )
    // != 函数
    let notEqual = FuncDecl(
        quote(
        public operator func !=(that: $(enumm.identifier)): Bool {
            this.hashCode() != that.hashCode()
        })
    )
    // 将函数加入枚举
    let funcs = ArrayList<String>()
    for (decl in enumm.decls) {
        match (decl) {
            // case d: FuncDecl => funcSet.put(d.identifier.toTokens().toString())
            case d: FuncDecl => funcs.append(d.identifier.value)
            case _ => ()
        }
    }
    if (!funcs.contains("hashCode")) {
        enumm.decls.append(hashCode)
    }
    if (!funcs.contains("==")) {
        enumm.decls.append(equal)
    }
    if (!funcs.contains("!=")) {
        enumm.decls.append(notEqual)
    }
    // 继承接口
    let intfs = ArrayList<String>()
    for (i in enumm.superTypes) {
        match (i) {
            case r: RefType => intfs.append(r.toTokens().toString())
            case r: TypeNode => ()
        }
    }
    if (!intfs.contains("Hashable")) {
        enumm.superTypes.append(RefType(quote(Hashable)))
    }
    if (!intfs.contains("Equatable")) {
        enumm.superTypes.append(RefType(quote(Equatable<$(enumm.identifier)>)))
    }

    enumm.toTokens()
}
