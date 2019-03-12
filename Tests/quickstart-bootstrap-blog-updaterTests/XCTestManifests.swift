import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(quickstart_bootstrap_blog_updaterTests.allTests),
    ]
}
#endif