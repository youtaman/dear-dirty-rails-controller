# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Hook do
  describe ".before" do
    it "adds a before callback" do
      klass = Class.new do
        include DearDirtyRailsController::Hook
        before do
          @context
        end
      end

      klass.instance_variable_set(:@context, true)

      expect(klass._before_callbacks.size).to eq 1
      expect(klass._before_callbacks.first.call(true)).to eq true
    end
  end

  describe ".after" do
    it "adds an after callback" do
      klass = Class.new do
        include DearDirtyRailsController::Hook
        after do
          @context
        end
      end

      klass.instance_variable_set(:@context, true)

      expect(klass._after_callbacks.size).to eq 1
      expect(klass._after_callbacks.first.call).to eq true
    end
  end

  describe "#run_before_callbacks" do
    it "runs all before callbacks" do
      klass = Class.new do
        include DearDirtyRailsController::Hook
        before do
          @context.message = "before"
        end
      end

      instance = klass.new
      context = Struct.new(:message).new
      instance.instance_variable_set(:@context, context)

      expect(context.message).to be_nil
      instance.send(:run_before_callbacks)
      expect(context.message).to eq "before"
    end
  end

  describe "#run_after_callbacks" do
    it "runs all after callbacks" do
      klass = Class.new do
        include DearDirtyRailsController::Hook
        after do
          @context.message = "after"
        end
      end

      instance = klass.new
      context = Struct.new(:message).new
      instance.instance_variable_set(:@context, context)

      expect(context.message).to be_nil
      instance.send(:run_after_callbacks)
      expect(context.message).to eq "after"
    end
  end

  describe "#skip_execution!" do
    klass = Class.new do
      include DearDirtyRailsController::Hook
    end

    it "sets skip_execution true" do
      instance = klass.new
      expect(instance.send(:skip_execution)).to be_nil
      instance.send(:skip_execution!)
      expect(instance.send(:skip_execution)).to be true
    end
  end

  describe "#skip_execution?" do
    klass = Class.new do
      include DearDirtyRailsController::Hook
    end

    it "returns false by default" do
      instance = klass.new
      expect(instance.send(:skip_execution?)).to be false

      instance.send(:skip_execution!)
      expect(instance.send(:skip_execution?)).to be true
    end
  end
end
