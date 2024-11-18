# frozen_string_literal: true

require_relative "base"
require "date"

module DearDirtyRailsController
  module Parameters
    class Date < Base
      def parse!(value)
        @parsed_value = begin
          Date.parse(value)
        rescue
          nil
        end
      end

      def valid?(value)
        parse!(value)
        @error_message = nil

        return true unless @parsed_value.nil?

        @error_message = "#{@name} is expected to be not nil" unless optional?

        @error_message.nil?
      end
    end
  end
end
