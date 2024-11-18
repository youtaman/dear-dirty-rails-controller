# frozen_string_literal: true

require_relative "base"

module DearDirtyRailsController
  module Parameters
    class Numeric < Base
      VALID_OPTIONS = %i[float values].freeze

      def initialize(name = nil, **options)
        unless options[:default].nil?
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

        super
      end

      def parse!(value)
        result = if float?
                   Float(value, exception: false)
                 else
                   Integer(value, exception: false)
                 end
        @parsed_value = result.nil? ? default_value : result
      end

      def valid?(value)
        parse!(value)
        @error_message = nil

        if @parsed_value.nil?
          @error_message = "#{@name} is expected to be not nil" unless optional?
        elsif !in_values?
          @error_message = "#{@name} is expected to be in #{@options[:values]}"
        end

        @error_message.nil?
      end

      private

      def float?
        @options[:float] || false
      end

      def in_values?
        return true unless @options[:values]

        @options[:values].include? @parsed_value
      end

      def default_value
        @options[:default] || nil
      end
    end
  end
end
