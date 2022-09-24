
import Foundation
import SwiftSyntax
import SwiftSyntaxParser

let tool = CommandLine.arguments[1]
let visitor: SyntaxRewriter
switch tool {
case "AddProtocolInheritance": visitor = AddProtocolInheritance()
case "RemoveAB": visitor = RemoveAB(experimentId: "flightsAgency")
default: fatalError("unsupported tool: \(tool)")
}
for filePath in CommandLine.arguments[2...] {
    let fullPath = URL(string: "file://" + FileManager.default.currentDirectoryPath)!
        .appendingPathComponent(filePath)
    let file = try String(contentsOf: fullPath)

    let ast = try SyntaxParser.parse(source: file)

    let output = visitor.visit(ast)

    try "\(output)".write(to: fullPath, atomically: false, encoding: .utf8)
}
