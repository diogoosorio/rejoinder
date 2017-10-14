module Rejoinder
  class Handler
    attr_reader :response
    attr_reader :handlers

    def initialize(response:, &handler)
      @response = response
      @handlers = { success: nil, error: {} }

      on_success(evaluate: true, &handler) if handler
    end

    def on_success(evaluate: false, &handler)
      unless handler
        raise ArgumentError, 'A block is required to register a success handler'
      end

      if handlers[:success]
        raise ArgumentError, 'A success handler is already registered'
      end

      handlers[:success] = handler

      evaluate ? self.evaluate : self
    end

    def on_error(with_code: nil, &handler)
      unless handler
        raise ArgumentError, 'A block is required to register an error handler'
      end

      if handlers[:error][with_code]
        raise ArgumentError,
              'A handler has been already registered for this error code'

      end

      handlers[:error][with_code] = handler

      self
    end

    def evaluate
      return evaluate_successful_response if response.success?

      evaluate_error_response
    end

    private

    def evaluate_successful_response
      if handlers[:success].nil?
        response.context
      else
        handlers[:success].call(response.context)
      end
    end

    def evaluate_error_response
      error = response.error

      default_handler = handlers[:error].fetch(nil, ->(e) { raise e })

      handler = handlers[:error].fetch(error.code, default_handler)

      handler.call(error)
    end

    alias done evaluate
  end
end
