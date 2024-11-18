# frozen_string_literal: true

require_relative "base"

module DearDirtyRailsController
  module Parameters
    class String < Base
      VALID_OPTIONS = %i[regexp values].freeze

      def initialize(name = nil, **options)
        if options[:regexp] && !options[:regexp].is_a?(Regexp)
          raise ArgumentError,
                "regexp option is expected to be Regexp"
        end

        if options[:default] && !options[:default].is_a?(String)
          raise ArgumentError,
                "default option is expected to be String"
        end

        super
      end

      def parse!(value)
        @parsed_value = if value.nil?
                          default_value.nil? ? nil : default_value
                        else
                          value.to_s
                        end
      end

      def valid?(value)
        parse!(value)
        @error_message = nil

        if @parsed_value.nil?
          @error_message = "#{@name} is expected to be not nil" unless optional?
        elsif !match?
          @error_message = "#{@name} is expected to match #{@options[:regexp]}"
        elsif !in_values?
          @error_message = "#{@name} is expected to be in #{@options[:values]}"
        end

        @error_message.nil?
      end

      private

      def match?
        return true unless @options[:regexp]

        @options[:regexp].match? @parsed_value
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
