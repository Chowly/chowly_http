# frozen_string_literal: true

Faraday::RackBuilder.class_eval do
  def build_env(connection, request)
    env = Faraday::Env.new(request.http_method, request.body,
                           connection.build_exclusive_url(request.path, request.params, request.options.params_encoder),
                           request.options, request.headers, connection.ssl,
                           connection.parallel_manager)
    env.proxy_headers = request.proxy_headers
    env
  end
end
