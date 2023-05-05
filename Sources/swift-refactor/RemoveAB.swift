//
//  File.swift
//  
//
//  Created by Ivan Kvyatkovskiy on 12/09/2022.
//

import SwiftSyntax
import SwiftSyntaxParser
import Foundation

class RemoveAB: SyntaxRewriter {
    let experimentId: String
    let on: Bool

  var branch: String { on ? "on" : "off" }

    init(experimentId: String,
         on: Bool = true) {
        self.experimentId = "Experiment." + experimentId
        self.on = on
    }

  var statements: CodeBlockItemListSyntax? = nil

  override func visit(_ node: CodeBlockItemListSyntax) -> Syntax {
    var items: [CodeBlockItemSyntax] = node.map { $0 }
    for (n, index) in zip(items, items.indices) {
      guard let item = n.item.as(FunctionCallExprSyntax.self) else {
        continue
      }
      if item.calledExpression.description.hasSuffix(".evaluate") {
        guard item.argumentList.first?.description == experimentId else {
          continue
        }
        if let closure = item.trailingClosure {
          for item in closure.statements {
            guard let item = item.item.as(FunctionCallExprSyntax.self) else {
              continue
            }
            if item.calledExpression
              .description
              .trimmingCharacters(in: .whitespacesAndNewlines)
              .hasSuffix(".\(branch)") {
              if let closure = item.trailingClosure {
                items[index] = SyntaxFactory.makeBlankCodeBlockItem().withItem(super.visit(closure.statements))
              }
            }
          }
        }
      }
    }
    return super.visit(SyntaxFactory.makeCodeBlockItemList(items))
  }

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        guard node.argumentList.first?.description.contains(experimentId) == true else {
            return super.visit(node)
        }
        let branch = on ? "on" : "off"
        for arg in node.argumentList {
            if arg.label?.description.contains(branch) == true {
                return arg.expression
            }
        }
        return super.visit(node)
    }
}



