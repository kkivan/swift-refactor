import XCTest
@testable import swift_refactor
import SwiftSyntax
import SwiftSyntaxParser

final class AddProtocolInheritanceTests: XCTestCase {

    func testStruct() {
        assert(
            input: "struct Struct: Encodable, Equatable {}",
            expected: "struct Struct: Encodable, Equatable, MyProtocol {}"
        )
    }

    func testStruct_NoInheritance() {
        assert(
            input: "struct NoInheritance {}",
            expected: "struct NoInheritance: MyProtocol {}"
        )
    }

    func testEnum() {
        assert(
            input: "enum Enum: Encodable, Equatable {}",
            expected: "enum Enum: Encodable, Equatable, MyProtocol {}"
        )
    }

    func testProtocol_NoInheritance() {
        assert(
            input: "enum Enum {}",
            expected: "enum Enum: MyProtocol {}"
        )
    }

    func testProtocol() {
        assert(
            input: "protocol MyProtocol: Encodable, Equatable {}",
            expected: "protocol MyProtocol: Encodable, Equatable {}"
        )
    }
}

extension AddProtocolInheritanceTests {
    func assert(input: String, expected: String) {
        do {
            let rootNode: SourceFileSyntax = try SyntaxParser.parse(source: input)
            let result = AddProtocolInheritance().visit(rootNode)
            XCTAssertEqual(expected, result.description)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
