//
//  File.swift
//  
//
//  Created by Ivan Kvyatkovskiy on 12/09/2022.
//

import SwiftSyntax
import SwiftSyntaxParser

class RemoveAB: SyntaxRewriter {
    let experimentId: String
    let on: Bool
    init(experimentId: String,
         on: Bool = true) {
        self.experimentId = experimentId
        self.on = on
    }
    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        guard node.argumentList.first?.description.contains("Experiment." + experimentId) == true else {
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



