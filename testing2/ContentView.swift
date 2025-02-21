//
//  ContentView.swift
//  testing2
//
//  Created by Luis Martinez on 2/13/25.
//

import SwiftUI

struct ContentView: View {
    @State private var foodItems: [Food] = [
        Food(name: "Eggs", image: "egg", quantity: 6, isFrozen: false),
        Food(name: "Chicken", image: "bird", quantity: 1, isFrozen: true),
        Food(name: "Bread", image: "birthday.cake", quantity: 1, isFrozen: false),
        Food(name: "Parmesan cheese", image: "circle", quantity: 1, isFrozen: false),
        Food(name: "Tomato sauce", image: "drop.fill", quantity: 1, isFrozen: false),
        Food(name: "Basil", image: "leaf", quantity: 1, isFrozen: false),
        Food(name: "Salt", image: "circle.fill", quantity: 1, isFrozen: false),
        Food(name: "Pepper", image: "circle.dotted", quantity: 1, isFrozen: false),
        Food(name: "Oil", image: "drop", quantity: 1, isFrozen: false),
        Food(name: "Spaghetti", image: "line.3.horizontal", quantity: 1, isFrozen: false),
        Food(name: "Garlic", image: "circle.circle", quantity: 1, isFrozen: false)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your stock")
                        .font(.title)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(foodItems) { food in
                            NavigationLink(destination: FoodDetailView(food: food)) {
                                FoodItemCard(food: food)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing: Button(action: {
                // Add new item functionality
            }) {
                Image(systemName: "plus")
            })
        }
    }
}

struct FoodItemCard: View {
    let food: Food
    
    var body: some View {
        VStack {
            Image(systemName: food.image)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .padding()
                .foregroundColor(.blue)
            
            Text(food.name)
                .font(.caption)
                .foregroundColor(.primary)
            
            HStack {
                Button(action: {
                    // Decrease quantity
                }) {
                    Image(systemName: "minus")
                        .padding(5)
                }
                
                Text("\(food.quantity)")
                    .padding(.horizontal, 5)
                
                Button(action: {
                    // Increase quantity
                }) {
                    Image(systemName: "plus")
                        .padding(5)
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Button("Remove") {
                // Remove item
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    ContentView()
}
