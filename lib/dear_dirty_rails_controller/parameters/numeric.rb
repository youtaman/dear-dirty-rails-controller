# frozen_string_literal: true

require_relative "base"

module DearDirtyRailsController
  module Parameters
    class Numeric < Base
      VALID_OPTIONS = %i[float values default].freeze

      def initialize(name = nil, **options)
        super
        return if options[:default].nil?

        if float?
          unless options[:default].is_a?(Float)
            raise ArgumentError,
                  "default option is expected to be Float"
          end
        else
          unless options[:default].is_a?(Integer)
            raise ArgumentError,
                  "default option is expected to be Integer"
          end
        end
      end

      def parse(value)
        parsed_value = parse_to_number!(value)
        parsed_value = @options[:default] if parsed_value.nil?
        success(parsed_value)
          .check(expect: method(:in_values?), error_message: "#{@name} is expected to be in #{@options[:values]}")
      rescue
        failure("#{@name} is expected to be #{float? ? "float" : "integer"}")
      end

      private

      def float?
        @options[:float] || false
      end

      def in_values?(value)
        return true if value.nil?
        return true unless @options[:values]

        @options[:values].include? value
      end

      def parse_to_number!(value)
        return nil if value.nil?
        return Float(value) if float?

        begin
          Integer(value)
        rescue
          Float(value).to_i
        end
      end
    end
  end
end
