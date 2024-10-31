# frozen_string_literal: true

module DearDirtyRailsController
  module ErrorHandler
    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end
  end

  module InstanceMethods
    private

    def try_rescue(error)
      block = self.class._error_handlers&.fetch(error.class, nil)
      block ||= self.class._all_error_handler

      raise error if block.nil?

      instance_exec(error, &block)
    end
  end

  module ClassMethods
    attr_reader :_error_handlers, :_all_error_handler

    private

    def rescue_from(error_class, &block)
      return unless block_given?

      @_error_handlers ||= {}
      @_error_handlers[error_class] = block
    end

    def rescue_all(&block)
      return unless block_given?

      @_all_error_handler = block
    end
  end
end
