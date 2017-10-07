import Foundation

public protocol KalmanFilterType {
    associatedtype Input: KalmanInput
    
    var stateEstimatePrior: Input { get }
    var errorCovariancePrior: Input { get }
    
    func predict(stateTransitionModel: Input, controlInputModel: Input, controlVector: Input, covarianceOfProcessNoise: Input) throws -> Self
    func update(measurement: Input, observationModel: Input, covarienceOfObservationNoise: Input) throws -> Self
}
