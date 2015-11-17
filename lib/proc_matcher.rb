require 'proc_matcher/version'
require 'rspec/matchers'

module RSpec
  module Matchers
    define(:equal_proc) do
      match do
        return false if actual.arity   != expected.arity
        return false if actual.lambda? != expected.lambda?

        actual_sexp = actual.dup.to_sexp

        return true if expected_sexp.sexp_body == actual_sexp.sexp_body
        return false if expected_sexp.count != actual_sexp.count

        p1_params = expected_sexp[2].sexp_body.to_a
        p2_params = actual_sexp[2].sexp_body.to_a

        p1_params.each_with_index do |param, index|
          actual_sexp[2][index + 1] = param
          actual_sexp = actual_sexp.gsub Sexp.new(:lvar, p2_params[index]), Sexp.new(:lvar, param)
        end

        expected_sexp == actual_sexp
      end

      description do
        "equal #{description_of(expected)}"
      end

      def description_of(object)
        Support::ObjectFormatter.format(source(object))
      end

      private

      def expected_sexp
        @expected_sexp ||= expected.to_sexp
      end


      def source(proc)
        source = proc.to_source
        proc.lambda? ? source.sub('proc ', '-> ') : source
      end
    end
  end
end

# TODO: handle procs where source extraction fails
# TODO: handle bindings
