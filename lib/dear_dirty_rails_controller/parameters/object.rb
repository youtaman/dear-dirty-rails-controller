# frozen_string_literal: true

require_relative "base"
require_relative "dsl"

module DearDirtyRailsController
  module Parameters
    class Object < Base
      include DSL

      attr_reader :fields

      def initialize(name = nil, **options, &block)
        super(name, **options)
        @fields = []
        instance_exec(&block) if block_given?
      end

      def parse!(value)
        @parsed_value = {}
        fields.each do |field|
          field.parse!(value[field.name])
          @parsed_value[field.name] = field
        end
      end

      def valid?(value)
        parse!(value)
        @parsed_value.values.map(&:error_message).all?(&:nil?)
      end

      def value
        @parsed_value.transform_values(&:value)
      end

      define_dsl do |field|
        raise ArgumentError, "name is required in object block" unless field.name

        @fields << field
      end
    end
  end
end
