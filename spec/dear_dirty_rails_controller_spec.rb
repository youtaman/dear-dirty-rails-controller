# frozen_string_literal: true

RSpec.describe DearDirtyRailsController do
  def to_query(hash)
    hash.map { |k, v| "#{k}=#{v}" }.join("&")
  end

  def build_env(params: {}, query: {})
    {
      "rack.input" => StringIO.new(to_query(params)),
      "QUERY_STRING" => to_query(query),
    }
  end

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
        env = build_env
        instance = klass.new(env)
        expect(klass).to receive(:new).with(env).and_return(instance)
        expect_any_instance_of(klass).to receive(:call)
        klass.call(env)
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
      it "sets @env" do
        env = build_env
        instance = klass.new(env)
        expect(instance.env).to eq env
      end

      it "sets @request" do
        env = build_env
        expect(ActionDispatch::Request).to receive(:new).with(env).and_call_original
        instance = klass.new(env)
        expect(instance.request).to be_a(ActionDispatch::Request)
      end
    end

    describe "#call" do
      it "runs callbacks" do
        instance = klass.new
        expect(instance).to receive(:run_before_callbacks)
        expect(instance).to receive(:run_after_callbacks)
        instance.call
      end

      it "sets serialized result to body" do
        instance = klass.new
        expect(instance).to receive(:serialize).and_return("serialized")
        instance.call
        expect(instance._body).to eq "serialized"
      end

      it "builds rack response" do
        instance = klass.new
        expect(instance).to receive(:build_rack_response)
        instance.call
      end

      it "rescues errors" do
        error = StandardError.new("test")
        klass.send(:before) { raise error }
        instance = klass.new

        expect(instance).to receive(:try_rescue).with(error).and_return("rescued")
        instance.call
      end

      it "does not execute if skip_execution? is true" do
        klass.send(:before) { skip_execution! }
        instance = klass.new

        expect(instance).not_to receive(:execute)
        instance.call
      end
    end
  end
end
