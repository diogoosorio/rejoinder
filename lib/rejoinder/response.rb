require 'rejoinder/response_error'

module Rejoinder
  class Response
    class << self
      def success(context: nil)
        new(context: context)
      end

      def error(message: nil, code: nil)
        new(
          context: nil,
          error: ResponseError.new(message: message, code: code)
        )
      end
    end

    attr_reader :context
    attr_reader :error

    def initialize(context: nil, error: nil)
      if !context.nil? && !error.nil?
        raise ArgumentError,
              'The context and error arguments are mutually exclusive'
      end

      @context = context
      @error = error
    end

    def success?
      error.nil?
    end

    def error?
      !success?
    end

    def error!
      error.raise! if error?
    end
  end
end
