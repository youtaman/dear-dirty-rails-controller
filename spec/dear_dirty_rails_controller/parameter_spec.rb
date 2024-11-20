# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameter do
  describe ".params" do
    it "assigns a parameter parser to @param_parser" do
      block = proc {}
      expect(DearDirtyRailsController::Parameters::Object).to receive(:new).with(:params, &block).and_call_original

      klass = Class.new do
        include DearDirtyRailsController::Parameter
        params(&block)
      end

      expect(klass.param_parser).to be_a(DearDirtyRailsController::Parameters::Object)
    end
  end

  describe "#parse_param" do
    it "parses params with the assigned parser" do
      parser = instance_double(DearDirtyRailsController::Parameters::Object)
      expect(parser).to receive(:parse).and_return(:result)

      klass = Class.new do
        include DearDirtyRailsController::Parameter
      end

      instance = klass.new
      klass.instance_variable_set(:@param_parser, parser)

      expect(instance.parse_param(:params)).to eq(:result)
    end

    it "does nothing if @param_parser is nil" do
      klass = Class.new do
        include DearDirtyRailsController::Parameter
      end

      instance = klass.new
      instance.parse_param({})

      expect(instance.instance_variable_get(:@parse_param_result)).to be_nil
    end
  end
end
