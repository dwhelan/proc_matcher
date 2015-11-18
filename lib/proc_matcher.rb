require 'proc_matcher/version'
require_relative 'proc_source.rb'

require 'rspec/matchers'

module RSpec
  module Matchers
    define(:equal_proc) do
      match { descriptor_for(actual) == descriptor_for(expected) }

      description { "equal #{description_of(expected)}" }

      def description_of(object)
        super(descriptor_for(object).to_s)
      end

      private

      def descriptor_for(proc)
        ProcSource.new(proc)
      end
    end
  end
end

# TODO: split proc equals logic into its own gem
