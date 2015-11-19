require 'sourcify'

class ProcSource
  extend Forwardable

  def initialize(proc = nil, &block)
    if proc
      fail ArgumentError, 'cannot pass both an argument and a block' if block
      fail ArgumentError, 'argument must be a Proc'                  unless proc.is_a?(Proc)
    end

    @proc = proc || block
  end

  def ==(other)
    return true if other.proc == proc
    return false if other.arity != arity || other.lambda? != lambda? || other.count != count
    return true if other.sexp_body == sexp_body

    other.sexp == sexp_with_parameters_from(other)
  end

  def to_raw_source
    lambdify(:to_raw_source)
  end

  def to_source
    lambdify(:to_source)
  end

  alias_method :to_s, :to_source

  protected

  attr_reader :proc

  def_delegators :proc, :arity, :lambda?
  def_delegators :sexp, :sexp_body, :count

  def sexp
    @sexp ||= proc.to_sexp
  end

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

  def lambdify(method)
    source = proc.public_send(method)
    lambda? ? source.sub('proc ', '-> ') : source
  rescue Sourcify::CannotHandleCreatedOnTheFlyProcError
    proc.to_s
  end
end

# TODO: handle symbol proc equality
# TODO: handle eval proc equality?
# TODO: handle bindings and local variable checks
# TODO: handle @variables?
# TODO: handle === , eql? & hash see http://commandercoriander.net/blog/2013/05/27/four-types-of-equality-in-ruby/
# TODO: optionally monkey match Proc?
