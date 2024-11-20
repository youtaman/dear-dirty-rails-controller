# frozen_string_literal: true

require_relative "base"
require_relative "dsl"

module DearDirtyRailsController
  module Parameters
    class Object < Base
      include DSL

      attr_reader :fields

      define_dsl do |field|
        raise ArgumentError, "name is required in object block" unless field.name

        @fields << field
      end

      def initialize(name = nil, **options, &block)
        super(name, **options)
        @fields = []
        instance_exec(&block) if block_given?
      end

      def parse(value)
        return failure("#{@name} is expected to be object") unless object?(value)

        parsed_value = fields.to_h { |field| [field.name, field.parse(value[field.name])] }
        success(parsed_value)
      end

      private

      def object?(value)
        return true if value.nil?

        value.is_a?(::Hash)
      end
    end
  end
end
