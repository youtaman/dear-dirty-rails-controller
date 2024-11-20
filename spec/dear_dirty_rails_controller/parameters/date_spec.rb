# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameters::Date do
  describe "#parse" do
    it "returns success with value if value is date" do
      result = described_class.new(:name).parse("2020-01-01")
      expect(result.success?).to be_truthy
      expect(result.value).to eq(DateTime.parse("2020-01-01"))
    end

    it "returns failure if value is not date" do
      result = described_class.new(:name).parse("invalid")
      expect(result.failure?).to be_truthy
      expect(result.error_messages).to include("name is expected to be date")
    end
  end
end
