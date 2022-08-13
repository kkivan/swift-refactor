import SwiftSyntax
import SwiftSyntaxParser

class AddProtocolInheritance: SyntaxRewriter {

    let protocolName: String = "MyProtocol"

    var isStructOrEnum: Bool = false

    var types: [SyntaxProtocol.Type] = []

    lazy var inheritedProtocol = SyntaxFactory.makeInheritedType(
        typeName: SyntaxFactory.makeTypeIdentifier(protocolName),
        trailingComma: nil).withTrailingTrivia(.spaces(1))

    override func visit(_ node: InheritedTypeListSyntax) -> Syntax {
        guard isStructOrEnum else {
            return super.visit(node)
        }
        defer { isStructOrEnum = false }

        let results = node.map {
            $0.withoutTrailingTrivia()
                .withTrailingComma(SyntaxFactory.makeCommaToken())
                .withTrailingTrivia(.spaces(1))
        } + [inheritedProtocol]

        return super.visit(SyntaxFactory.makeInheritedTypeList(results))
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        isStructOrEnum = true
        return super.visit(node.addInheritanceClauseIfNeeded())
    }

    override func visit(_ node: EnumDeclSyntax) -> DeclSyntax {
        isStructOrEnum = true
        return super.visit(node.addInheritanceClauseIfNeeded())
    }
}

extension StructDeclSyntax {
    func addInheritanceClauseIfNeeded() -> Self {
        if self.inheritanceClause == nil {
            return self.withIdentifier(self.identifier.withoutTrailingTrivia())
                .withInheritanceClause(SyntaxFactory.makeBlankTypeInheritanceClause()
                    .withColon(SyntaxFactory.makeColonToken().withTrailingTrivia(.spaces(1))))
        }
        return self
    }
}

extension EnumDeclSyntax {
    func addInheritanceClauseIfNeeded() -> Self {
        if self.inheritanceClause == nil {
            return self.withIdentifier(self.identifier.withoutTrailingTrivia())
                .withInheritanceClause(SyntaxFactory.makeBlankTypeInheritanceClause()
                    .withColon(SyntaxFactory.makeColonToken().withTrailingTrivia(.spaces(1))))
        }
        return self
    }
}
