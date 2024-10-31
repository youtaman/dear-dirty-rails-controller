# frozen_string_literal: true

module DearDirtyRailsController
  module RackResponse
    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end

    module InstanceMethods
      attr_reader :_headers, :_status, :_body

      private

      def headers(param)
        @_headers = param
      end

      def content_type(param)
        @_headers ||= {}
        @_headers["Content-Type"] = param
      end

      def status(param)
        @_status = param
      end

      def body(param)
        @_body = param
      end

      def build_rack_response
        status = @_status || self.class._status || 200
        headers = (self.class._headers || {}).merge(@_headers || {})
        body = @_body.nil? ? [] : [@_body]
        [status, headers, body.to_json]
      end
    end

    module ClassMethods
      attr_reader :_headers, :_status

      private

      def headers(param)
        @_headers = param
      end

      def content_type(param)
        @_headers ||= {}
        @_headers["Content-Type"] = param
      end

      def status(param)
        @_status = param
      end
    end
  end
end
