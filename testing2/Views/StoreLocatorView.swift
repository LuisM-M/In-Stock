import SwiftUI
import MapKit

struct StoreLocatorView: View {
    @StateObject private var viewModel = StoreLocatorViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                Text("Grocery stores")
                    .font(.title2.bold())
                
                Spacer()
            }
            .padding()
            
            // Map
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow),
                annotationItems: viewModel.stores) { store in
                MapAnnotation(coordinate: store.coordinate) {
                    VStack {
                        Image(systemName: "cart.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .shadow(radius: 2)
                            )
                    }
                }
            }
            .frame(height: 300)
            .cornerRadius(15)
            .padding()
            
            if viewModel.isLoading {
                ProgressView("Finding stores...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                VStack {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    if error.contains("Settings") {
                        Button("Open Settings") {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                               UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
            
            // Store list
            ScrollView {
                VStack(spacing: 15) {
                    if !viewModel.stores.isEmpty {
                        Text("\(viewModel.stores.count) stores found nearby")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                    
                    ForEach(viewModel.stores.sorted { $0.distance < $1.distance }) { store in
                        StoreCard(store: store)
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.requestLocationPermission()
        }
    }
}

struct StoreCard: View {
    let store: Store
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "cart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(store.name)
                    .font(.headline)
                Text(store.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(String(format: "%.1f mi", store.distance))
                .font(.subheadline.bold())
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
} 