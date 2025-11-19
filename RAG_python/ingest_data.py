# upload_files.py

import os
import sys
import time
from dotenv import load_dotenv
from google import genai
from google.genai import types

# Load environment variables from .env file
load_dotenv()

# --- Configuration ---
# ⚠️ 1. Set the display name for your store
FILE_STORE_DISPLAY_NAME = 'Flutter Chatbot Knowledge Base'
# ⚠️ 2. Set the directory containing your JSON files
DATA_DIRECTORY = 'data'
# ⚠️ 3. Specify the mime type for your files (important for processing)
MIME_TYPE = 'application/json'
# ---------------------


def create_or_get_store(client: genai.Client) -> types.FileSearchStore:
    """Finds an existing store by display name or creates a new one."""

    print(f"Checking for store: '{FILE_STORE_DISPLAY_NAME}'...")

    # List existing stores
    existing_stores = list(client.file_search_stores.list())
    for store in existing_stores:
        if store.display_name == FILE_STORE_DISPLAY_NAME:
            print(f"✅ Found existing store: {store.name}")
            return store

    # If not found, create a new one
    print("Store not found. Creating a new File Search Store...")
    new_store = client.file_search_stores.create(
        config={'display_name': FILE_STORE_DISPLAY_NAME}
    )
    print(f"✅ Created new store: {new_store.name}")
    return new_store


def upload_and_process_files(client: genai.Client, store_name: str):
    """Uploads all files from the data directory to the specified store."""

    if not os.path.exists(DATA_DIRECTORY):
        print(f"❌ Error: Directory '{DATA_DIRECTORY}' not found.")
        return

    json_files = [f for f in os.listdir(DATA_DIRECTORY) if f.endswith('.json')]
    if not json_files:
        print(
            f"⚠️ No JSON files found in '{DATA_DIRECTORY}'. Nothing to upload.")
        return

    print(
        f"\nFound {len(json_files)} JSON files. Starting upload and indexing...")

    for filename in json_files:
        file_path = os.path.join(DATA_DIRECTORY, filename)

        print(f"\n--- Processing {filename} ---")

        try:
            # Upload the file and initiate the indexing process
            operation = client.file_search_stores.upload_to_file_search_store(
                file=file_path,
                file_search_store_name=store_name,
                config={
                    'display_name': filename,
                    # 'mime_type': MIME_TYPE,
                    # Optional: Custom chunking config for complex JSON data
                    # 'chunking_config': {
                    #     'white_space_config': {
                    #         'max_tokens_per_chunk': 512,
                    #         'max_overlap_tokens': 50
                    #     }
                    # }
                }
            )

            print("🚀 Upload initiated. Waiting for indexing to complete...")

            # Polling the long-running operation status
            while not operation.done:
                time.sleep(5)
                operation = client.operations.get(operation)
                print(".", end="", flush=True)

            if operation.error:
                print(
                    f"\n❌ Indexing failed for {filename}: {operation.error.message}")
            else:
                print(f"\n✅ Indexing complete for {filename}.")

        except Exception as e:
            print(f"\n❌ An error occurred while processing {filename}: {e}")


def get_api_key():
    """Get API key from .env file or environment variable."""
    # Get API key from environment (loaded from .env file by dotenv)
    api_key = os.getenv('GEMINI_API_KEY')

    if not api_key:
        print("❌ Error: GEMINI_API_KEY not found!")
        print("\nTo fix this:")
        print("1. Create a .env file in the same directory as this script")
        print("2. Add your API key to the .env file:")
        print("   GEMINI_API_KEY=your-api-key-here")
        print("\n3. Get your API key from: https://aistudio.google.com/app/apikey")
        print("\n📝 Example .env file content:")
        print("   GEMINI_API_KEY=AIzaSyD...your-actual-key-here")
        sys.exit(1)

    return api_key


def main():
    try:
        # Get API key
        api_key = get_api_key()

        # Initialize the client with API key
        client = genai.Client(api_key=api_key)

        # Step 1: Create or get the File Search Store
        file_store = create_or_get_store(client)

        # Step 2: Upload and process all JSON files
        upload_and_process_files(client, file_store.name)

        print(
            f"\nSetup Complete! Use this store name in your Cloudflare Worker: **{file_store.name}**")

    except Exception as e:
        print(
            f"\n🛑 Fatal Error during client initialization or main process: {e}")
        if "api_key" in str(e).lower():
            print("\n💡 This seems to be an API key issue. Please check:")
            print("1. Your API key is correct")
            print("2. Your API key has the necessary permissions")
            print("3. You have sufficient quota/credits")

if __name__ == "__main__":
    main()
