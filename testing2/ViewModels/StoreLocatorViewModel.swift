import Foundation
import CoreLocation
import MapKit

class StoreLocatorViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var stores: [Store] = []
    @Published var userLocation: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "Please enable location access in Settings to find nearby stores."
        @unknown default:
            break
        }
    }
    
    private func startUpdatingLocation() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            errorMessage = "Location access not authorized"
            return
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = "Please enable Location Services in Settings"
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdatingLocation()
            case .denied, .restricted:
                self.errorMessage = "Location access denied. Please enable in Settings."
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
            @unknown default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.userLocation = location
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            self.searchNearbyGroceryStores()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.errorMessage = "Location access denied. Please enable in Settings."
                case .locationUnknown:
                    self.errorMessage = "Unable to determine location. Please try again."
                default:
                    self.errorMessage = "Location error: \(error.localizedDescription)"
                }
            } else {
                self.errorMessage = "Location error: \(error.localizedDescription)"
            }
            print("Location error: \(error.localizedDescription)")
        }
    }
    
    private func searchNearbyGroceryStores() {
        guard let location = userLocation else { return }
        
        isLoading = true
        errorMessage = nil
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "grocery store supermarket"
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to find stores: \(error.localizedDescription)"
                    return
                }
                
                guard let response = response else {
                    self.errorMessage = "No stores found nearby"
                    return
                }
                
                self.stores = response.mapItems.map { item in
                    Store(
                        name: item.name ?? "Unknown Store",
                        address: item.placemark.thoroughfare ?? item.placemark.title ?? "Unknown Address",
                        distance: location.distance(from: item.placemark.location ?? location) / 1609.34,
                        coordinate: item.placemark.coordinate,
                        placemark: item.placemark
                    )
                }
                
                if !self.stores.isEmpty {
                    let allCoordinates = self.stores.map { $0.coordinate } + [location.coordinate]
                    let minLat = allCoordinates.map { $0.latitude }.min()!
                    let maxLat = allCoordinates.map { $0.latitude }.max()!
                    let minLon = allCoordinates.map { $0.longitude }.min()!
                    let maxLon = allCoordinates.map { $0.longitude }.max()!
                    
                    let center = CLLocationCoordinate2D(
                        latitude: (minLat + maxLat) / 2,
                        longitude: (minLon + maxLon) / 2
                    )
                    
                    let span = MKCoordinateSpan(
                        latitudeDelta: (maxLat - minLat) * 1.5,
                        longitudeDelta: (maxLon - minLon) * 1.5
                    )
                    
                    self.region = MKCoordinateRegion(center: center, span: span)
                }
            }
        }
    }
} 