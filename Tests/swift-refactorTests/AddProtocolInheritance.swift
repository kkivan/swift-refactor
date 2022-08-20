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
    
    func testEnum_WithFewProtocols_WithMyProtocol() {
        assert(
            input: "enum Enum: Encodable, Equatable, MyProtocol {}",
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
    
    func testStruct_WithRewritableProtocol_WithTrailingSpaces() {
        assert(
            input: "struct A: MyProtocol     {}",
            expected: "struct A: MyProtocol {}"
        )
    }
    
    func testStruct_WithRewritableProtocol_WithConflictingTypes() {
        assert(
            input: "struct A: MyProtocol, MyProtocol_A, MyProtocol_B {}",
            expected: "struct A: MyProtocol {}"
        )
    }
    
    func testStruct_WithRewritableProtocol_WithExtension() {
        assert(
            input: """
                struct A {}
                extension A: MyProtocol {}
                """,
            expected: """
                struct A: MyProtocol {}
                """
        )
    }
    
    func testStruct_WithExtensionWithoutProtocol() {
        assert(
            input: """
                struct A {}
                extension A {}
                """,
            expected: """
                struct A: MyProtocol {}
                extension A {}
                """
        )
    }
    
    func testStruct_WithExtensionWithNotExcludedProtocol() {
        assert(
            input: """
                struct A {}
                extension A: ShouldNotBeRemovedProtocol {}
                """,
            expected: """
                struct A: MyProtocol {}
                extension A: ShouldNotBeRemovedProtocol {}
                """
        )
    }
    
    func testStruct_WithFewProtocols_WithMyProtocol() {
            assert(
                input: """
                    struct A: AnyProtocol, MyProtocol {}
                    """,
                expected: """
                    struct A: AnyProtocol, MyProtocol {}
                    """
        )
    }
}

extension AddProtocolInheritanceTests {
    func assert(input: String, expected: String) {
        do {
            let rootNode: SourceFileSyntax = try SyntaxParser.parse(source: input)
            let result = AddProtocolInheritance("MyProtocol", ["MyProtocol_A", "MyProtocol_B"]).visit(rootNode)
            XCTAssertEqual(expected, result.description)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
