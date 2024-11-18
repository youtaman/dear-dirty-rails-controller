# frozen_string_literal: true

require_relative "parameters/array"
require_relative "parameters/boolean"
require_relative "parameters/date_time"
require_relative "parameters/date"
require_relative "parameters/numeric"
require_relative "parameters/object"
require_relative "parameters/string"

module DearDirtyRailsController
  module Parameter
    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end

    module ClassMethods
      attr_reader :parameter

      def params(&block)
        @parameter = Parameters::Object.new(:params, &block)
      end
    end

    module InstanceMethods
      attr_reader :parsed_parameter

      def parse_parameter!(params)
        @parsed_parameter = self.class.parameter.duplicate
        @parsed_parameter.parse!(params)
      end
    end
  end

  class A
    include Parameter
    params do
      # datetime :now, optional: true
      array :users, optional: true do
        object :user, optional: true do
          numeric :id, optional: true
          string :name, optional: true
          boolean :is_admin, optional: true
        end
        # numeric :id, optional: true
      end

      # array :ids do
      #   numeric
      # end
      # array :num_or_str do
      #   union :name do # これどう？
      #     numeric optional: true
      #     string optional: true
      #   end
      # end
    end
  end
end
