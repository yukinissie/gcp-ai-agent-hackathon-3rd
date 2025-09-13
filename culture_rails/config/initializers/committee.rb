# Committee Rails configuration
Committee::Rails.configure do |config|
  # OpenAPI schema file path
  config.schema_path = Rails.root.join('doc', 'openapi.yml')

  # Enable request validation
  config.request_validation = true

  # Enable response validation (disable in production for performance)
  config.response_validation = Rails.env.development? || Rails.env.test?

  # Query parameter validation
  config.query_hash_key = :query

  # Parameter coercion
  config.parameter_coercion = true

  # Optimistic parsing (don't fail on unknown properties)
  config.parse_response_by_content_type = true

  # Accept request filters (only validate API routes)
  config.accept_request_filter = -> (request) do
    request.path.start_with?('/api/')
  end
end
