# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameters::Base do
  describe ".new" do
    it "check options has invalid key" do
      expect { described_class.new(:name, invalid: true) }.to raise_error(ArgumentError)
      klass = Class.new(described_class) do
        VALID_OPTIONS = %i[valid]
      end

      expect { klass.new(:name, invalid: true) }.to raise_error(ArgumentError)
    end
  end

  describe "#parse" do
    it "raise NotImplementedError" do
      expect { described_class.new.parse("value") }.to raise_error(NotImplementedError)
    end
  end

  describe "#optional?" do
    it "returns false if optional option is not set" do
      expect(described_class.new.send(:optional?)).to be_falsey
    end

    it "returns true if optional option is set" do
      expect(described_class.new(:name, optional: true).send(:optional?)).to be_truthy
    end
  end

  describe "#not_nil?" do
    it "returns satisfied value" do
      expect(described_class.new(:name                ).send(:not_nil?, nil    )).to be_falsey
      expect(described_class.new(:name                ).send(:not_nil?, "value")).to be_truthy
      expect(described_class.new(:name, optional: true).send(:not_nil?, nil    )).to be_truthy
      expect(described_class.new(:name, optional: true).send(:not_nil?, "value")).to be_truthy
    end
  end

  describe "#success" do
    it "returns success result" do
      result = described_class.new(:name).send(:success, "value")
      expect(result.success?).to be_truthy
      expect(result.value).to eq("value")
    end

    it "returns failure if not_nil? is false" do
      result = described_class.new(:name).send(:success, nil)
      expect(result.failure?).to be_truthy
      expect(result.error_messages).to include("name is expected to be not nil")
    end
  end

  describe "#failure" do
    it "returns failure result" do
      result = described_class.new(:name).send(:failure, "error")
      expect(result.failure?).to be_truthy
      expect(result.error_messages).to include("error")
    end
  end
end
