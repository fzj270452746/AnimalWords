import Foundation

class AnimalWordsWordValidator: ObservableObject {
    static let shared = AnimalWordsWordValidator()
    
    // Basic English word list for offline validation
    private let animalWordsCommonWords: Set<String> = [
        "cat", "dog", "bird", "fish", "lion", "bear", "wolf", "deer", "fox", "owl",
        "bat", "cow", "pig", "hen", "duck", "goat", "sheep", "horse", "mouse", "rat",
        "bee", "ant", "fly", "bug", "frog", "toad", "crab", "seal", "whale", "shark",
        "snake", "lizard", "tiger", "zebra", "giraffe", "elephant", "monkey", "ape",
        "rabbit", "squirrel", "chipmunk", "beaver", "otter", "badger", "skunk", "raccoon",
        "the", "and", "you", "that", "was", "for", "are", "with", "his", "they",
        "this", "have", "from", "one", "had", "word", "but", "not", "what", "all",
        "were", "they", "been", "said", "each", "which", "she", "how", "will", "other",
        "its", "who", "oil", "now", "find", "long", "down", "day", "did", "get",
        "come", "made", "may", "part", "over", "new", "sound", "take", "only", "little",
        "work", "know", "place", "year", "live", "back", "give", "most", "very", "after",
        "thing", "our", "just", "name", "good", "sentence", "man", "think", "say", "great",
        "where", "help", "through", "much", "before", "line", "right", "too", "mean", "old",
        "any", "same", "tell", "boy", "follow", "came", "want", "show", "also", "around",
        "form", "three", "small", "set", "put", "end", "why", "again", "turn", "here",
        "move", "like", "well", "such", "because", "large", "must", "big", "even", "between",
        "read", "need", "land", "different", "home", "hand", "picture", "try", "us", "again",
        "animal", "point", "mother", "world", "near", "build", "self", "earth", "father"
    ]
    
    private init() {}
    
    // MARK: - Word Validation
    func animalWordsValidateWord(_ word: String) async -> AnimalWordsValidationResponse {
        let cleanWord = word.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Check minimum length
        guard cleanWord.count >= 2 else {
            return AnimalWordsValidationResponse(isValid: false, word: cleanWord)
        }
        
        // First check against local dictionary
        if animalWordsCommonWords.contains(cleanWord) {
            return AnimalWordsValidationResponse(isValid: true, word: cleanWord, definition: animalWordsGetBasicDefinition(for: cleanWord))
        }
        
        // Try online validation as fallback
        return await animalWordsValidateWordOnline(cleanWord)
    }
    
    private func animalWordsGetBasicDefinition(for word: String) -> String {
        // Basic definitions for common animal words
        let animalWordsDefinitions: [String: String] = [
            "cat": "A small domesticated carnivorous mammal",
            "dog": "A domesticated carnivorous mammal",
            "bird": "A warm-blooded egg-laying vertebrate with feathers",
            "fish": "A limbless cold-blooded vertebrate animal with gills",
            "lion": "A large tawny-colored cat that lives in prides",
            "bear": "A large, heavy mammal with thick fur",
            "wolf": "A wild carnivorous mammal, ancestor of the domestic dog",
            "deer": "A hoofed grazing or browsing animal",
            "fox": "A carnivorous mammal with a pointed muzzle and bushy tail",
            "owl": "A nocturnal bird of prey with large forward-facing eyes"
        ]
        
        return animalWordsDefinitions[word] ?? "A valid English word"
    }
    
    private func animalWordsValidateWordOnline(_ word: String) async -> AnimalWordsValidationResponse {
        // For this demo, we'll use a simple online dictionary API
        // In a real app, you might use APIs like Merriam-Webster, Oxford, etc.
        
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)") else {
            return AnimalWordsValidationResponse(isValid: false, word: word)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Word exists in dictionary
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                   let firstEntry = jsonArray.first,
                   let meanings = firstEntry["meanings"] as? [[String: Any]],
                   let firstMeaning = meanings.first,
                   let definitions = firstMeaning["definitions"] as? [[String: Any]],
                   let firstDefinition = definitions.first,
                   let definition = firstDefinition["definition"] as? String {
                    
                    return AnimalWordsValidationResponse(isValid: true, word: word, definition: definition)
                }
                
                return AnimalWordsValidationResponse(isValid: true, word: word, definition: "A valid English word")
            } else {
                // Word not found
                return AnimalWordsValidationResponse(isValid: false, word: word)
            }
        } catch {
            // Network error - fall back to offline validation
            return animalWordsValidateWordOffline(word)
        }
    }
    
    private func animalWordsValidateWordOffline(_ word: String) -> AnimalWordsValidationResponse {
        // Extended offline validation using basic English patterns
        let cleanWord = word.lowercased()
        
        // Check for very short words that are commonly valid
        let animalWordsShortValidWords: Set<String> = [
            "a", "i", "am", "an", "as", "at", "be", "by", "do", "go", "he", "if", "in", "is", "it",
            "me", "my", "no", "of", "on", "or", "so", "to", "up", "we", "ox", "yo"
        ]
        
        if animalWordsShortValidWords.contains(cleanWord) {
            return AnimalWordsValidationResponse(isValid: true, word: cleanWord)
        }
        
        // For longer words, use basic heuristics
        if cleanWord.count >= 3 {
            // Check if it contains only letters
            let animalWordsLetterSet = CharacterSet.letters
            if cleanWord.rangeOfCharacter(from: animalWordsLetterSet.inverted) == nil {
                // Basic validation - in a real app, you'd want a more comprehensive dictionary
                return AnimalWordsValidationResponse(isValid: true, word: cleanWord)
            }
        }
        
        return AnimalWordsValidationResponse(isValid: false, word: cleanWord)
    }
    
    // MARK: - Batch Validation
    func animalWordsValidateWords(_ words: [String]) async -> [AnimalWordsValidationResponse] {
        var results: [AnimalWordsValidationResponse] = []
        
        for word in words {
            let result = await animalWordsValidateWord(word)
            results.append(result)
        }
        
        return results
    }
} 