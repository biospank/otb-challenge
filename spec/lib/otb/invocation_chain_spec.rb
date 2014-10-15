require_relative '../../../lib/otb/invocation_chain'
require_relative '../../../lib/otb/jobs_parser'

describe Otb::InvocationChain do

  it "respond to #order" do
    chain = Otb::InvocationChain.new(Otb::JobsParser.new(""))
    expect(chain).to respond_to :order
  end

  describe "empty jobs list" do
    it "return an empty string" do
      parser = Otb::JobsParser.new("")
      chain = Otb::InvocationChain.new(parser)
      expect(chain.order).to be_empty
    end
  end

  describe "single job (a => )" do
    it "return a string with content 'a'" do
      parser = Otb::JobsParser.new("a => ")
      chain = Otb::InvocationChain.new(parser)
      expect(chain.order).to eq 'a'
    end
  end

  describe "jobs list without dependencies (a => \nb => \nc => )" do
    it "return a string with content 'abc'" do
      parser = Otb::JobsParser.new("a => \nb => \nc => ")
      chain = Otb::InvocationChain.new(parser)
      expect(chain.order).to eq 'abc'
    end
  end

  describe "jobs list as follow (a => \nb => c\nc => )" do
    it "return a string with content 'acb'" do
      parser = Otb::JobsParser.new("a => \nb => c\nc => ")
      chain = Otb::InvocationChain.new(parser)
      jobs_queue = chain.order
      expect(jobs_queue).to match 'c.*b'
      expect(jobs_queue).to eq 'acb'
    end
  end

  describe "jobs list as follow (a => \nb => c\nc => f\nd => a\ne => b\nf => )" do
    it "return a string with content 'afcbde'" do
      parser = Otb::JobsParser.new("a => \nb => c\nc => f\nd => a\ne => b\nf => ")
      chain = Otb::InvocationChain.new(parser)
      jobs_queue = chain.order
      expect(jobs_queue).to match 'c.*b'
      expect(jobs_queue).to match 'f.*c'
      expect(jobs_queue).to match 'a.*d'
      expect(jobs_queue).to match 'b.*e'
      expect(jobs_queue).to eq 'afcbde'
    end
  end

  describe "jobs list as follow (a => \nb => \nc => c)" do
    it "raise error: Otb::SelfDependencyError" do
      parser = Otb::JobsParser.new("a => \nb => \nc => c")
      chain = Otb::InvocationChain.new(parser)
      expect{chain.order}.to raise_error(Otb::SelfDependencyError)
    end
  end

  describe "jobs list as follow (a => \nb => c\nc => f\nd => a\ne => \nf => b)" do
    it "raise error: Otb::CircularDependencyError" do
      parser = Otb::JobsParser.new("a => \nb => c\nc => f\nd => a\ne => \nf => b")
      chain = Otb::InvocationChain.new(parser)
      expect{chain.order}.to raise_error(Otb::CircularDependencyError)
    end
  end
end
