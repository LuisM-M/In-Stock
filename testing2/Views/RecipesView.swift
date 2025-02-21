import SwiftUI

struct RecipesView: View {
    let ingredient: String
    @State private var recipes: [Recipe] = []
    
    var body: some View {
        List(recipes) { recipe in
            VStack(alignment: .leading) {
                Text(recipe.title)
                    .font(.headline)
                Text("Cooking time: \(recipe.cookingTime) minutes")
                    .font(.subheadline)
            }
        }
        .navigationTitle("Recipes with \(ingredient)")
        .onAppear {
            // Here you would fetch recipes from an API
            // For now, we'll use sample data
            recipes = [
                Recipe(title: "Sample Recipe 1", cookingTime: 30),
                Recipe(title: "Sample Recipe 2", cookingTime: 45)
            ]
        }
    }
}

struct Recipe: Identifiable {
    let id = UUID()
    let title: String
    let cookingTime: Int
} 