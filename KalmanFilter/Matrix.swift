import Foundation

// MARK: - MatrixError

enum MatrixError: Error {
    case failedToInitializeMatrix(because: String)
    case invalidIndexRow(row: Int, inMatrix: Matrix)
    case invalidIndexColumn(column: Int, inMatrix: Matrix)
    case squareMatrixRequiredForFunction(function: String, actualMatrix: Matrix)
    case matricesOfEqualSizeRequiredForFunction(
        function: String,
        firstMatrix: Matrix,
        secondMatrix: Matrix
    )
    case leftMatrixColumnsShouldMatchRightMatrixRequiredForFunction
    case firstMatrixColumnSizeFailedToMatchSecondMatrixRowSize(
        function: String,
        firstMatrix: Matrix,
        secondMatrix: Matrix
    )
}

// MARK: - Index

extension Matrix {
    public struct Index {
        let row: Int
        let column: Int
    }
}

// MARK: - Matrix

public struct Matrix: Equatable {
    
    // MARK: - Properties
    
    public let rowCount: Int, columnCount: Int
    public private(set) var grid: [Double]
    
    var isSquare: Bool {
        return rowCount == columnCount
    }
    
    // MARK: - Initialization
    
    /**
     Initialization of matrix with rows * columns
     size where all the elements are set to 0.0
     
     - parameter rows: number of rows in matrix
     - parameter columns: number of columns in matrix
     */
    public init(rows: Int, columns: Int) throws {
        let grid = Array(repeating: 0.0, count: rows * columns)
        try self.init(grid: grid, rows: rows, columns: columns)
    }
    
    /**
     Initialization with grid that contains all the
     elements of matrix with given matrix size
     
     - parameter grid: array of matrix elements. **warning**
     Should be of rows * column size.
     - parameter rows: number of rows in matrix
     - parameter columns: number of columns in matrix
     */
    public init(grid: [Double], rows: Int, columns: Int) throws {
        guard rows * columns == grid.count else {
            throw MatrixError.failedToInitializeMatrix(
                because: "grid size \(grid.count) should equal rows * column size \(rows * columns)"
            )
        }
        
        self.rowCount = rows
        self.columnCount = columns
        self.grid = grid
    }
    
    /**
     Initialization of 
     [column vector](https://en.wikipedia.org/wiki/Row_and_column_vectors)
     with given array. Number of
     elements in array equals to number of rows in vector.
     
     - parameter vector: array with elements of vector
    */
    public init(vector: [Double]) throws {
        try self.init(grid: vector, rows: vector.count, columns: 1)
    }
    
    /**
     Initialization of 
     [column vector](https://en.wikipedia.org/wiki/Row_and_column_vectors)
     with given number of rows. Every element is assign to 0.0
     
     - parameter size: vector size
     */
    public init(vectorOf size: Int) throws {
        try self.init(rows: size, columns: 1)
    }
    
    /**
     Initialization of square matrix with given size. Number of
     elements in array equals to size * size. Every elements is
     assigned to 0.0
     
     - parameter size: number of rows and columns in matrix
     */
    public init(squareOfSize size: Int) throws {
        try self.init(rows: size, columns: size)
    }
    
    /**
     Initialization of 
     [identity matrix](https://en.wikipedia.org/wiki/Identity_matrix)
     of given sizen
     
     - parameter size: number of rows and columns in identity matrix
     */
    public init(identityOfSize size: Int) throws {
        try self.init(squareOfSize: size)
        
        for i in 0..<size {
            try self.set(value: 1, at: Index(row: i, column: i))
        }
    }
    
    /**
     Convenience initialization from 2D array
     
     - parameter array2d: 2D array representation of matrix
     */
    public init(_ array2d: [[Double]]) throws {
        try self.init(
            grid: array2d.flatMap({$0}),
            rows: array2d.count,
            columns: array2d.first?.count ?? 0
        )
    }
    
    // MARK: - Getter/Setters
    
    // Implemented as getter/setter functions rather than subscript in order to throw on invalid index.
    
