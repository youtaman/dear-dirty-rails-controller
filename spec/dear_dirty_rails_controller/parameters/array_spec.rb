# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameters::Array do
  describe ".new" do
    it "initialize @items" do
      expect(described_class.new(:name).instance_variable_get(:@items)).to eq([])
    end

    it "execute block" do
      block = proc { @is_called = true }
      expect(described_class.new(:name, &block).instance_variable_get(:@is_called)).to be_truthy
    end
  end

  describe "#parse" do
    let(:result_class) { DearDirtyRailsController::Parameters::Result }

    it "returns success with array of Result" do
      result = described_class.new(:name) { numeric }.parse([1, 2, 3])
      expect(result.success?).to be_truthy
      expect(result.value.all? { _1.is_a?(result_class) }).to be_truthy
      expect(result.extract_value).to eq([1, 2, 3])
    end

    it "returns failure if any item is invalid" do
      result = described_class.new(:name) { numeric }.parse([1, "invalid", 3])
      expect(result.failure?).to be_truthy
      expect(result.error_messages).to include("name[1] is not assigned to any type.")
    end

    it "use earlier type in block " do
      extract_value = described_class.new(:name) { numeric; string; }.parse([1, "2", 3]).extract_value
      expect(extract_value).to eq([1, 2, 3])

      extract_value = described_class.new(:name) { string; numeric; }.parse([1, "2", 3]).extract_value
      expect(extract_value).to eq(["1", "2", "3"])

      extract_value = described_class.new(:name) { numeric; string;  }.parse(["1", "string", "3"]).extract_value
      expect(extract_value).to eq([1, "string", 3])
    end

    it "return failure if value is not array" do
      result = described_class.new(:name) { numeric }.parse("invalid")
      expect(result.failure?).to be_truthy
      expect(result.error_messages).to include("name is expected to be array")
    end
  end

  describe "#array?" do
    it "returns true if value is nil" do
      expect(described_class.new(:name).send(:array?, nil)).to be_truthy
    end

    it "returns true if value is array" do
      expect(described_class.new(:name).send(:array?, [])).to be_truthy
    end

    it "returns false if value is not array" do
      expect(described_class.new(:name).send(:array?, "invalid")).to be_falsey
    end
  end
end
