# frozen_string_literal: true

require_relative "base"
require_relative "dsl"

module DearDirtyRailsController
  module Parameters
    class Array < Base
      include DSL

      attr_reader :items

      def initialize(name = nil, **options, &block)
        super(name, **options)
        @items = []
        instance_exec(&block) if block_given?
      end

      def parse!(value)
        @parsed_value = []

        unless value.is_a?(::Array)
          @parsed_value = nil
          return
        end

        value.each do |v|
          parser = items.find { |item| item.valid?(v) } || items.last
          @parsed_value << parser&.duplicate
        end
      end

      def valid?(value)
        parse!(value)

        if @parsed_value.nil? && !optional?
          @error_message = "#{@name} is expected to be array"
        else
          @parsed_value.values.map(&:error_message).every?(&:nil?)
        end
      end

      def value
        @parsed_value&.map(&:value)
      end

      define_dsl do |item|
        @items << item
      end
    end
  end
end
