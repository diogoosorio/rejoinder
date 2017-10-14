require 'rejoinder/error'
require 'rejoinder/handler'

module Rejoinder
  class Response
    private

    attr_reader :handler

    public

    class << self
      def success(context: nil)
        new(context: context)
      end

      def error(message: nil, code: nil)
        new(
          context: nil,
          error: Error.new(message: message, code: code)
        )
      end
    end

    extend Forwardable

    attr_reader :context
    attr_reader :error

    def initialize(context: nil, error: nil, handler_class: Handler)
      if !context.nil? && !error.nil?
        raise ArgumentError,
              'The context and error arguments are mutually exclusive'
      end

      @context = context
      @error = error
      @handler = handler_class.new(response: self)
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

    delegate %i[on_success on_error evaluate done] => :@handler
  end
end
