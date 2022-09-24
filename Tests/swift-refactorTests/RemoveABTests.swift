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

    func testLeaveOnExpression_NewLine() {
        let input = """
                let paymentModel: Analytics.PaymentModel = toggler.evaluate(
                    Experiment.someExp,
                    off: .unknown,
                    on: true
                )
                """
        assert(
            input:input,
            expected: "let paymentModel: Analytics.PaymentModel = true"
        )
    }

    func testLeaveOnExpression_NewLine1() {
        assert(
            input:
                """
                toggler.evaluate(
                Experiment.someExp,
                                off: false, on: true)
                """,
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

    // test context on

    // test context off

    // test remove isOn

    // test remove isOff

    // test remove duplicated test on

    // test remove duplicated test off

    // test on without off case toggler.evaluate(<#T##toggle: Toggle##Toggle#>, on: <#T##Void#>) for on

    // test on without off case toggler.evaluate(<#T##toggle: Toggle##Toggle#>, on: <#T##Void#>) for off

    // test toggler.states = [Experiment.flightsAgency: .on]

    // guard toggler.isOff(Experiment.flightsImproveBF2Analytics) else {
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
