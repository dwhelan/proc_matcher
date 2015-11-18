require 'spec_helper'

describe ProcSource do
  describe 'to_s' do
    it 'should delegate "to_so" to "proc.to_source"' do
      source = ProcSource.new proc {}
      expect(source.to_s).to be source.proc.to_source
    end

    it 'should replace "proc" with "->" for lambdas' do
      source = ProcSource.new -> {}
      expect(source.to_s).to eq source.proc.to_source.sub('proc', '->')
    end
  end

  describe '==' do
    specify 'sames procs should be equal' do
      source = ProcSource.new proc {}

      expect(source).to eq source
    end

    specify 'procs with empty code should be equal' do
      source1 = ProcSource.new proc {}
      source2 = ProcSource.new proc {}

      expect(source1).to eq source2
    end

    specify 'procs with different but equivalent code should not be equal' do
      source1 = ProcSource.new proc {}
      source2 = ProcSource.new proc { nil }

      expect(source1).to_not eq source2
    end

    specify 'with different parameters should be equal' do
      source1 = ProcSource.new proc { |a, b| a.to_s + b.to_s }
      source2 = ProcSource.new proc { |c, d| c.to_s + d.to_s }

      expect(source1).to eq source2
    end

    specify 'should not be equal when one is a lambda and the other is not' do
      source1 = ProcSource.new -> {}
      source2 = ProcSource.new proc {}

      expect(source1).to_not eq source2
    end

    specify 'should not be equal with a different number of parameters' do
      source1 = ProcSource.new proc {}
      source2 = ProcSource.new proc { |a| a.to_s }

      expect(source1).to_not eq source2
    end
  end
end
