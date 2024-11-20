# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Parameters::Result do
  describe ".new" do
    it "sets @parser and @value" do
      instance = described_class.new(:parser, :value)
      expect(instance.instance_variable_get(:@parser)).to eq(:parser)
      expect(instance.instance_variable_get(:@value)).to eq(:value)
    end
  end

  describe "#success?" do
    it "returns true if error_messages is empty" do
      instance = described_class.new(:parser, :value)
      allow(instance).to receive(:error_messages).and_return([])
      expect(instance.success?).to be_truthy
    end

    it "returns false if error_messages is not empty" do
      instance = described_class.new(:parser, :value)
      allow(instance).to receive(:error_messages).and_return(["error"])
      expect(instance.success?).to be_falsey
    end
  end

  describe "#failure?" do
    it "returns toggle of success?" do
      instance = described_class.new(:parser, :value)
      allow(instance).to receive(:success?).and_return(true)
      expect(instance.failure?).to be_falsey

      allow(instance).to receive(:success?).and_return(false)
      expect(instance.failure?).to be_truthy
    end
  end

  describe "#check" do
    it "don't execute received method pass @value if failure?" do
      instance = described_class.new(:parser, :value)
      allow(instance).to receive(:failure?).and_return(true)
      expect { instance.check(expect: -> (_) { raise "not called this proc" }) }.not_to raise_error
    end

    it "execute received method and if success?" do
      instance = described_class.new(:parser, :value)
      allow(instance).to receive(:success?).and_return(true)
      called_method = -> (value) { expect(value).to eq(:value); raise }
      expect { instance.check(expect: called_method) }.to raise_error
    end

    it "sets @error_message and return self if received method return false" do
      instance = described_class.new(:parser, :value)
      allow(instance).to receive(:success?).and_return(true)
      expect(instance.check(expect: -> (_) { false }, error_message: "error")).to eq(instance)
      expect(instance.error_message).to eq("error")
    end
  end

  describe "#error_messages" do
    describe "returns flatten array of error_message" do
      let(:failure1) do
        described_class.new(:parser, :value).tap do |instance|
          instance.instance_variable_set(:@error_message, "failure1")
        end
      end
      let(:failure2) do
        described_class.new(:parser, :value).tap do |instance|
          instance.instance_variable_set(:@error_message, "failure2")
        end
      end
      let(:success) { described_class.new(:parser, :value) }

      it "when @value is array" do
        expect(described_class.new(:parser, [success, failure1, failure2]).error_messages).to eq(["failure1", "failure2"])
      end

      it "when @value is hash" do
        expect(described_class.new(:parser, { a: success, b: failure1, c: failure2 }).error_messages).to eq(["failure1", "failure2"])
      end

      it "when @value is not array or hash" do
        expect(failure1.error_messages).to eq(["failure1"])
      end
    end
  end

  describe "#extract_value" do
    let(:success1) { described_class.new(:parser, :success1) }
    let(:success2) { described_class.new(:parser, :success2) }

    it "returns array of @value when @value is array" do
      expect(described_class.new(:parser, [success1, success2]).extract_value).to eq([:success1, :success2])
    end

    it "returns hash of @value when @value is hash" do
      expect(described_class.new(:parser, { a: success1, b: success2 }).extract_value).to eq({ a: :success1, b: :success2 })
    end

    it "returns @value when @value is not array or hash" do
      expect(described_class.new(:parser, :value).extract_value).to eq(:value)
    end
  end
end
