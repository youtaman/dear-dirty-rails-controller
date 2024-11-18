# frozen_string_literal: true

require_relative "base"

module DearDirtyRailsController
  module Parameters
    class Boolean < Base
      VALID_VALUES = [true, false].freeze

      def initialize(name, **options)
        if options[:default] && !VALID_VALUES.include?(options[:default])
          raise ArgumentError,
                "default value must be boolean"
        end

        super
      end

      def parse!(value)
        @parsed_value = case value
                        when "true", "TRUE", true, 1
                          true
                        when "false", "FALSE", false, 0
                          false
                        else
                          default_value
                        end
      end

      def valid?(value)
        parse!(value)
        @error_message = nil

        @error_message = "#{@name} is expected to be boolean" if @parsed_value.nil? && !optional?

        @error_message.nil?
      end

      private

      def default_value
        @options[:default] || nil
      end
    end
  end
end
