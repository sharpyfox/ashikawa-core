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
        when ResourceNotFoundError then resource_not_found_for(@env)
        when ClientErrorStatuses then client_error_status_for(@env[:body])
        when ServerErrorStatuses then server_error_status_for(@env[:body])
        end
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
      def client_error_status_for(body)
        raise Ashikawa::Core::ClientError, error(body)
      end

      # Raise a Server Error for a given body
      #
      # @raise [ServerError]
      # @return nil
      # @api private
      def server_error_status_for(body)
        raise Ashikawa::Core::ServerError, error(body)
      end

      # Raise the fitting ResourceNotFoundException
      #
      # @raise [DocumentNotFoundException, CollectionNotFoundException, IndexNotFoundException]
      # @return nil
      # @api private
      def resource_not_found_for(env)
        raise case env[:url].path
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
