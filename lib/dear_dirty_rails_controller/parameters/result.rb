# frozen_string_literal: true

module DearDirtyRailsController
  module Parameters
    class Result
      attr_reader :parser, :value, :error_message

      def initialize(parser, value)
        @parser = parser
        @value = value
      end

      def success?
        error_messages.empty?
      end

      def failure?
        !success?
      end

      def check(expect: nil, error_message: "Check is Failure")
        return self if failure?

        @error_message = error_message unless expect.call(value)
        self
      end

      def error_messages
        case @value
        when ::Array
          @value.map(&:error_messages)
        when Hash
          @value.values.map(&:error_messages)
        else
          [@error_message]
        end.flatten.compact.uniq
      end

      def extract_value
        case @value
        when ::Array
          @value.map(&:value)
        when Hash
          @value.transform_values(&:value)
        else
          @value
        end
      end
    end
  end
end
