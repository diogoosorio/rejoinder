module Rejoinder
  class ResponseError < StandardError
    attr_reader :code

    def initialize(message: nil, code: nil)
      super(message)

      @code = code
    end

    def raise!
      raise self
    end
  end
end
