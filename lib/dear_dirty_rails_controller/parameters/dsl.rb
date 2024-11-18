# frozen_string_literal: true

module DearDirtyRailsController
  module Parameters
    module DSL
      TYPES = {
        numeric: "Numeric",
        string: "String",
        boolean: "Boolean",
        datetime: "DateTime",
        date: "Date",
        array: "Array",
        object: "Object"
      }.freeze

      def self.included(base)
        base.class_eval do
          def self.define_dsl(&block)
            TYPES.each_key do |type|
              define_method(type) do |name = nil, **options, &child_block|
                klass = DearDirtyRailsController::Parameters.const_get(TYPES[type])
                instance = klass.new(name, **options, &child_block)
                instance_exec(instance, &block)
              end
            end
          end
        end
      end
    end
  end
end
