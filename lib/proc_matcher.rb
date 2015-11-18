require 'proc_matcher/version'
require 'rspec/matchers'

class ProcDescriptor
  extend Forwardable

  attr_reader :proc
  attr_accessor :sexp

  def_delegators :@proc, :arity, :lambda?, :to_source

  def initialize(proc, sexp = proc.to_sexp)
    @proc = proc
    @sexp = sexp
  end

  def to_s
    lambda? ? to_source.sub('proc ', '-> ') : to_source
  end

  def ==(other)
    return false if other.arity != arity || other.lambda? != lambda? || other.count != count
    return true  if other.body == body

    other.sexp == with_parameters_from(other).sexp
  end

  protected

  def body
    sexp.sexp_body
  end

  def count
    sexp.count
  end

  def parameters
    sexp[2].sexp_body.to_a
  end

  def with_parameters_from(other_proc)
    sexp = self.sexp
    other_proc.parameters.each_with_index do |param, index|
      sexp = rename_parameter(parameters[index], param, sexp)
    end
    ProcDescriptor.new(proc, sexp)
  end

  def rename_parameter(from, to, sexp)
    sexp = sexp.gsub Sexp.new(:lvar, from), Sexp.new(:lvar, to)
    index = parameters.find_index { |parameter| parameter == from }
    sexp[2][index + 1] = to
    sexp
  end
end

module RSpec
  module Matchers
    define(:equal_proc) do
      match do
        expected_descriptor == actual_descriptor
      end

      description do
        %(equal "#{expected_descriptor}")
      end

      def failure_message
        %(expected "#{actual_descriptor}" to equal "#{expected_descriptor}")
      end

      def failure_message_when_negated
        %(expected "#{actual_descriptor}" not to equal "#{expected_descriptor}")
      end

      private

      def actual_descriptor
        @actual_descriptor ||= ProcDescriptor.new(actual)
      end

      def expected_descriptor
        @expected_descriptor ||= ProcDescriptor.new(expected)
      end
    end
  end
end

# TODO: split proc equals logic into its own module
# TODO: handle procs where source extraction fails
# TODO: handle proc being passed as a block rather than a parameter
# TODO: handle bindings
