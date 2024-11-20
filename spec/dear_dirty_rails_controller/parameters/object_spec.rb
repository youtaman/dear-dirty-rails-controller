# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameters::Object do
  describe "dsl" do
    it "raises ArgumentError if name is not provided in block" do
      expect { described_class.new { numeric      } }.to     raise_error(ArgumentError)
      expect { described_class.new { numeric :id  } }.not_to raise_error
    end
  end

  describe ".new" do
    it "initialize @fields" do
      expect(described_class.new(:name).instance_variable_get(:@fields)).to eq([])
    end

    it "execute block" do
      block = proc { @is_called = true }
      expect(described_class.new(:name, &block).instance_variable_get(:@is_called)).to be_truthy
    end
  end

  describe "#parse" do
    it "returns failure if value is not hash" do
      result = described_class.new(:name) { numeric :id }.parse("invalid")
      expect(result.failure?).to be_truthy
      expect(result.error_messages).to include("name is expected to be object")
    end

    it "returns success with Result has hash value" do
      result = described_class.new(:name) { numeric :id }.parse({ id: 1 })
      expect(result.success?).to be_truthy
      expect(result.value).to be_a(Hash)
      expect(result.value.values.all? { _1.is_a?(DearDirtyRailsController::Parameters::Result) }).to be_truthy
    end

    it "returns value dropped undefined keys" do
      result = described_class.new(:name) { numeric :id }.parse({ id: 1, invalid: 2 })
      expect(result.value.keys).to eq([:id])
    end
  end

  describe "#object?" do
    it "returns true if value is nil" do
      expect(described_class.new(:name).send(:object?, nil)).to be_truthy
    end

    it "returns true if value is hash" do
      expect(described_class.new(:name).send(:object?, {})).to be_truthy
    end

    it "returns false if value is not hash" do
      expect(described_class.new(:name).send(:object?, "invalid")).to be_falsey
    end
  end
end
