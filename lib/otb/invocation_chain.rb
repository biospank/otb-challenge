module Otb
  class SelfDependencyError < StandardError; end
  class CircularDependencyError < StandardError; end

  class InvocationChain

    def initialize parser
      @jobs_hash = parser.parse()
    end

    # order jobs sequence based on dependencies
    def order
      @jobs_hash.inject([]) do |jobs, pair|
        job, dependency = pair

        raise SelfDependencyError, "Jobs can't depend on themeselves" if job == dependency
        raise CircularDependencyError, "Jobs can't have circular dependencies" if has_circular_dependency_for pair, dependency

        if job_position = jobs.index(job)
          jobs.insert job_position, dependency
        else
          dependency.empty? ? jobs << job : jobs.concat(pair.reverse)
        end

      end.uniq.join
    end

    private

    # recursive method to find circular dependency
    def has_circular_dependency_for pair, current_dependency
      if parent_dependency = @jobs_hash[current_dependency]
        if pair.include? parent_dependency
          return true
        else
          has_circular_dependency_for pair, parent_dependency
        end
      else
        return false
      end
    end

  end
end
