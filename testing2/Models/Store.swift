import Foundation
import CoreLocation
import MapKit

struct Store: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let distance: Double
    let coordinate: CLLocationCoordinate2D
    let placemark: MKPlacemark
} 