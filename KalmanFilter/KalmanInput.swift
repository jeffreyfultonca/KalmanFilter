import Foundation

public protocol KalmanInput {
    func transposed() throws -> Self
    func inversed() throws -> Self
    func additionToUnit() throws -> Self
    
    static func + (lhs: Self, rhs: Self) throws -> Self
    static func - (lhs: Self, rhs: Self) throws -> Self
    static func * (lhs: Self, rhs: Self) throws -> Self
}
