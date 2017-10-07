import Foundation

extension Double: KalmanInput {
    public func transposed() throws -> Double {
        return self
    }
    
    public func inversed() throws -> Double {
        return 1 / self
    }
    
    public func additionToUnit() throws -> Double {
        return 1 - self
    }
}
