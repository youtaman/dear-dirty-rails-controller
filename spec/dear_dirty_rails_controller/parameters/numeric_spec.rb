# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameters::Numeric do
  describe ".new" do
    it "check default option class" do
      expect { described_class.new(:name, float: true, default: 1   ) }.to     raise_error(ArgumentError)
      expect { described_class.new(:name, float: true, default: 1.0 ) }.not_to raise_error
      expect { described_class.new(:name, float: true               ) }.not_to raise_error

      expect { described_class.new(:name, float: false, default: 1.0) }.to     raise_error(ArgumentError)
      expect { described_class.new(:name, float: false, default: 1  ) }.not_to raise_error
      expect { described_class.new(:name, float: false              ) }.not_to raise_error
    end
  end

  describe "#parse" do
    it "returns failure if value cannot cast to numeric" do
      result = described_class.new(:name).parse("invalid")
      expect(result.failure?).to be_truthy
      expect(result.error_messages).to include("name is expected to be integer")
    end

    describe "with no option" do
      it "returns success with value if value is not nil" do
        result = described_class.new(:name).parse("1")
        expect(result.success?).to be_truthy
        expect(result.value).to eq(1)
      end
    end

    describe "with default option" do
      it "returns success with value if value is not nil" do
        result = described_class.new(:name, default: 1).parse("2")
        expect(result.success?).to be_truthy
        expect(result.value).to eq(2)
      end

      it "returns success with default value if value is nil" do
        result = described_class.new(:name, default: 1).parse(nil)
        expect(result.success?).to be_truthy
        expect(result.value).to eq(1)
      end
    end

    describe "with values option" do
      it "returns success if value is in values" do
        result = described_class.new(:name, values: [1, 2]).parse("2")
        expect(result.success?).to be_truthy
        expect(result.value).to eq(2)
      end

      it "returns failure if value is not in values" do
        result = described_class.new(:name, values: [1, 2]).parse("3")
        expect(result.failure?).to be_truthy
        expect(result.error_messages).to include("name is expected to be in [1, 2]")
      end
    end
  end

  describe "#float?" do
    it "returns true if float option is true" do
      expect(described_class.new(:name, float: true).send(:float?)).to be_truthy
    end

    it "returns false if float option is false" do
      expect(described_class.new(:name, float: false).send(:float?)).to be_falsey
    end

    it "returns false if float option is not given" do
      expect(described_class.new(:name).send(:float?)).to be_falsey
    end
  end

  describe "#in_values?" do
    it "returns true if value is nil" do
      expect(described_class.new(:name).send(:in_values?, nil)).to be_truthy
    end

    it "returns true if values option is not set" do
      expect(described_class.new(:name).send(:in_values?, 1)).to be_truthy
    end

    it "returns true if value is in values" do
      expect(described_class.new(:name, values: [1, 2]).send(:in_values?, 1)).to be_truthy
    end

    it "returns false if value is not in values" do
      expect(described_class.new(:name, values: [1, 2]).send(:in_values?, 3)).to be_falsey
    end
  end

  describe "#parse_to_number!" do
    it "returns nil if value is nil" do
      expect(described_class.new(:name).send(:parse_to_number!, nil)).to be_nil
    end

    it "returns float if float?" do
      result = described_class.new(:name, float: true).send(:parse_to_number!, "1.0")
      expect(result).to eq(1.0)
      expect(result).to be_a(Float)
    end

    it "returns integer unless float?" do
      result = described_class.new(:name, float: false).send(:parse_to_number!, "1.0")
      expect(result).to eq(1)
      expect(result).to be_a(Integer)
    end

    it "raises error if value cannot cast to numeric" do
      expect { described_class.new(:name             ).send(:parse_to_number!, "invalid") }.to raise_error(ArgumentError)
      expect { described_class.new(:name, float: true).send(:parse_to_number!, "invalid") }.to raise_error(ArgumentError)
    end
  end
end