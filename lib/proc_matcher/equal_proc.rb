module RSpec
  module Matchers
    define(:equal_proc) do
      match { ProcSource.new(actual) == ProcSource.new(expected) }

      description { "equal #{description_of(expected)}" }

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