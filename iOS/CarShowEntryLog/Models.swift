import Foundation

struct ShowEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String        // Show name
    var detail: String      // Category
    var date: Date           // Entry date
    var note: String = ""
}
