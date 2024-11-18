# frozen_string_literal: true

module DearDirtyRailsController
  module Parameters
    class Base
      attr_accessor :name, :options, :parsed_value, :error_message

      COMMON_VALID_OPTIONS = %i[optional].freeze
      VALID_OPTIONS = [].freeze

      def initialize(name = nil, **options)
        invalid_options = options.keys - self.class::VALID_OPTIONS - COMMON_VALID_OPTIONS
        raise ArgumentError, "Invalid options: #{invalid_options}" unless invalid_options.empty?

        @name = name&.to_sym
        @options = options
      end

      def parse!(value)
        raise NotImplementedError
      end

      def valid?(value)
        raise NotImplementedError
      end

      def value
        @parsed_value
      end

      def duplicate
        Marshal.load(Marshal.dump(self))
      end

      private

      def optional?
        @options[:optional] || false
      end
    end
  end
end
