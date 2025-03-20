import SwiftUI

struct AIAssistantView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("AI Kitchen Assistant")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding()
            
            // Placeholder content
            VStack(spacing: 15) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Ask me about:")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 10) {
                    Label("Recipe suggestions", systemImage: "fork.knife")
                    Label("Food expiration dates", systemImage: "calendar")
                    Label("Cooking tips", systemImage: "questionmark.circle")
                }
                .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(15)
            .padding()
            
            Spacer()
        }
    }
} 