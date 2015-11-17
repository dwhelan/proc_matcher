require 'proc_matcher/version'
require 'rspec/matchers'

module RSpec
  module Matchers
    define(:equal_proc) do |expected|
      match do |actual|
        return false if    expected.arity != actual.arity
        return false if expected .lambda? != actual.lambda?

        s1 = expected.to_sexp
        s2 = actual.dup.to_sexp

        return true if s1.sexp_body == s2.sexp_body
        return false if s1.count != s2.count

        p1_params = s1[2].sexp_body.to_a
        p2_params = s2[2].sexp_body.to_a

        p1_params.each_with_index do |param, index|
          s2[2][index + 1] = param
          s2 = s2.gsub Sexp.new(:lvar, p2_params[index]), Sexp.new(:lvar, param)
        end

        s1 == s2
      end

      description do
        "equal #{description_of(expected)}"
      end

      def description_of(object)
        Support::ObjectFormatter.format(source(object))
      end

      private

      def source(proc)
        source = proc.to_source
        proc.lambda? ? source.sub('proc ', '-> ') : source
      end
    end
  end
end

# TODO: handle procs where source extraction fails
