# -*- encoding : utf-8 -*-
module Ashikawa
  module Core
    # This Exception is thrown when a Query object should execute a simple query
    # but no collection was provided upon creation
    class NoCollectionProvidedException < RuntimeError
      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        "A simple query can't be executed by a Query object without a collection"
      end
    end
  end
end
