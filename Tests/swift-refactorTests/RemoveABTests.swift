import XCTest
@testable import swift_refactor
import SwiftSyntax
import SwiftSyntaxParser

final class RemoveABTests: XCTestCase {

    let experimentId = "someExp"
    lazy var sut = RemoveAB(experimentId: experimentId)

    func testLeaveOnExpression() {
        assert(
            input: "toggler.evaluate(Experiment.someExp, off: false, on: true)",
            expected: "true"
        )
    }

    func testDoesnChangeAnotherExperiment() {
        assert(
            input: "toggler.evaluate(Experiment.doNotChange, off: false, on: true)",
            expected: "toggler.evaluate(Experiment.doNotChange, off: false, on: true)"
        )
    }

    func testLeaveOffExpression() {
        setUp(on: false)
        assert(
            input: "toggler.evaluate(Experiment.someExp, off: false, on: true)",
            expected: "false"
        )
    }

    // test context
}

extension RemoveABTests {

    func setUp(on: Bool) {
        sut = .init(experimentId: experimentId,
                    on: on)
    }

    func assert(input: String, expected: String) {
        do {
            let rootNode: SourceFileSyntax = try SyntaxParser.parse(source: input)
            let result = sut.visit(rootNode)
            XCTAssertEqual(expected, result.description)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
