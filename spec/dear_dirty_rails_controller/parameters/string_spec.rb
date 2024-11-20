# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameters::String do
  describe ".new" do
    it "check regexp option class is RegExp?" do
      expect { described_class.new(:name, regexp: "invalid") }.to     raise_error(ArgumentError)
      expect { described_class.new(:name, regexp: /valid/  ) }.not_to raise_error
      expect { described_class.new(:name                   ) }.not_to raise_error
    end

    it "check default option class is String?" do
      expect { described_class.new(:name, default: 1      ) }.to     raise_error(ArgumentError)
      expect { described_class.new(:name, default: "valid") }.not_to raise_error
      expect { described_class.new(:name                  ) }.not_to raise_error
    end
  end

  describe "#parse" do
    describe "with no options" do
      it "returns success with value if value is not nil" do
        result = described_class.new(:name).parse("value")
        expect(result.success?).to be_truthy
        expect(result.value).to eq("value")
      end
    end

    describe "with default option" do
      it "returns success with value if value is not nil" do
        result = described_class.new(:name, default: "default").parse("value")
        expect(result.success?).to be_truthy
        expect(result.value).to eq("value")
      end

      it "returns success with default value if value is nil" do
        result = described_class.new(:name, default: "default").parse(nil)
        expect(result.success?).to be_truthy
        expect(result.value).to eq("default")
      end
    end

    describe "with regexp option" do
      it "returns failure if value does not match regexp" do
        result = described_class.new(:name, regexp: /\d+/).parse("value")
        expect(result.failure?).to be_truthy
        expect(result.error_messages).to include("name is expected to match #{/\d+/}")
      end

      it "returns success if value matches regexp" do
        result = described_class.new(:name, regexp: /\d+/).parse("123")
        expect(result.success?).to be_truthy
        expect(result.value).to eq("123")
      end
    end

    describe "with values option" do
      it "returns success if value is in values" do
        result = described_class.new(:name, values: %w[one two]).parse("one")
        expect(result.success?).to be_truthy
        expect(result.value).to eq("one")
      end

      it "returns failure if value is not in values" do
        result = described_class.new(:name, values: %w[one two]).parse("three")
        expect(result.failure?).to be_truthy
        expect(result.error_messages).to include("name is expected to be in #{%w[one two]}")
      end
    end

    it "returns value as string" do
      expect(described_class.new(:name).parse("value"     ).value).to be_a(String)
      expect(described_class.new(:name).parse(123         ).value).to be_a(String)
      expect(described_class.new(:name).parse(DateTime.now).value).to be_a(String)
      expect(described_class.new(:name).parse(true).value ).to be_a(String)
    end

    it "returns regexp failure if value does not match regexp and is not in values" do
      result = described_class.new(:name, regexp: /\d+/, values: %w[one two]).parse("value")
      expect(result.failure?).to be_truthy
      expect(result.error_messages).to include("name is expected to match #{/\d+/}")
    end
  end

  describe "#match?" do
    it "returns true if value is nil" do
      expect(described_class.new(:name).send(:match?, nil)).to be_truthy
    end

    it "returns true if regexp is not set" do
      expect(described_class.new(:name).send(:match?, "value")).to be_truthy
    end

    it "returns true if value matches regexp" do
      expect(described_class.new(:name, regexp: /\d+/).send(:match?, "123")).to be_truthy
    end

    it "returns false if value does not match regexp" do
      expect(described_class.new(:name, regexp: /\d+/).send(:match?, "value")).to be_falsey
    end
  end

  describe "#in_values?" do
    it "returns true if value is nil" do
      expect(described_class.new(:name).send(:in_values?, nil)).to be_truthy
    end

    it "returns true if values is not set" do
      expect(described_class.new(:name).send(:in_values?, "value")).to be_truthy
    end

    it "returns true if value is in values" do
      expect(described_class.new(:name, values: %w[one two]).send(:in_values?, "one")).to be_truthy
    end

    it "returns false if value is not in values" do
      expect(described_class.new(:name, values: %w[one two]).send(:in_values?, "three")).to be_falsey
    end
  end
end
