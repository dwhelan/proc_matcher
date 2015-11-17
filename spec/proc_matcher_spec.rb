require 'spec_helper'
require 'sourcify'

# rubocop:disable Lint/UnusedBlockArgument
describe ProcMatcher do
  it 'has a version number' do
    expect(ProcMatcher::VERSION).not_to be nil
  end

  context 'no parameters' do
    specify 'with empty code should be equal' do
      p1 = proc {}
      p2 = proc {}

      expect(p1).to equal_proc(p2)
    end

    specify 'with different code should not be equal' do
      p1 = proc {}
      p2 = proc { '' }

      expect(p1).to_not equal_proc(p2)
    end

    specify 'with different code should not be equal' do
      p1 = proc {}
      p2 = proc { '' }

      expect(p1).to_not equal_proc(p2)
    end

    specify 'with different but equivalent code should not be equal' do
      p1 = proc { nil }
      p2 = proc {}

      expect(p1).to_not equal_proc(p2)
    end
  end

  context 'single parameter' do
    specify 'with empty code should be equal' do
      p1 = proc { |a| }
      p2 = proc { |a| }

      expect(p1).to equal_proc(p2)
    end

    specify 'with different names should not be equal' do
      p1 = proc { |a| }
      p2 = proc { |b| }

      expect(p1).to equal_proc(p2)
    end

    specify 'with different parameters but same usage should be equal' do
      p1 = proc { |a| a.to_s }
      p2 = proc { |b| b.to_s }

      expect(p1).to equal_proc(p2)
    end

    specify 'with different code should not be equal' do
      p1 = proc { |a| }
      p2 = proc { |a| '' }

      expect(p1).to_not equal_proc(p2)
    end
  end

  context 'multiple parameters' do
    specify 'with same parameters with empty code' do
      p1 = proc { |a, b| }
      p2 = proc { |a, b| }

      expect(p1).to equal_proc(p2)
    end

    specify 'different parameters with empty code' do
      p1 = proc { |a, b| }
      p2 = proc { |c, d| }

      expect(p1).to equal_proc(p2)
    end

    specify 'with different parameters but same usage' do
      p1 = proc { |a, b| a.to_s + b.to_s }
      p2 = proc { |c, d| c.to_s + d.to_s }

      expect(p1).to equal_proc(p2)
    end
  end

  specify 'when one is a lambda and the other is not' do
    p1 = -> {}
    p2 = proc {}

    expect(p1).to_not equal_proc(p2)
  end

  specify 'with different number of parameters should not be equal' do
    p1 = proc {}
    p2 = proc { |a| }

    expect(p1).to_not equal_proc(p2)
  end

  specify 'description' do
    match = equal_proc proc { |b| }
    match.matches? proc { |a| }
    expect(match.description).to eq 'proc { |a| } should equal proc { |b| }'
  end

  specify 'negated description' do
    match = equal_proc proc { |b| }
    match.matches? proc { |a| }
    expect(match.description).to eq 'proc { |a| } should equal proc { |b| }'
  end
end
