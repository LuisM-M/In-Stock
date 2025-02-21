import SwiftUI

struct FoodDetailView: View {
    let food: Food
    @State private var isFrozen: Bool
    @State private var quantity: Int
    
    init(food: Food) {
        self.food = food
        _isFrozen = State(initialValue: food.isFrozen)
        _quantity = State(initialValue: food.quantity)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Food Image
                Image(systemName: food.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                
                // Food Details
                VStack(alignment: .leading, spacing: 15) {
                    Text(food.name)
                        .font(.title)
                        .bold()
                    
                    // Expiration Date
                    DatePicker(
                        "Expiration Date",
                        selection: .constant(food.expirationDate ?? Date()),
                        displayedComponents: [.date]
                    )
                    
                    // Frozen Toggle
                    Toggle("Frozen", isOn: $isFrozen)
                    
                    // Quantity Stepper
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 0...100)
                }
                .padding()
                
                // Recipes Button
                NavigationLink(destination: RecipesView(ingredient: food.name)) {
                    Text("View Recipes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 