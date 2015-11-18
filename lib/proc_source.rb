require 'sourcify'

class ProcSource
  extend Forwardable

  attr_reader :proc

  def initialize(proc)
    @proc = proc
  end

  def sexp
    @sexp ||= proc.to_sexp
  end

  def ==(other)
    return false if other.arity != arity || other.lambda? != lambda? || other.count != count
    return true if other.sexp_body == sexp_body

    other.sexp == sexp_with_parameters_from(other)
  end

  def to_s
    lambda? ? proc.to_source.sub('proc ', '-> ') : proc.to_source
  end

  protected

  def_delegators :proc, :arity, :lambda?
  def_delegators :sexp, :sexp_body, :count

  def parameters
    sexp[2].sexp_body.to_a
  end

  private

  def sexp_with_parameters_from(other_proc)
    new_sexp = sexp
    other_proc.parameters.each_with_index do |to, index|
      from = parameters[index]
      new_sexp = rename_parameter(from, to, new_sexp)
    end
    new_sexp
  end

  def rename_parameter(from, to, sexp)
    new_sexp = replace_parameter_definition(from, to, sexp)
    replace_parameter_references(from, to, new_sexp)
  end

  def replace_parameter_definition(from, to, sexp)
    new_sexp = sexp.clone
    index = parameters.find_index { |parameter| parameter == from }
    new_sexp[2][index + 1] = to
    new_sexp
  end

  def replace_parameter_references(from, to, sexp)
    sexp.gsub(s(:lvar, from), s(:lvar, to))
  end
end

# TODO: handle procs where source extraction fails
# TODO: handle proc being passed as a block rather than a parameter
# TODO: handle bindings and local variable checks
