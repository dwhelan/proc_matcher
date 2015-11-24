module RSpec
  module Matchers
    define(:have_same_source_as) do
      chain(:ignoring_parameter_names) { self.ignore_parameter_names = true }

      match do
        if ignore_parameter_names
          source_for(actual).match source_for(expected)
        else
          source_for(actual) == source_for(expected)
        end
      end

      description do
        "have same source as #{description_of(expected)}#{ignore_parameter_names ? ' ignoring parameter names' : ''}"
      end

      def description_of(object)
        super(source_for(object).inspect)
      end

      private

      attr_accessor :ignore_parameter_names

      def source_for(proc)
        ProcSource.new(proc)
      end
    end
  end
end
