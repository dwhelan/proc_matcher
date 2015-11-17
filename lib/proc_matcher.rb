require 'proc_matcher/version'
require 'rspec/matchers'

module ProcHelper

  class ProcSexp
    extend Forwardable

    attr_reader :proc
    attr_accessor :sexp

    def_delegators :@proc, :arity, :lambda?

    def initialize(proc, sexp=proc.to_sexp)
      @proc = proc.dup
      @sexp = sexp
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

    def with_parameters_from(proc)
      sexp = self.sexp
      proc.parameters.each_with_index do |param, index|
        sexp = sexp.gsub Sexp.new(:lvar, parameters[index]), Sexp.new(:lvar, param)
        sexp[2][index + 1] = param
      end
      ProcSexp.new(proc, sexp)
    end

    def to_s
      source = proc.to_source
      proc.lambda? ? source.sub('proc ', '-> ') : source
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

        actual_proc2 = actual_proc.with_parameters_from(expected_proc)

        expected_proc.sexp == actual_proc2.sexp
      end

      def actual_proc
        @acutal_proc ||= ProcHelper::ProcSexp.new(actual)
      end

      def expected_proc
        @expected_proc ||= ProcHelper::ProcSexp.new(expected)
      end

      description do
        %Q(equal "#{expected_proc}")
      end

      def failure_message
        %Q(expected "#{actual_proc}" to equal "#{expected_proc}")
      end

      def failure_message_when_negated
        %Q(expected "#{actual_proc}" not to equal "#{expected_proc}")
      end
    end
  end
end

# TODO: handle procs where source extraction fails
# TODO: handle proc being passed as a block rather than a parameter
# TODO: handle bindings
# TODO: split proc equals logic into its own module
