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
          env[:body] = response.parsed_body
        end
      end

      private

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
