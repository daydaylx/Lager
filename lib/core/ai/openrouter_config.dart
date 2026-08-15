class OpenRouterConfig {
  final bool enabled;
  final String apiKey;
  final String modelId;

  const OpenRouterConfig({
    required this.enabled,
    required this.apiKey,
    required this.modelId,
  });

  const OpenRouterConfig.fromEnvironment()
      : enabled = const bool.fromEnvironment('OPENROUTER_ENABLED'),
        apiKey = const String.fromEnvironment('OPENROUTER_API_KEY'),
        modelId = const String.fromEnvironment('OPENROUTER_MODEL_ID');

  static const disabled = OpenRouterConfig(
    enabled: false,
    apiKey: '',
    modelId: '',
  );

  bool get isConfigured =>
      enabled && apiKey.trim().isNotEmpty && modelId.trim().isNotEmpty;
}
