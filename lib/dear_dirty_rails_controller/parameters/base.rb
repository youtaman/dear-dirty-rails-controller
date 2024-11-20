# frozen_string_literal: true

require_relative "result"

module DearDirtyRailsController
  module Parameters
    class Base
      attr_accessor :name, :options

      COMMON_VALID_OPTIONS = %i[optional].freeze
      VALID_OPTIONS = [].freeze

      def initialize(name = nil, **options)
        invalid_options = options.keys - self.class::VALID_OPTIONS - COMMON_VALID_OPTIONS
        raise ArgumentError, "Invalid options: #{invalid_options}" unless invalid_options.empty?

        @name = name&.to_sym
        @options = options
      end

      def parse(value)
        raise NotImplementedError
      end

      private

      def optional?
        @options[:optional] || false
      end

      def not_nil?(value)
        return true unless value.nil?
        return true if optional?

        false
      end

      def success(value)
        Result.new(self, value).check(expect: method(:not_nil?), error_message: "#{@name} is expected to be not nil")
      end

      def failure(error_message)
        Result.new(self, nil).check(expect: ->(_) { false }, error_message: error_message)
      end
    end
  end
end
