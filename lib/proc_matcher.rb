require 'proc_matcher/version'
require 'rspec/matchers'

module RSpec
  module Matchers
    define(:equal_proc) do
      match do
        return false if actual.arity   != expected.arity
        return false if actual.lambda? != expected.lambda?

        return true if expected_sexp.sexp_body == actual_sexp.sexp_body
        return false if expected_sexp.count != actual_sexp.count

        p2_params = actual_sexp[2].sexp_body.to_a

        parameters(expected_sexp).each_with_index do |param, index|
          self.actual_sexp[2][index + 1] = param
          self.actual_sexp = actual_sexp.gsub Sexp.new(:lvar, p2_params[index]), Sexp.new(:lvar, param)
        end

        expected_sexp == self.actual_sexp
      end

      description do
        "equal #{description_of(expected)}"
      end

      def description_of(object)
        Support::ObjectFormatter.format(source(object))
      end

      attr_writer :actual_sexp

      def actual_sexp
        @actual_sexp ||= actual.dup.to_sexp
      end

      def expected_sexp
        @expected_sexp ||= expected.to_sexp
      end

      def parameters(sexp)
        sexp[2].sexp_body.to_a
      end

      def source(proc)
        source = proc.to_source
        proc.lambda? ? source.sub('proc ', '-> ') : source
      end
    end
  end
end

# TODO: handle procs where source extraction fails
# TODO: handle proc being passed as a block rather than a parameter
# TODO: handle bindings
# TODO: split proc equals logic into its own module
