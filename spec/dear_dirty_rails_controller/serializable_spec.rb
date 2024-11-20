# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::Serializable do
  let(:klass) do
    Class.new do
      include DearDirtyRailsController::Serializable
    end
  end

  describe ".serializer" do
    it "sets serializer class" do
      klass.send(:serializer, Object)
      expect(klass.send(:_serializer_class)).to eq Object
    end

    it "sets serializer method" do
      klass.send(:serializer, Object, method: :test)
      expect(klass.send(:_serialize_method)).to eq :test
    end

    it "sets default serializer method" do
      klass.send(:serializer, Object)
      expect(klass.send(:_serialize_method)).to eq :call
    end
  end

  describe ".serialize" do
    it "sets serialize block" do
      klass.send(:serialize) { _1 }
      expect(klass.send(:_serialize_block).call(true)).to eq true
    end
  end

  describe "#serialize" do
    Serializer = Class.new do
      def self.call(execute_result); execute_result; end
      def self.add_1(execute_result); execute_result + 1; end
      def self.dummy(_); raise "Should not be called"; end
    end

    it "calls serializer block" do
      klass.send(:serialize) { _1 }
      expect(klass.new.send(:serialize, true)).to eq true
    end

    it "calls serializer class" do
      klass.send(:serializer, Serializer)
      expect(klass.new.send(:serialize, true)).to eq true

      klass.send(:serializer, Serializer, method: :add_1)
      expect(klass.new.send(:serialize, 1)).to eq 2
    end

    it "returns json result if no set serializer" do
      expect(klass.new.send(:serialize, true)).to eq true
    end

    it "prioritizes block over class" do
      klass.send(:serialize) { _1 }
      klass.send(:serializer, Serializer, method: :dummy)
      expect(klass.new.send(:serialize, true)).to eq true
    end
  end
end
