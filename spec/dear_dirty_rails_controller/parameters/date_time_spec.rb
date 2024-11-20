# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameters::DateTime do
  describe "#parse" do
    it "returns success with value if value is date time" do
      result = described_class.new(:name).parse("2020-01-01T00:00:00Z")
      expect(result.success?).to be_truthy
      expect(result.value).to eq(DateTime.parse("2020-01-01T00:00:00Z"))
    end

    it "returns failure if value is not date time" do
      result = described_class.new(:name).parse("invalid")
      expect(result.failure?).to be_truthy
      expect(result.error_messages).to include("name is expected to be date time")
    end
  end
end
