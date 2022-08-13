
import Foundation
import SwiftSyntax
import SwiftSyntaxParser

for filePath in CommandLine.arguments[1...] {
    let fullPath = URL(string: "file://" + FileManager.default.currentDirectoryPath)!
        .appendingPathComponent(filePath)
    let file = try String(contentsOf: fullPath)

    let ast = try SyntaxParser.parse(source: file)

    let visitor = AddProtocolInheritance()
    let output = visitor.visit(ast)

    try "\(output)".write(to: fullPath, atomically: false, encoding: .utf8)
}
