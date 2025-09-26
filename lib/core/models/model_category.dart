enum ModelCategory {
  chat, // text->text chat/completions
  reasoning, // OpenAI o1/o3 or Gemini “thinking”
  embeddings, // vector embeddings
  image, // image generation
  audioTts, // text-to-speech
  audioTranscribe, // speech-to-text
  moderation, // moderation/filtering
  other, // everything else / unknown
}
