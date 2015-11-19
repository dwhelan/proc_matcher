require 'sourcify'

class ProcSource
  extend Forwardable

  attr_reader :proc

  def initialize(proc = nil, &block)
    if proc
      fail ArgumentError, 'cannot pass both an argument and a block' if block
      fail ArgumentError, 'argument must be a Proc'                  unless proc.is_a?(Proc)
    end

    @proc = proc || block
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
      new_sexp = rename_parameter_in(new_sexp, from, to)
    end
    new_sexp
  end

  def rename_parameter_in(sexp, from, to)
    new_sexp = replace_parameter_definition_in(sexp, from, to)
    replace_parameter_references_in(new_sexp, from, to)
  end

  def replace_parameter_definition_in(sexp, from, to)
    sexp.clone.tap do |new_sexp|
      index = parameters.find_index { |parameter| parameter == from }
      new_sexp[2][index + 1] = to
    end
  end

  def replace_parameter_references_in(sexp, from, to)
    sexp.gsub(s(:lvar, from), s(:lvar, to))
  end
end

# TODO: add alias for to_source => to_s
# TODO: add source
# TODO: handle procs where source extraction fails
# TODO: handle bindings and local variable checks
# TODO: handle @variables?
# TODO: handle === , eql? & hash see http://commandercoriander.net/blog/2013/05/27/four-types-of-equality-in-ruby/
# TODO: optionally monkey match Proc?
