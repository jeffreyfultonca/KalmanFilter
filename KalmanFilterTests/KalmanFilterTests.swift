import XCTest
@testable import KalmanFilter

class KalmanFilterTests: XCTestCase {
    
    func testKalmanFilter2D() {
        let measurements = [1.0, 2.0, 3.0]
        let accuracy = 0.00001
        
        let x = try! Matrix(vector: [0, 0])
        let P = try! Matrix(grid: [1000, 0, 0, 1000], rows: 2, columns: 2)
        let B = try! Matrix(identityOfSize: 2)
        let u = try! Matrix(vector: [0, 0])
        let F = try! Matrix(grid: [1, 1, 0, 1], rows: 2, columns: 2)
        let H = try! Matrix(grid: [1, 0], rows: 1, columns: 2)
        let R = try! Matrix(grid: [1], rows: 1, columns: 1)
        let Q = try! Matrix(rows: 2, columns: 2)
        
        var kalmanFilter = KalmanFilter(stateEstimatePrior: x, errorCovariancePrior: P)
        
        for measurement in measurements {
            let z = try! Matrix(grid: [measurement], rows: 1, columns: 1)
            kalmanFilter = try! kalmanFilter.update(measurement: z, observationModel: H, covarienceOfObservationNoise: R)
            kalmanFilter = try! kalmanFilter.predict(stateTransitionModel: F, controlInputModel: B, controlVector: u, covarianceOfProcessNoise: Q)
        }
        
        let resultX = try! Matrix(vector: [3.9996664447958645, 0.9999998335552873])
        let resultP = try! Matrix(grid: [2.3318904241194827, 0.9991676099921091, 0.9991676099921067, 0.49950058263974184], rows: 2, columns: 2)
        
        var index = Matrix.Index(row: 0, column: 0)
        XCTAssertEqual(
            try! kalmanFilter.stateEstimatePrior.value(at: index),
            try! resultX.value(at: index),
            accuracy: accuracy
        )
        
        index = Matrix.Index(row: 1, column: 0)
        XCTAssertEqual(
            try! kalmanFilter.stateEstimatePrior.value(at: index),
            try! resultX.value(at: index),
            accuracy: accuracy
        )
        
        index = Matrix.Index(row: 0, column: 0)
        XCTAssertEqual(
            try! kalmanFilter.errorCovariancePrior.value(at: index),
            try! resultP.value(at: index),
            accuracy: accuracy
        )
        
        index = Matrix.Index(row: 0, column: 1)
        XCTAssertEqual(
            try! kalmanFilter.errorCovariancePrior.value(at: index),
            try! resultP.value(at: index),
            accuracy: accuracy
        )
        
        index = Matrix.Index(row: 1, column: 0)
        XCTAssertEqual(
            try! kalmanFilter.errorCovariancePrior.value(at: index),
            try! resultP.value(at: index),
            accuracy: accuracy
        )
        
        index = Matrix.Index(row: 1, column: 1)
        XCTAssertEqual(
            try! kalmanFilter.errorCovariancePrior.value(at: index),
            try! resultP.value(at: index),
            accuracy: accuracy
        )
    }
    
}
