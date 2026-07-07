import XCTest
@testable import CarShowEntryLog

@MainActor
final class CarShowEntryLogTests: XCTestCase {
    var store: ShowEntryStore!

    override func setUp() {
        super.setUp()
        store = ShowEntryStore()
    }

    func testSeedDataBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, ShowEntryStore.freeLimit)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        let added = store.add(ShowEntry(name: "Test", detail: "d", date: Date()))
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testFreeLimitBlocksAdd() {
        for i in 0..<20 {
            _ = store.add(ShowEntry(name: "Item \(i)", detail: "d", date: Date()))
        }
        XCTAssertEqual(store.items.count, ShowEntryStore.freeLimit)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<20 {
            _ = store.add(ShowEntry(name: "Item \(i)", detail: "d", date: Date()))
        }
        XCTAssertGreaterThan(store.items.count, ShowEntryStore.freeLimit)
    }

    func testDeleteRemovesItem() {
        let item = ShowEntry(name: "ToDelete", detail: "d", date: Date())
        _ = store.add(item)
        store.delete(id: item.id)
        XCTAssertFalse(store.items.contains(where: { $0.id == item.id }))
    }

    func testUpdateChangesFields() {
        var item = ShowEntry(name: "Orig", detail: "d", date: Date())
        _ = store.add(item)
        item.name = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.name, "Updated")
    }

    func testCanAddMoreReflectsLimit() {
        while store.canAddMore {
            _ = store.add(ShowEntry(name: "X", detail: "d", date: Date()))
        }
        XCTAssertFalse(store.canAddMore)
    }
}
