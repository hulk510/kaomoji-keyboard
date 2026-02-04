import XCTest
@testable import KaomojiKeyboard

final class SharedSettingsTests: XCTestCase {

    func testGridColumnsDefault() {
        XCTAssertEqual(SharedSettings.gridColumns, 4)
    }

    func testDefaultBracketIDDefault() {
        XCTAssertEqual(SharedSettings.defaultBracketID, "round")
    }

    func testHiddenTabsDefault() {
        XCTAssertEqual(SharedSettings.hiddenTabs, [])
    }

    func testFeatureFlagDefault() {
        XCTAssertFalse(SharedSettings.featureFlag("nonexistent"))
    }
}
