import XCTest
@testable import KalmanFilter

class MatrixTests: XCTestCase {
    
    func testMatrixIsSquare() {
        XCTAssertTrue(try Matrix(identityOfSize: 2).isSquare)
        XCTAssertFalse(try Matrix(rows: 3, columns: 1).isSquare)
    }
    
    func testMatrixEquatable() {
        var matrixOne = try! Matrix(rows: 1, columns: 2)
        var matrixTwo = try! Matrix(rows: 1, columns: 2)
        
        XCTAssertTrue(matrixOne == matrixTwo)
        XCTAssertTrue(matrixTwo == matrixOne)
        
        try! matrixOne.set(value: 1, at: Matrix.Index(row: 0, column: 0))
        XCTAssertFalse(matrixOne == matrixTwo)
        
        try! matrixOne.set(value: 0, at: Matrix.Index(row: 0, column: 0))
        XCTAssertTrue(matrixTwo == matrixOne)
        
        matrixTwo = try! Matrix(rows: 2, columns: 1)
        XCTAssertFalse(matrixOne == matrixTwo)
    }
    
    func testMatrixInitialization() {
        let rowCount = 4
        let columnCount = 3
        let matrix = try! Matrix(rows: rowCount, columns: columnCount)
        
        XCTAssertEqual(matrix.rowCount, rowCount)
        XCTAssertEqual(matrix.columnCount, columnCount)
        XCTAssertEqual(matrix.grid.count, rowCount * columnCount)
        
        let squareMatrix = try! Matrix(squareOfSize: rowCount)
        
        XCTAssertEqual(squareMatrix.rowCount, rowCount)
        XCTAssertEqual(squareMatrix.columnCount, rowCount)
        XCTAssertEqual(squareMatrix.grid.count, rowCount * rowCount)
        
        let identityMatrixSize = 3
        let identityMatrix = try! Matrix(identityOfSize: identityMatrixSize)
        var identityMatrixProper = try! Matrix(squareOfSize: identityMatrixSize)
        
        try! identityMatrixProper.set(value: 1, at: Matrix.Index(row: 0, column: 0))
        try! identityMatrixProper.set(value: 1, at: Matrix.Index(row: 1, column: 1))
        
        XCTAssertNotEqual(identityMatrix, identityMatrixProper)
        
        try! identityMatrixProper.set(value: 1, at: Matrix.Index(row: 2, column: 2))
        XCTAssertEqual(identityMatrix, identityMatrixProper)
        
        let vectorMatrixEmpty = try! Matrix(vectorOf: 2)
        
        XCTAssertEqual(vectorMatrixEmpty.rowCount, 2)
        XCTAssertEqual(vectorMatrixEmpty.columnCount, 1)
        
        let vectorMatrix = try! Matrix(vector: [2, 1, 3])
        
        XCTAssertEqual(vectorMatrix.rowCount, 3)
        XCTAssertEqual(vectorMatrix.columnCount, 1)
        XCTAssertEqual(
            try! vectorMatrix.value(at: Matrix.Index(row: 0, column: 0)),
            2
        )
        XCTAssertEqual(
            try! vectorMatrix.value(at: Matrix.Index(row: 1, column: 0)),
            1
        )
        XCTAssertEqual(
            try! vectorMatrix.value(at: Matrix.Index(row: 2, column: 0)),
            3
        )
        
        let array2d = [[1.0, 0.0], [0.0, 1.0]]
        XCTAssertEqual(
            try! Matrix(array2d),
            try! Matrix(identityOfSize: 2)
        )
        XCTAssertEqual(
            try! Matrix([[2.0], [1], [3]]),
            vectorMatrix
        )
    }
    
    func testMatrixCheckForSquare() {
        XCTAssertTrue(try Matrix(rows: 2, columns: 2).isSquare)
        XCTAssertTrue(try Matrix(squareOfSize: 2).isSquare)
        XCTAssertTrue(try Matrix(identityOfSize: 2).isSquare)
        XCTAssertFalse(try Matrix(rows: 3, columns: 2).isSquare)
        XCTAssertFalse(try Matrix(rows: 2, columns: 3).isSquare)
    }
    
    func testMatrixIndexValidation() {
        let rows = 2
        let columns = 3
        let matrix = try! Matrix(rows: rows, columns: columns)
        
        XCTAssertNoThrow(try matrix.validate(index: Matrix.Index(row: 0, column: 0)))
        XCTAssertNoThrow(try matrix.validate(index: Matrix.Index(row: rows - 1, column: columns - 1)))
        
        XCTAssertThrowsError(try matrix.validate(index: Matrix.Index(row: rows, column: columns)))
        XCTAssertThrowsError(try matrix.validate(index: Matrix.Index(row: -1, column: -1)))
    }
    
    // MARK: Matrix Kalman Filter Extension Tests
    func testMatrixTranspose() {
        let initialMatrix = try! Matrix([[5, 4], [4, 0], [7, 10], [-1, 8]])
        let transposedMatrixProper = try! Matrix([[5, 4, 7, -1], [4, 0, 10, 8]])
        XCTAssertEqual(try initialMatrix.transposed(), transposedMatrixProper)
    }
    
    func testAdditionToUnit() {
        let initialMatrix = try! Matrix([[4, 7, 1], [-2, 8, 3], [5, -4, 11]])
        let properAdditionToUnitMatrix = try! Matrix([[-3, -7, -1], [2, -7, -3], [-5, 4, -10]])
        
        XCTAssertEqual(try initialMatrix.additionToUnit(), properAdditionToUnitMatrix)
    }
    
