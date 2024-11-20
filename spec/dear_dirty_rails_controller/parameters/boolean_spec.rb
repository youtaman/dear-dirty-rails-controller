# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameters::Boolean do
  describe ".new" do
    it "check default option class is Boolean?" do
      expect { described_class.new(:name, default: 1      ) }.to     raise_error(ArgumentError)
      expect { described_class.new(:name, default: true   ) }.not_to raise_error
      expect { described_class.new(:name, default: false  ) }.not_to raise_error
      expect { described_class.new(:name                  ) }.not_to raise_error
    end
  end

  describe "#parse" do
    it "returns success with value if value is truthy" do
      def expect_success_with_true(result)
        expect(result.success?).to be_truthy
        expect(result.value).to eq(true)
      end

      expect_success_with_true described_class.new(:name).parse(true)
      expect_success_with_true described_class.new(:name).parse("true")
      expect_success_with_true described_class.new(:name).parse("TRUE")
      expect_success_with_true described_class.new(:name).parse(1)
    end

    it "returns success with value if value is false" do
      def expect_success_with_false(result)
        expect(result.success?).to be_truthy
        expect(result.value).to eq(false)
      end

      expect_success_with_false described_class.new(:name).parse(false)
      expect_success_with_false described_class.new(:name).parse("false")
      expect_success_with_false described_class.new(:name).parse("FALSE")
      expect_success_with_false described_class.new(:name).parse(0)
    end

    it "returns success with default value if value is not boolean" do
      result = described_class.new(:name, default: true).parse("invalid")
      expect(result.success?).to be_truthy
      expect(result.value).to eq(true)
    end
  end
end
