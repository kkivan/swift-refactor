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

    func testRemoveOffExpression_NewLine() {
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

    func testRemoveOffExpression_NewLine1() {
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

    func testRemoveOnExpression() {
      setUp(on: false)
      assert(
        input: "toggler.evaluate(Experiment.someExp, off: false, on: true)",
        expected: "false"
      )
    }

    func testRemoveOffWithContext() {
      assert(input:
        """
            toggler.evaluate(Experiment.someExp) {
                $0.off { doThis() }
                $0.on { doThat() }
            }
        """,
             expected:
              "doThat()"
      )
    }

    func testDoesntRemoveOffWithContext_AnotherExp() {
      assertNotChanged(
        input:
        """
            toggler.evaluate(Experiment.anotherExp) {
                $0.off { doThis() }
                $0.on { doThat() }
            }
        """
      )
    }

  func testDoesntRemoveOffWithContext_MultipleCodeItems() {
    assert(
      input:
        """
            dontDelete()
            toggler.evaluate(Experiment.someExp) {
                $0.off { doThis() }
                $0.on { doThat() }
            }
        """,
      expected:"""
            dontDelete()
            doThat()
        """
    )
  }

    // precheck -> ternary operator
    //    toggler.evaluate(Experiment.searchClayUseDomainModel) {
    //        $0.precheck { self.interactor.bookingCriteria.hotel.domainModel as? PropertySSR != nil }
    //        $0.off { doThis() }
    //        $0.on { doThat() }
    //    }

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
            let result = sut.visit(rootNode).as(SourceFileSyntax.self)!

            let expectedAst = try SyntaxParser.parse(source: expected)
            XCTAssertEqual(expectedAst.formattedDescription, result.formattedDescription)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

  func assertNotChanged(input: String) {
    assert(input: input, expected: input)
  }
}