    public func value(at index: Index) throws -> Double {
        try validate(index: index)
        return grid[(index.row * columnCount) + index.column]
    }
    
    public mutating func set(value: Double, at index: Index) throws {
        try validate(index: index)
        grid[(index.row * columnCount) + index.column] = value
    }
    
    /**
     Throws appropriate error if either row or column index is invalid.
     
     - parameter row: row index of element
     - parameter column: column index of element
     */
    public func validate(index: Index) throws {
        guard (0..<rowCount).contains(index.row) else {
            throw MatrixError.invalidIndexRow(row: index.row, inMatrix: self)
        }
        guard (0..<columnCount).contains(index.column) else {
            throw MatrixError.invalidIndexColumn(column: index.column, inMatrix: self)
        }
    }
}

// MARK: - Equatable

public func == (lhs: Matrix, rhs: Matrix) -> Bool {
    return lhs.rowCount == rhs.rowCount && lhs.columnCount == rhs.columnCount && lhs.grid == rhs.grid
}

// MARK: -  Matrix as KalmanInput
extension Matrix: KalmanInput {
    /**
     [Transposed](https://en.wikipedia.org/wiki/Transpose)
     version of matrix
     
     Compexity: O(n^2)
     */
    public func transposed() throws -> Matrix {
        var resultMatrix = try Matrix(rows: columnCount, columns: rowCount)
        
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                try resultMatrix.set(
                    value: value(at: Index(row: row, column: column)),
                    at: Index(row: column, column: row)
                )
            }
        }
        
        return resultMatrix
    }
    
    /**
     Addition to Unit in form: **I - A**
     where **I** - is 
     [identity matrix](https://en.wikipedia.org/wiki/Identity_matrix) 
     and **A** - is self
     
     **warning** Only for square matrices
     
     Complexity: O(n ^ 2)
     */
    public func additionToUnit() throws -> Matrix {
        guard isSquare else {
            throw MatrixError.squareMatrixRequiredForFunction(
                function: #function,
                actualMatrix: self
            )
        }
        
        return try Matrix(identityOfSize: rowCount) - self
    }
    
    /**
     Inversed matrix if
     [it is invertible](https://en.wikipedia.org/wiki/Invertible_matrix)
     */
    public func inversed() throws -> Matrix {
        guard isSquare else {
            throw MatrixError.squareMatrixRequiredForFunction(
                function: #function,
                actualMatrix: self
            )
        }
        
        guard rowCount > 0 else { return self }
        
        guard rowCount > 1 else {
            let onlyValue = try value(at: Index(row: 0, column: 0))
            return try Matrix(
                grid: [ 1 / onlyValue ],
                rows: 1,
                columns: 1
            )
        }
        
        var resultMatrix = try Matrix(squareOfSize: rowCount)
        let tM = try transposed()
        let det = try determinant()
        
        for i in 0..<rowCount {
            for j in 0..<rowCount {
                let sign = (i + j) % 2 == 0 ? 1.0: -1.0
                let value = try tM.additionalMatrix(forIndex: Index(row: i, column: j)).determinant()
                try resultMatrix.set(
                    value: sign * value / det,
                    at: Index(row: i, column: j)
                )
            }
        }
        
        return resultMatrix
    }
    
    /**
     [Matrix determinant](https://en.wikipedia.org/wiki/Determinant)
     */
    public func determinant() throws -> Double {
        guard isSquare else {
            throw MatrixError.squareMatrixRequiredForFunction(
                function: #function,
                actualMatrix: self
            )
        }
        
        var result = 0.0
        
        if rowCount == 1 {
            result = try self.value(at: Index(row: 0, column: 0))
            
        } else {
            for row in 0..<rowCount {
                let sign = row % 2 == 0 ? 1.0 : -1.0
                let value = try self.value(at: Index(row: row, column: 0))
                let additionalMatrixDeterminant = try self.additionalMatrix(forIndex: Index(row: row, column: 0)).determinant()
                result += sign * value * additionalMatrixDeterminant
            }
        }
        
        return result
    }
    
    public func additionalMatrix(forIndex index: Index) throws -> Matrix {
        try self.validate(index: index)
        
        var resultMatrix = try Matrix(rows: rowCount - 1, columns: columnCount - 1)
        
        for row in 0..<rowCount where row != index.row {
            for column in 0..<columnCount where column != index.column {
                let resultRow = row < index.row ? row : row - 1
                let resultColumn = column < index.column ? column : column - 1
                
                try resultMatrix.set(
                    value: try self.value(at: Index(row: row, column: column)),
                    at: Index(row: resultRow, column: resultColumn)
                )
            }
        }
        return resultMatrix
    }
    
    // MARK: - Private methods
    
    public func operate(
        with otherMatrix: Matrix,
        closure: (Double, Double) -> Double) throws -> Matrix
    {
        guard rowCount == otherMatrix.rowCount && columnCount == otherMatrix.columnCount else {
            throw MatrixError.matricesOfEqualSizeRequiredForFunction(
                function: #function,
                firstMatrix: self,
                secondMatrix: otherMatrix
            )
        }
        
        var resultMatrix = try Matrix(rows: rowCount, columns: columnCount)
        
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                let index = Index(row: row, column: column)
                let value = try closure(
                    self.value(at: index),
                    otherMatrix.value(at: index)
                )
                
                try resultMatrix.set(
                    value: value,
                    at: Index(row: row, column: column)
                )
            }
        }
        
        return resultMatrix
    }
}

