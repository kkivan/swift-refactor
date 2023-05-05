import SwiftSyntax
import SwiftSyntaxParser

final class AddProtocolInheritance: SyntaxRewriter {

  private let protocolName: String
  private let conflictingTypes: [String]

  private var isStructOrEnum: Bool = false
  private var types: [SyntaxProtocol.Type] = []

  init(
    _ protocolName: String = "Codable",
    _ excludedNames: [String] = ["Encodable", "Decodable"]
  ) {
    self.protocolName = protocolName
    self.conflictingTypes = [protocolName] + excludedNames
  }

  lazy var inheritedProtocol = SyntaxFactory.makeInheritedType(
    typeName: SyntaxFactory.makeTypeIdentifier(protocolName),
    trailingComma: nil
  ).withTrailingTrivia(.spaces(1))

  override func visit(_ node: InheritedTypeListSyntax) -> Syntax {
    guard isStructOrEnum else { return super.visit(node) }
    defer { isStructOrEnum = false }

    let results =
      node.filter(shouldInclude)
      .map {
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

  override func visit(_ node: CodeBlockItemSyntax) -> Syntax {
    var newNode = node
    if let extensionDecl = node.item.as(ExtensionDeclSyntax.self) {
      let inheritedTypes = extensionDecl.inheritanceClause?.inheritedTypeCollection
      let remainingTypes = inheritedTypes?.filter(shouldInclude)
      if remainingTypes?.isEmpty == true {
        newNode = SyntaxFactory.makeBlankCodeBlockItem()
      }
    }
    return super.visit(newNode)
  }
}

extension StructDeclSyntax {
  func addInheritanceClauseIfNeeded() -> Self {
    if self.inheritanceClause == nil {
      return self.withIdentifier(self.identifier.withoutTrailingTrivia())
        .withInheritanceClause(
          SyntaxFactory.makeBlankTypeInheritanceClause()
            .withColon(SyntaxFactory.makeColonToken().withTrailingTrivia(.spaces(1))))
    }
    return self
  }
}

extension EnumDeclSyntax {
  func addInheritanceClauseIfNeeded() -> Self {
    if self.inheritanceClause == nil {
      return self.withIdentifier(self.identifier.withoutTrailingTrivia())
        .withInheritanceClause(
          SyntaxFactory.makeBlankTypeInheritanceClause()
            .withColon(SyntaxFactory.makeColonToken().withTrailingTrivia(.spaces(1))))
    }
    return self
  }
}

extension AddProtocolInheritance {

  func shouldInclude(_ type: InheritedTypeSyntax) -> Bool {
    !conflictingTypes.contains(type.withoutTrailingTrivia().typeName.description)
  }
}
