# frozen_string_literal: true

require_relative "base"

module DearDirtyRailsController
  module Parameters
    class String < Base
      VALID_OPTIONS = %i[regexp values default].freeze

      def initialize(name = nil, **options)
        if options[:regexp] && !options[:regexp].is_a?(Regexp)
          raise ArgumentError,
                "regexp option is expected to be Regexp"
        end

        if options[:default] && !options[:default].is_a?(::String)
          raise ArgumentError,
                "default option is expected to be String"
        end

        super
      end

      def parse(value)
        parsed_value = value.nil? ? @options[:default] : value.to_s
        success(parsed_value)
          .check(expect: method(:match?), error_message: "#{@name} is expected to match #{@options[:regexp]}")
          .check(expect: method(:in_values?), error_message: "#{@name} is expected to be in #{@options[:values]}")
      end

      private

      def match?(value)
        return true if value.nil?
        return true unless @options[:regexp]

        @options[:regexp].match? value
      end

      def in_values?(value)
        return true if value.nil?
        return true unless @options[:values]

        @options[:values].include? value
      end
    end
  end
end
