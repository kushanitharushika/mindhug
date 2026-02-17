import json
import random
import os

class ChatbotLogic:
    def __init__(self, intents_file='chatbot_intents.json'):
        self.intents = []
        try:
            # Construct absolute path to ensure file is found
            base_dir = os.path.dirname(os.path.abspath(__file__))
            file_path = os.path.join(base_dir, intents_file)
            
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                self.intents = data.get('intents', [])
            print(f"Chatbot logic loaded {len(self.intents)} intents.")
        except Exception as e:
            print(f"Error loading chatbot intents: {e}")

    def get_response(self, message):
        if not message or not message.strip():
            return "I didn't quite catch that. Could you say it again?"

        normalized_message = message.lower().strip()
        
        # Simple pattern matching (same logic as Dart version)
        # Prioritize long matches? logic here is simple containment
        
        # Flatten patterns for easier searching
        # In a real ML app, this would use vector embeddings or a classifier
        
        matched_intent = None
        
        for intent in self.intents:
            for pattern in intent['patterns']:
                if not pattern: continue
                if pattern.lower() in normalized_message:
                    matched_intent = intent
                    break # Found a match in this intent
            if matched_intent:
                break # Found a match overall

        if matched_intent:
            return random.choice(matched_intent['responses'])
        
        return "I hear you. Tell me more about that."
