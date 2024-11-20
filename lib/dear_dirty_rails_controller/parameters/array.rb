# frozen_string_literal: true

require_relative "base"
require_relative "dsl"

module DearDirtyRailsController
  module Parameters
    class Array < Base
      include DSL

      attr_reader :items

      define_dsl do |item|
        @items << item
      end

      def initialize(name = nil, **options, &block)
        super(name, **options)
        @items = []
        instance_exec(&block) if block_given?
      end

      def parse(value)
        return failure("#{@name} is expected to be array") unless array?(value)

        parsed_value = value&.map&.with_index do |v, i|
          result = nil
          items.each do |item|
            output = item.parse(v)
            if output.success?
              result = output
              break
            end
          end
          result || failure("#{@name}[#{i}] is not assigned to any type.")
        end

        success(parsed_value)
      end

      private

      def array?(value)
        return true if value.nil?

        value.is_a?(::Array)
      end
    end
  end
end
