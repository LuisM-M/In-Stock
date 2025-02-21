import Foundation

struct Food: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    var quantity: Int
    var isFrozen: Bool
    var expirationDate: Date?
} 