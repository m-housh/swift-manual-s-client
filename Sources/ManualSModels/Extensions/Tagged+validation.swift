import Tagged
import Validations

extension Tagged: @retroactive Validatable where RawValue: Validatable {

  public var body: some Validation<Self> {
    Validator.validate(\.rawValue)
  }

}
extension Tagged: @retroactive Validation where RawValue: Validatable {}
