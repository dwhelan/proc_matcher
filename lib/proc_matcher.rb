require 'proc_matcher/version'
require_relative 'proc_source.rb'

require 'rspec/matchers'

module RSpec
  module Matchers
    define(:equal_proc) do
      match { source_for(actual) == source_for(expected) }

      description { "equal #{description_of(expected)}" }

      def description_of(object)
        super(source_for(object).to_s)
      end

      private

      def source_for(proc)
        ProcSource.new(proc)
      end
    end
  end
end

# TODO: support symbol procs
# TODO: support procs returned from an eval
# TODO: split proc equals logic into its own gem
# TODO: clean up README.md