    func testMatrixDeterminant() {
        let initialMatrix = try! Matrix([[-2, 2, -3], [-1, 1, 3], [2, 0, -1]])
        XCTAssertEqual(try initialMatrix.determinant(), 18)
    }
    
    func testMatrixInversed() {
        let initialMatrix = try! Matrix([[1, 2, 3], [0, 1, 4], [5, 6, 0]])
        let properInversedMatrix = try! Matrix([[-24, 18, 5], [20, -15, -4], [-5, 4, 1]])
        
        XCTAssertEqual(try initialMatrix.inversed(), properInversedMatrix)
        XCTAssertEqual(
            try Matrix(grid: [2], rows: 1, columns: 1).inversed(),
            try Matrix(grid: [1.0/2], rows: 1, columns: 1)
        )
    }
    
    func testMatrixAddition() {
        let size = (2, 3)
        let matrixOne = try! Matrix([[5, 7, 9], [11, -2, -3]])
        let matrixTwo = try! Matrix([[-8, 4, 9], [6, 3, 2]])
        
        var additionMatrix = try! Matrix(rows: size.0, columns: size.1)
        
        var index = Matrix.Index(row: 0, column: 0)
        try! additionMatrix.set(
            value: matrixOne.value(at: index) + matrixTwo.value(at: index),
            at: index
        )
        
        index = Matrix.Index(row: 0, column: 1)
        try! additionMatrix.set(
            value: matrixOne.value(at: index) + matrixTwo.value(at: index),
            at: index
        )
        
        index = Matrix.Index(row: 0, column: 2)
        try! additionMatrix.set(
            value: matrixOne.value(at: index) + matrixTwo.value(at: index),
            at: index
        )
        
        index = Matrix.Index(row: 1, column: 0)
        try! additionMatrix.set(
            value: matrixOne.value(at: index) + matrixTwo.value(at: index),
            at: index
        )
        
        index = Matrix.Index(row: 1, column: 1)
        try! additionMatrix.set(
            value: matrixOne.value(at: index) + matrixTwo.value(at: index),
            at: index
        )
        
        index = Matrix.Index(row: 1, column: 2)
        try! additionMatrix.set(
            value: matrixOne.value(at: index) + matrixTwo.value(at: index),
            at: index
        )
        
        XCTAssertEqual(try matrixOne + matrixTwo, additionMatrix)
    }
    
    func testMatrixSubtraction() {
        let size = (2, 3)
        let matrixOne = try! Matrix([[5, 7, 9], [11, -2, -3]])
        let matrixTwo = try! Matrix([[-8, 4, 9], [6, 3, 2]])
        
        var subtractionMatrix = try! Matrix(rows: size.0, columns: size.1)
        
        var index = Matrix.Index(row: 0, column: 0)
        try! subtractionMatrix.set(
            value: matrixOne.value(at: index) - matrixTwo.value(at: index),
            at: index
        )
        
        index = Matrix.Index(row: 0, column: 1)
        try! subtractionMatrix.set(
            value: matrixOne.value(at: index) - matrixTwo.value(at: index),
            at: index
        )
        
        index = Matrix.Index(row: 0, column: 2)
        try! subtractionMatrix.set(
            value: matrixOne.value(at: index) - matrixTwo.value(at: index),
            at: index
        )
        
        index = Matrix.Index(row: 1, column: 0)
        try! subtractionMatrix.set(
            value: matrixOne.value(at: index) - matrixTwo.value(at: index),
            at: index
        )
        
        index = Matrix.Index(row: 1, column: 1)
        try! subtractionMatrix.set(
            value: matrixOne.value(at: index) - matrixTwo.value(at: index),
            at: index
        )
        
        index = Matrix.Index(row: 1, column: 2)
        try! subtractionMatrix.set(
            value: matrixOne.value(at: index) - matrixTwo.value(at: index),
            at: index
        )
        
        XCTAssertEqual(try matrixOne - matrixTwo, subtractionMatrix)
    }
    
    func testMatrixMultiplication() {
        let matrixOne = try! Matrix([[3.0, 4, 2]])
        let matrixTwo = try! Matrix([[13, 9, 7, 15], [8, 7, 4, 6], [6, 4, 0, 3]])
        let multipliedMatrices = try! Matrix([[83.0, 63, 37, 75]])
        
        XCTAssertEqual(try! matrixOne * matrixTwo, multipliedMatrices)
    }
    
    func testMatrixMultiplicationByScalar() {
        let matrix = try! Matrix(grid: [1, 2, 3, 4], rows: 2, columns: 2)
        
        XCTAssertEqual(try! matrix * 2, try! Matrix([[2, 4], [6, 8]]))
        XCTAssertEqual(try! 2 * matrix, try! Matrix([[2, 4], [6, 8]]))
        XCTAssertEqual(try! matrix * 0.5, try! Matrix([[0.5, 1], [1.5, 2]]))
    }
    
    func testMatrixStringDescription() {
        let matrix = try! Matrix(
            [[0.0, 2.0, 3.0, 4.0],
            [0.0, 2.0, 3.0, 4.0],
            [0.0, 2.0, 3.0, 4.0]]
        )
        
        let string = "⎛\t0.0\t2.0\t3.0\t4.0\t⎞\n" +
                     "⎜\t0.0\t2.0\t3.0\t4.0\t⎥\n" +
                     "⎝\t0.0\t2.0\t3.0\t4.0\t⎠\n"
        XCTAssertEqual(matrix.description, string)
        XCTAssertEqual(try! Matrix([[0.0, 2.0, 3.0, 4.0]]).description, "(\t0.0\t2.0\t3.0\t4.0\t)\n")
    }
}
