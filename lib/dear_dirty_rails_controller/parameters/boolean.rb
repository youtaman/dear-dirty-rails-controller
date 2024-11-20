# frozen_string_literal: true

require_relative "base"

module DearDirtyRailsController
  module Parameters
    class Boolean < Base
      VALID_OPTIONS = %i[default].freeze
      VALID_DEFAULT_VALUES = [true, false].freeze

      def initialize(name, **options)
        if !options[:default].nil? && !VALID_DEFAULT_VALUES.include?(options[:default])
          raise ArgumentError,
                "default value must be boolean"
        end

        super
      end

      def parse(value)
        parsed_value = case value
                       when "true", "TRUE", true, 1
                         true
                       when "false", "FALSE", false, 0
                         false
                       else
                         @options[:default]
                       end
        success(parsed_value)
      end
    end
  end
end
