# frozen_string_literal: true

require_relative "base"
require "date"

module DearDirtyRailsController
  module Parameters
    class DateTime < Base
      def parse(value)
        success(::DateTime.parse(value))
      rescue
        failure("#{@name} is expected to be date time")
      end
    end
  end
end
