import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  [testCase(WebServiceTests.allTests)]
}
#endif
