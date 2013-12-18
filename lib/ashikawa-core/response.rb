require 'ashikawa-core/exceptions/client_error'
require 'ashikawa-core/exceptions/client_error/resource_not_found'
require 'ashikawa-core/exceptions/client_error/resource_not_found/index_not_found'
require 'ashikawa-core/exceptions/client_error/resource_not_found/document_not_found'
require 'ashikawa-core/exceptions/client_error/resource_not_found/collection_not_found'
require 'ashikawa-core/exceptions/client_error/bad_syntax'
require 'ashikawa-core/exceptions/client_error/authentication_failed'
require 'ashikawa-core/exceptions/server_error'
require 'ashikawa-core/exceptions/server_error/json_error'

module Ashikawa
  module Core
    # A response from the server
    class Response
      BadSyntaxStatus = 400
      AuthenticationFailed = 401
      ResourceNotFoundError = 404
      ClientErrorStatuses = 405...499
      ServerErrorStatuses = 500...599

      def initialize(env)
        @env = env
      end

      # Handle the status code
      #
      # @param [Hash] env Environment info
      # @return [nil]
      # @api private
      def handle_status
        case @env[:status]
        when BadSyntaxStatus then bad_syntax
        when AuthenticationFailed then authentication_failed
        when ResourceNotFoundError then resource_not_found
        when ClientErrorStatuses then client_error
        when ServerErrorStatuses then server_error
        end
      end

      # Parsed version of the body
      #
      # @param [Hash] env Environment info
      # @return [Hash] The parsed body
      # @api private
      def parsed_body
        raise JSON::ParserError unless json_content_type?(@env[:response_headers]['content-type'])
        JSON.parse(@env[:body])
      rescue JSON::ParserError
        raise Ashikawa::Core::JsonError
      end

      private

      # Check if the Content Type is JSON
      #
      # @param [String] content_type
      # @return [Boolean]
      # @api private
      def json_content_type?(content_type)
        content_type == 'application/json; charset=utf-8'
      end

      # Raise a Bad Syntax Error
      #
      # @raise [BadSyntax]
      # @return nil
      # @api private
      def bad_syntax
        raise Ashikawa::Core::BadSyntax
      end

      # Raise an Authentication Failed Error
      #
      # @raise [AuthenticationFailed]
      # @return nil
      # @api private
      def authentication_failed
        raise Ashikawa::Core::AuthenticationFailed
      end

      # Raise a Client Error for a given body
      #
      # @raise [ClientError]
      # @return nil
      # @api private
      def client_error
        raise Ashikawa::Core::ClientError, error(@env[:body])
      end

      # Raise a Server Error for a given body
      #
      # @raise [ServerError]
      # @return nil
      # @api private
      def server_error
        raise Ashikawa::Core::ServerError, error(@env[:body])
      end

      # Raise the fitting ResourceNotFoundException
      #
      # @raise [DocumentNotFoundException, CollectionNotFoundException, IndexNotFoundException]
      # @return nil
      # @api private
      def resource_not_found
        raise case @env[:url].path
              when %r{\A(/_db/[^/]+)?/_api/document} then Ashikawa::Core::DocumentNotFoundException
              when %r{\A(/_db/[^/]+)?/_api/collection} then Ashikawa::Core::CollectionNotFoundException
              when %r{\A(/_db/[^/]+)?/_api/index} then Ashikawa::Core::IndexNotFoundException
              else Ashikawa::Core::ResourceNotFound
        end
      end

      # Read the error message for the request
      #
      # @param [String] The raw body of the request
      # @return [String] The formatted error message
      # @api private
      def error(body)
        parsed_body = JSON.parse(body)
        "#{parsed_body['errorNum']}: #{parsed_body["errorMessage"]}"
      end
    end
  end
end
