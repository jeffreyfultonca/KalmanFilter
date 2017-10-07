import XCTest
@testable import KalmanFilter

class DoubleExtensionTests: XCTestCase {
    func testDoubleAsKalmanInput() {
        XCTAssertEqual(try! 5.2.transposed(), 5.2)
        XCTAssertEqual(try! 2.0.inversed(), 0.5)
        XCTAssertEqual(try! 0.2.additionToUnit(), 0.8)
    }
}
