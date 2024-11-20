# frozen_string_literal: true

require_relative "base"
require "date"

module DearDirtyRailsController
  module Parameters
    class Date < Base
      def parse(value)
        success(::Date.parse(value))
      rescue
        failure("#{@name} is expected to be date")
      end
    end
  end
end
