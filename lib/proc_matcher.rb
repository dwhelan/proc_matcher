require 'proc_matcher/version'
require 'rspec/matchers'

module ProcHelper

  class ProcSexp
    extend Forwardable

    attr_reader :proc

    def_delegators :@proc, :arity, :lambda?, :to_sexp

    def initialize(proc)
      @proc = proc.dup
    end

    def sexp
      @sexp ||= proc.to_sexp
    end

    def body
      sexp.sexp_body
    end

    def count
      sexp.count
    end

    def parameters
      sexp[2].sexp_body.to_a
    end
  end
end

module RSpec
  module Matchers
    define(:equal_proc) do
      match do
        return false if actual_proc.arity   != expected_proc.arity
        return false if actual_proc.lambda? != expected_proc.lambda?

        return true if expected_proc.body == actual_proc.body
        return false if expected_proc.count != actual_proc.count

        p2_params = actual_proc.parameters

        expected_proc.parameters.each_with_index do |param, index|
          self.actual_sexp[2][index + 1] = param
          self.actual_sexp = actual_sexp.gsub Sexp.new(:lvar, p2_params[index]), Sexp.new(:lvar, param)
        end

        expected_sexp == self.actual_sexp
      end

      def actual_proc
        @acutal_proc ||= ProcHelper::ProcSexp.new(actual)
      end

      def expected_proc
        @expected_proc ||= ProcHelper::ProcSexp.new(expected)
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
