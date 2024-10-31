# frozen_string_literal: true

RSpec.describe DearDirtyRailsController do
  let(:klass) do
    Class.new do
      include DearDirtyRailsController::Mixin
      execute do
        { args: @args }
      end
    end
  end

  describe "Mixin module" do
    describe ".call" do
      it "calls the controller" do
        instance = klass.new(1, 2)
        expect(klass).to receive(:new).with(1, 2).and_return(instance)
        expect_any_instance_of(klass).to receive(:call)
        klass.call(1, 2)
      end
    end

    describe ".execute" do
      it "defines execute method" do
        klass2 = Class.new do
          include DearDirtyRailsController::Mixin
        end
        expect(klass2.new.methods).not_to include :execute

        klass2.send(:execute) { "test" }
        expect(klass2.new.methods).to include :execute
      end
    end

    describe "#initialize" do
      it "sets args" do
        instance = klass.new(1, 2)
        expect(instance.args).to eq [1, 2]
      end
    end

    describe "#call" do
      it "runs callbacks" do
        instance = klass.new(1, 2)
        expect(instance).to receive(:run_before_callbacks)
        expect(instance).to receive(:run_after_callbacks)
        instance.call
      end

      it "sets serialized result to body" do
        instance = klass.new(1, 2)
        expect(instance).to receive(:serialize).and_return("serialized")
        instance.call
        expect(instance._body).to eq "serialized"
      end

      it "builds rack response" do
        instance = klass.new(1, 2)
        expect(instance).to receive(:build_rack_response)
        instance.call
      end

      it "rescues errors" do
        error = StandardError.new("test")
        klass.send(:before) { raise error }
        instance = klass.new(1, 2)

        expect(instance).to receive(:try_rescue).with(error).and_return("rescued")
        instance.call
      end

      it "does not execute if skip_execution? is true" do
        klass.send(:before) { skip_execution! }
        instance = klass.new(1, 2)

        expect(instance).not_to receive(:execute)
        instance.call
      end
    end
  end
end
