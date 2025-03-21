import SwiftUI

struct AIAssistantView: View {
    @StateObject private var viewModel = AIAssistantViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("AI Kitchen Assistant")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 15) {
                        if viewModel.messages.isEmpty {
                            // Placeholder content when no messages
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
                        } else {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message)
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
            
            // Loading indicator
            if viewModel.isLoading {
                ProgressView("Thinking...")
                    .padding()
            }
            
            // Input area
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                    .shadow(radius: 2)
                
                HStack(spacing: 12) {
                    TextField("Ask about recipes, expiration dates", text: $viewModel.inputMessage)
                        .textFieldStyle(.plain)
                        .disabled(viewModel.isLoading)
                        .submitLabel(.send)
                        .onSubmit {
                            if !viewModel.inputMessage.isEmpty {
                                Task {
                                    await viewModel.sendMessage()
                                }
                            }
                        }
                    
                    Button(action: {
                        Task {
                            await viewModel.sendMessage()
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(viewModel.inputMessage.isEmpty ? .gray : .blue)
                    }
                    .disabled(viewModel.inputMessage.isEmpty || viewModel.isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

struct ChatBubble: View {
    let message: AIAssistantViewModel.ChatMessage
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(
                        message.isUser ? Color.blue :
                            (colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                    )
                    .foregroundColor(
                        message.isUser ? .white :
                            (colorScheme == .dark ? .white : .primary)
                    )
                    .cornerRadius(15)
                    .shadow(radius: 1)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
} 