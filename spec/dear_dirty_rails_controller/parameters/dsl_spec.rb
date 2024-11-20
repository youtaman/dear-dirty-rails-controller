# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameters::DSL do
  describe "::TYPES" do
    it "values exist in DearDirtyRailsController::Parameters module" do
      described_class::TYPES.each_value do |type|
        expect(DearDirtyRailsController::Parameters.const_defined?(type)).to be_truthy
      end
    end

    it "values are classes inherited from DearDirtyRailsController::Parameters::Base" do
      described_class::TYPES.each_value do |type|
        expect(DearDirtyRailsController::Parameters.const_get(type).ancestors).to include(DearDirtyRailsController::Parameters::Base)
      end
    end
  end

  describe ".included" do
    it "defines DSL methods for each type" do
      klass = Class.new
      expect(klass.methods).to_not include(:define_dsl)

      klass.include DearDirtyRailsController::Parameters::DSL
      expect(klass.methods).to include(:define_dsl)
    end
  end

  describe ".define_dsl" do
    it "defines instance methods for each type" do
      klass = Class.new do
        include DearDirtyRailsController::Parameters::DSL
        define_dsl {}
      end

      expect(klass.instance_methods).to include(*described_class::TYPES.keys)
    end

    it "calls block with instance of parameter class" do
      klass = Class.new do
        include DearDirtyRailsController::Parameters::DSL
        define_dsl do |result|
          @result = result
        end
      end

      instance = klass.new
      instance.numeric(:name)
      expect(instance.instance_variable_get(:@result)).to be_a(DearDirtyRailsController::Parameters::Numeric)
    end
  end
end
