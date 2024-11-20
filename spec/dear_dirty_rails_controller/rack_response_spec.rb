# frozen_string_literal: true

RSpec.describe DearDirtyRailsController::RackResponse do
  let(:klass) do
    Class.new do
      include DearDirtyRailsController::RackResponse
    end
  end

  describe ".headers" do
    it "sets headers" do
      klass.send(:headers, { "X-Test" => "test" })
      expect(klass.send(:_headers)).to eq({ "X-Test" => "test" })
    end
  end

  describe ".content_type" do
    it "sets content type" do
      klass.send(:content_type, "application/json")
      expect(klass.send(:_headers)).to eq({ "Content-Type" => "application/json" })
    end
  end

  describe ".status" do
    it "sets status" do
      klass.send(:status, 201)
      expect(klass.send(:_status)).to eq 201
    end
  end

  describe "#headers" do
    it "sets headers" do
      instance = klass.new
      instance.send(:headers, { "X-Test" => "test" })
      expect(instance.send(:_headers)).to eq({ "X-Test" => "test" })
    end
  end

  describe "#content_type" do
    it "sets content type" do
      instance = klass.new
      instance.send(:content_type, "application/json")
      expect(instance.send(:_headers)).to eq({ "Content-Type" => "application/json" })
    end
  end

  describe "#status" do
    it "sets status" do
      instance = klass.new
      instance.send(:status, 201)
      expect(instance.send(:_status)).to eq 201
    end
  end

  describe "#status" do
    it "sets status" do
      instance = klass.new
      instance.send(:status, 201)
      expect(instance.send(:_status)).to eq 201
    end
  end

  describe "#body" do
    it "sets body" do
      instance = klass.new
      instance.send(:body, "test")
      expect(instance.send(:_body)).to eq "test"
    end
  end

  describe "#build_rack_response" do
    it "builds rack response" do
      instance = klass.new
      instance.send(:status, 201)
      instance.send(:headers, { "X-Test" => "test" })
      instance.send(:content_type, "application/json")
      instance.send(:body, "test")

      status_code, headers, body = instance.send(:build_rack_response)
      expect(status_code).to eq 201
      expect(headers).to eq({ "X-Test" => "test", "Content-Type" => "application/json" })
      expect(body).to eq ["test"].to_json
    end

    it "defaults status to 200" do
      instance = klass.new

      status_code, = instance.send(:build_rack_response)
      expect(status_code).to eq 200
    end

    it "prioritizes instance status over class status" do
      klass.send(:status, 201)
      instance = klass.new
      instance.send(:status, 202)

      status_code, = instance.send(:build_rack_response)
      expect(status_code).to eq 202
    end

    it "defaults headers to empty hash" do
      instance = klass.new

      _, headers = instance.send(:build_rack_response)
      expect(headers).to eq({})
    end

    it "defaults body to empty array" do
      instance = klass.new
      _, _, body = instance.send(:build_rack_response)
      expect(body).to eq [].to_json
    end

    it "merges class headers with instance headers(priority instance headers)" do
      klass.send(:headers, { "X-Test" => "class", "X-Test2" => "class" })
      instance = klass.new
      instance.send(:headers, { "X-Test" => "instance", "X-Test3" => "instance" })

      _, headers = instance.send(:build_rack_response)
      expect(headers).to eq({ "X-Test" => "instance", "X-Test2" => "class", "X-Test3" => "instance" })
    end
  end
end
