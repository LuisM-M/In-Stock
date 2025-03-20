import Foundation

class AIAssistantViewModel: ObservableObject {
    private let apiKey = "YOUR_OPENAI_API_KEY" // Replace with your OpenAI API key
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    @Published var messages: [ChatMessage] = []
    @Published var inputMessage = ""
    @Published var isLoading = false
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let content: String
        let isUser: Bool
        let timestamp = Date()
    }
    
    func sendMessage() async {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = inputMessage
        
        // Add user message to chat
        await MainActor.run {
            messages.append(ChatMessage(content: userMessage, isUser: true))
            inputMessage = ""
            isLoading = true
        }
        
        // Prepare the request
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful kitchen assistant that provides recipe suggestions, food expiration information, and cooking tips."],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            await MainActor.run {
                if let content = response.choices.first?.message.content {
                    messages.append(ChatMessage(content: content, isUser: false))
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                messages.append(ChatMessage(content: "Sorry, I encountered an error. Please try again.", isUser: false))
                isLoading = false
            }
            print("Error: \(error)")
        }
    }
}

// OpenAI API Response Models
struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct Message: Codable {
    let role: String
    let content: String
} 