/**
 Naive add matrices
 
 Complexity: O(n^2)
 */
public func + (lhs: Matrix, rhs: Matrix) throws -> Matrix {
    return try lhs.operate(with: rhs, closure: +)
}

/**
 Naive subtract matrices
 
 Complexity: O(n^2)
 */
public func - (lhs: Matrix, rhs: Matrix) throws -> Matrix {
    return try lhs.operate(with: rhs, closure: -)
}


/**
 Naive matrices multiplication
 
 Complexity: O(n^3)
 */
public func * (lhs: Matrix, rhs: Matrix) throws -> Matrix {
    guard lhs.columnCount == rhs.rowCount else {
        throw MatrixError.firstMatrixColumnSizeFailedToMatchSecondMatrixRowSize(
            function: #function,
            firstMatrix: lhs,
            secondMatrix: rhs
        )
    }
    
    
    var resultMatrix = try Matrix(rows: lhs.rowCount, columns: rhs.columnCount)
    
    for i in 0..<resultMatrix.rowCount {
        for j in 0..<resultMatrix.columnCount {
            var currentValue = 0.0
            
            for k in 0..<lhs.columnCount {
                currentValue += try lhs.value(at: Matrix.Index(row: i, column: k)) *
                    rhs.value(at: Matrix.Index(row: k, column: j))
            }
            
            try resultMatrix.set(value: currentValue, at: Matrix.Index(row: i, column: j))
        }
    }
    
    return resultMatrix
}

// MARK: - Nice additional methods

public func * (lhs: Matrix, rhs: Double) throws -> Matrix {
    return try Matrix(grid: lhs.grid.map({ $0*rhs }), rows: lhs.rowCount, columns: lhs.columnCount)
}

public func * (lhs: Double, rhs: Matrix) throws -> Matrix {
    return try rhs * lhs
}

// MARK: - CustomStringConvertible

extension Matrix: CustomStringConvertible {
    public var description: String {
        var description = ""
        
        for row in 0..<rowCount {
            let contents = (0..<columnCount)
                .flatMap({ try? self.value(at: Matrix.Index(row: row, column: $0)) })
                .map({ $0.description })
                .joined(separator: "\t")
            
            switch (row, rowCount) {
            case (0, 1):
                description += "(\t\(contents)\t)"
            case (0, _):
                description += "⎛\t\(contents)\t⎞"
            case (rowCount - 1, _):
                description += "⎝\t\(contents)\t⎠"
            default:
                description += "⎜\t\(contents)\t⎥"
            }
            
            description += "\n"
        }
        
        return description
    }
}
