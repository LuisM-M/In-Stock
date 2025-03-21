import Foundation

class AIAssistantViewModel: ObservableObject {
    private let apiKey = APIKeys.deepseekAPI
    private let baseURL = "https://api.deepseek.com/v1/chat/completions"
    
    @Published var messages: [ChatMessage] = []
    @Published var inputMessage = ""
    @Published var isLoading = false
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let content: String
        let isUser: Bool
        let timestamp = Date()
    }
    
    // Add time window check for discounted rates
    private func isDiscountTimeWindow() -> Bool {
        let utcCalendar = Calendar.current.timeZone == TimeZone(identifier: "UTC") 
            ? Calendar.current 
            : Calendar(identifier: .gregorian)
        
        let now = Date()
        let utcComponents = utcCalendar.dateComponents([.hour, .minute], from: now)
        
        guard let hour = utcComponents.hour, let minute = utcComponents.minute else {
            return false
        }
        
        let currentTimeInMinutes = hour * 60 + minute
        let startDiscountTime = 16 * 60 + 30  // 16:30 UTC
        let endDiscountTime = 24 * 60 + 30    // 00:30 UTC next day
        
        return currentTimeInMinutes >= startDiscountTime || currentTimeInMinutes <= endDiscountTime
    }
    
    func sendMessage() async {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Check if current time is outside discount window
        if !isDiscountTimeWindow() {
            // Add warning for non-discount hours
            await MainActor.run {
                messages.append(ChatMessage(
                    content: "Note: For better rates, try using the assistant during UTC 16:30-00:30 (50% discount)",
                    isUser: false
                ))
            }
        }
        
        let userMessage = inputMessage
        
        await MainActor.run {
            messages.append(ChatMessage(content: userMessage, isUser: true))
            inputMessage = ""
            isLoading = true
        }
        
        // Optimize request for cost savings
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": "You are a concise kitchen assistant. Provide brief, practical advice about recipes and food."],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.5,
            "max_tokens": 100,     // Reduced from 150 to save tokens
            "stream": false
        ]
        
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, httpResponse) = try await URLSession.shared.data(for: request)
            
            // Print response for debugging
            if let httpResponse = httpResponse as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response data: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(DeepSeekResponse.self, from: data)
            
            await MainActor.run {
                if let content = apiResponse.choices.first?.message.content {
                    messages.append(ChatMessage(content: content, isUser: false))
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                messages.append(ChatMessage(content: "Sorry, I encountered an error: \(error.localizedDescription)", isUser: false))
                isLoading = false
            }
            print("Error: \(error)")
        }
    }
}

// Updated DeepSeek API Response Models
struct DeepSeekResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index
        case message
        case finishReason = "finish_reason"
    }
}

struct Message: Codable {
    let role: String
    let content: String
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
} 