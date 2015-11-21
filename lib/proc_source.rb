require 'sourcify'

class Proc
  def match(other)
    ProcSource.new(other) == ProcSource.new(self)
  end

  def inspect
    ProcSource.new(self).inspect
  end
end

RSpec::Matchers::BuiltIn::Match.class_eval do
  def description
    "match #{description_of(expected)}"
  end

  def description_of(object)
    super(ProcSource.new(object).to_s)
  end

end

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
    case
    when other.proc == proc
      true
    when other.arity != arity || other.lambda? != lambda?
      false
    else
      source_equal(other)
    end
  end

  def to_raw_source
    source(:to_raw_source)
  end

  def to_source
    source(:to_source)
  end

  alias_method :to_s, :to_source
  alias_method :inspect, :to_source

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

  def source_equal(other)
    case
    when other.count != count
      false
    when other.sexp_body == sexp_body
      true
    else
      other.sexp == sexp_with_parameters_from(other)
    end
  rescue Sourcify::CannotHandleCreatedOnTheFlyProcError, Sourcify::MultipleMatchingProcsPerLineError
    false
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

  def source(method)
    proc_source = proc.public_send(method)
    lambda? ? proc_source.sub('proc ', '-> ') : proc_source
  rescue Sourcify::CannotHandleCreatedOnTheFlyProcError, Sourcify::MultipleMatchingProcsPerLineError
    proc.to_s
  end
end

# TODO: Monkey path Proc =~
# TODO: Monkey path Proc match()
# TODO: print (lamba) instead of ->
# TODO: handle eql? & hash see http://commandercoriander.net/blog/2013/05/27/four-types-of-equality-in-ruby/
