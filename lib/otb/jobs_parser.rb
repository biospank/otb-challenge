module Otb
  class JobsParser

    def initialize jobs
      @jobs = jobs
    end

    def parse
      @jobs.scan(/(\w) => (\w|)/).inject({}) do |jobs_hash, pair|
        jobs_hash[pair.first] = pair.last
        jobs_hash
      end
    end

  end
end
