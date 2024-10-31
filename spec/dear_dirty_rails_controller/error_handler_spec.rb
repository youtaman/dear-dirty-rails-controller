# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::ErrorHandler do
  let(:klass) do
    Class.new do
      include DearDirtyRailsController::ErrorHandler
    end
  end

  describe ".rescue_from" do
    it "adds an error handler" do
      expect(klass._error_handlers).to be_nil
      klass.send(:rescue_from, StandardError) do |error|
        error.message
      end
      expect(klass._error_handlers.keys).to eq [StandardError]
    end
  end

  describe ".rescue_all" do
    it "register an all error handler" do
      expect(klass._all_error_handler).to be_nil
      klass.send(:rescue_all) do |error|
        error.message
      end
      expect(klass._all_error_handler).not_to be_nil
    end
  end

  describe "#try_rescue" do
    it "raises error if no handler" do
      instance = klass.new
      expect { instance.send(:try_rescue, StandardError.new("test")) }.to raise_error(StandardError)
    end

    it "catch specific error" do
      klass.send(:rescue_from, StandardError) do |error|
        error.message
      end
      instance = klass.new
      expect(instance.send(:try_rescue, StandardError.new("test"))).to eq "test"
    end

    it "executes all handler" do
      error_klass = Class.new(StandardError)

      klass.send(:rescue_from, StandardError) do |error|
        raise "shuld not be called"
      end

      klass.send(:rescue_all) do |error|
        error.message
      end

      instance = klass.new
      expect(instance.send(:try_rescue, error_klass.new("test"))).to eq "test"
    end
  end
end
