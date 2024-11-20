# frozen_string_literal: true

require_relative "dear_dirty_rails_controller/context"
require_relative "dear_dirty_rails_controller/error_handler"
require_relative "dear_dirty_rails_controller/hook"
require_relative "dear_dirty_rails_controller/parameter"
require_relative "dear_dirty_rails_controller/rack_response"
require_relative "dear_dirty_rails_controller/serializable"
require_relative "dear_dirty_rails_controller/version"

require "action_dispatch"
require "action_controller"

module DearDirtyRailsController
  module Mixin
    attr_reader :context, :env, :request

    def self.included(base)
      base.extend ClassMethods
      base.include DearDirtyRailsController::ErrorHandler
      base.include DearDirtyRailsController::Hook
      base.include DearDirtyRailsController::Parameter
      base.include DearDirtyRailsController::RackResponse
      base.include DearDirtyRailsController::Serializable
    end

    def initialize(env = {})
      @env = env
      @request = ::ActionDispatch::Request.new(env)
    end

    def raw_params
      @raw_params ||= ::ActionController::Parameters.new(request.params)
    end

    def params
      @params ||= parse_param(request.params)&.extract_value || raw_params
    end

    def call
      @context = Context.new
      parse_param(raw_params)
      begin
        run_before_callbacks
        body serialize(execute) unless skip_execution?
        run_after_callbacks
      rescue => e
        try_rescue e
      end
      build_rack_response
    end

    module ClassMethods
      def call(...)
        new(...).call
      end

      def execute(&block)
        define_method(:execute, &block)
      end
    end
  end
end
