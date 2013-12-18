# -*- encoding : utf-8 -*-
require 'faraday'
require 'json'
require 'ashikawa-core/response'

module Ashikawa
  module Core
    # Preprocessor for Faraday Requests
    class ResponsePreprocessor < Faraday::Middleware
      # Create a new Response Preprocessor
      #
      # @param [Object] app Faraday internal
      # @param [Object] logger The object you want to log to
      # @return [ResponsePreprocessor]
      # @api private
      def initialize(app, logger)
        @app = app
        @logger = logger
      end

      # Process a Response
      #
      # @param [Hash] env Environment info
      # @return [Object]
      # @api private
      def call(env)
        @app.call(env).on_complete do
          log(env)
          response = Response.new(env)
          response.handle_status
          env[:body] = parse_json(env)
        end
      end

      private

      # Parse the JSON
      #
      # @param [Hash] env Environment info
      # @return [Hash] The parsed body
      # @api private
      def parse_json(env)
        raise JSON::ParserError unless json_content_type?(env[:response_headers]['content-type'])
        JSON.parse(env[:body])
      rescue JSON::ParserError
        raise Ashikawa::Core::JsonError
      end

      # Check if the Content Type is JSON
      #
      # @param [String] content_type
      # @return [Boolean]
      # @api private
      def json_content_type?(content_type)
        content_type == 'application/json; charset=utf-8'
      end

      # Log a Request
      #
      # @param [Hash] env Environment info
      # @return [nil]
      # @api private
      def log(env)
        @logger.info("#{env[:status]} #{env[:body]}")
        nil
      end
    end

    Faraday.register_middleware :response,
                                ashikawa_response: -> { ResponsePreprocessor}
  end
end
