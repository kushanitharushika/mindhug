import urllib.request
import json
import time

BASE_URL = "http://127.0.0.1:8000"

def test_api():
    print("Waiting for server...")
    time.sleep(5)
    
    try:
        # Test 1: Home
        with urllib.request.urlopen(f"{BASE_URL}/") as response:
            print(f"Home Response: {json.loads(response.read().decode())}")
        
        # Test 2: Recommend (Level 0, Mood 0)
        data = json.dumps({"level": 0, "mood": 0}).encode("utf-8")
        req = urllib.request.Request(f"{BASE_URL}/recommend", data=data, headers={'Content-Type': 'application/json'})
        with urllib.request.urlopen(req) as response:
            print(f"Recommendation (Level 0, Mood 0): {json.loads(response.read().decode())}")

        # Test 3: Recommend (Level 3, Mood 4)
        data = json.dumps({"level": 3, "mood": 4}).encode("utf-8")
        req = urllib.request.Request(f"{BASE_URL}/recommend", data=data, headers={'Content-Type': 'application/json'})
        with urllib.request.urlopen(req) as response:
            print(f"Recommendation (Level 3, Mood 4): {json.loads(response.read().decode())}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_api()
