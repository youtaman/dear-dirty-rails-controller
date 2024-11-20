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
      attr_reader :param_parser

      def params(&block)
        @param_parser = Parameters::Object.new(:params, &block)
      end
    end

    module InstanceMethods
      def parse_param(params)
        return if self.class.param_parser.nil?

        self.class.param_parser.parse(params)
      end
    end
  end
end
