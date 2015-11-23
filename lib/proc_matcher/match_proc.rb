module RSpec
  module Matchers
    define(:match_proc) do
      match { ProcSource.new(actual).match ProcSource.new(expected) }

      description { "match #{description_of(expected)}" }

      def description_of(object)
        super(source_for(object).inspect)
      end

      private

      def source_for(proc)
        ProcSource.new(proc)
      end
    end
  end
end
