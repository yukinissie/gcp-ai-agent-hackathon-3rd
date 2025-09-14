# Committee Rails configuration
# Note: OpenAPI parser deprecation warning is expected and will be addressed in future gem versions

Rails.application.configure do
  # Only enable committee middleware in development and test environments
  if Rails.env.development? || Rails.env.test?
    schema_path = Rails.root.join('doc', 'openapi.yml')

    if File.exist?(schema_path)
      config.middleware.use Committee::Middleware::RequestValidation,
                            schema_path: schema_path,
                            accept_request_filter: -> (request) { request.path.start_with?('/api/') }

      config.middleware.use Committee::Middleware::ResponseValidation,
                            schema_path: schema_path,
                            accept_request_filter: -> (request) { request.path.start_with?('/api/') }
    end
  end
end
