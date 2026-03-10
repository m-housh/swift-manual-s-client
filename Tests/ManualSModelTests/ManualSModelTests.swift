import ManualSModels
import Testing
import Validations

@Suite
struct ManualSModelTests {

  @Test
  func coolingContainerValidations() {
    let sut = CoolingContainer<Double>(total: 100, sensible: 101)
    #expect(throws: ValidationError.self) {
      try sut.validate()
    }
  }

  @Test
  func coolingInterpolationValidation() {
    let sut = CoolingInterpolation.Interpolation.noInterpolation(.init(total: 100, sensible: 101))
    #expect(throws: ValidationError.self) {
      try sut.validate()
    }
  }
}
