require_relative '../../../lib/otb/jobs_parser'

describe Otb::JobsParser do
  it "respond to #parse" do
    parser = Otb::JobsParser.new ""
    expect(parser).to respond_to :parse
  end

  describe "#parse" do
    context "with an empty jobs list" do
      it "#parse return an empty hash" do
        jobs = Otb::JobsParser.new("").parse
        expect(jobs).to be_empty
      end
    end

    context "jobs list with no dependencies" do
      before :each do
        @jobs = Otb::JobsParser.new("a => \nb => \nc => ").parse
      end

      it "return a hash with the same number of jobs" do
        expect(@jobs.size).to eq 3
      end

      it "return a hash with job as key and an empty string as value" do
        expect(@jobs).to eq({'a' => '', 'b' => '', 'c' => ''})
      end
    end

    context "jobs list with dependencies" do
      before :each do
        @jobs = Otb::JobsParser.new("a => b\nb => c\nc => d").parse
      end

      it "return a hash with the same number of jobs" do
        expect(@jobs.size).to eq 3
      end

      it "return a hash with job as key and dependency as value" do
        expect(@jobs).to eq({'a' => 'b', 'b' => 'c', 'c' => 'd'})
      end
    end

    context "jobs list with mixed content" do
      before :each do
        @jobs = Otb::JobsParser.new("a => \nb => c\nc => d").parse
      end

      it "return a hash with the same number of jobs" do
        expect(@jobs.size).to eq 3
      end

      it "return a hash with job as key and dependency as value (if exist) otherwise an empty string" do
        expect(@jobs).to eq({'a' => '', 'b' => 'c', 'c' => 'd'})
      end
    end
  end

end
