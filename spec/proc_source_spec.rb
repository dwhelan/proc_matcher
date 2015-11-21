require 'spec_helper'

# rubocop:disable Metrics/LineLength, Style/SymbolProc
describe ProcSource do
  describe 'initialize' do
    it 'should allow a Proc to be an argument' do
      expect { ProcSource.new proc {} }.not_to raise_error
    end

    it 'should allow a block to be passed' do
      expect { ProcSource.new {} }.not_to raise_error
    end

    it 'should throw if argument is not a proc' do
      expect { ProcSource.new Object.new }.to raise_error ArgumentError, 'argument must be a Proc'
    end

    it 'should throw if an argument is provided along with a block' do
      proc = proc {}
      expect { ProcSource.new(proc) {} }.to raise_error ArgumentError, 'cannot pass both an argument and a block'
    end
  end

  shared_examples 'string functions' do |method, other = method|
    context method do
      it "should delegate to 'proc.#{other}'" do
        prc = proc {}
        expect(ProcSource.new(prc).public_send(method)).to eq prc.public_send(other)
      end

      it "should replace 'proc' with '->' for lambdas" do
        prc = -> {}
        expect(ProcSource.new(prc).public_send(method)).to eq prc.public_send(other).sub('proc', '->')
      end

      it "should call 'proc.to_s' for symbol procs" do
        prc = proc(&:to_s)
        expect(ProcSource.new(prc).public_send(method)).to eq prc.to_s
      end

      it "should call 'proc.to_s' for procs when source cannot be extracted" do
        prc = proc { proc {} }
        expect(ProcSource.new(prc).public_send(method)).to eq prc.to_s
      end
    end
  end

  include_examples 'string functions', :to_s, :to_source
  include_examples 'string functions', :to_source
  include_examples 'string functions', :to_raw_source

  describe '==' do
    specify 'sames procs should be equal' do
      source = ProcSource.new {}

      expect(source).to eq source
    end

    specify 'procs with empty code should be equal' do
      source1 = ProcSource.new {}
      source2 = ProcSource.new {}

      expect(source1).to eq source2
    end

    specify 'procs with different but equivalent code should not be equal' do
      source1 = ProcSource.new {}
      source2 = ProcSource.new { nil }

      expect(source1).to_not eq source2
    end

    specify 'with different parameters should be equal' do
      source1 = ProcSource.new { |a, b| a.to_s + b.to_s }
      source2 = ProcSource.new { |c, d| c.to_s + d.to_s }

      expect(source1).to eq source2
    end

    specify 'should not be equal when one is a lambda and the other is not' do
      source1 = ProcSource.new -> {}
      source2 = ProcSource.new {}

      expect(source1).to_not eq source2
    end

    specify 'should not be equal with a different parameter arity' do
      source1 = ProcSource.new {}
      source2 = ProcSource.new { |a| a.to_s }

      expect(source1).to_not eq source2
    end

    describe 'symbol procs' do
      specify 'same symbol procs should be equal' do
        source = ProcSource.new proc(&:to_s)

        expect(source).to eq source
      end

      specify 'lexically same symbol procs should be equal' do
        source1 = ProcSource.new proc(&:to_s)
        source2 = ProcSource.new proc(&:to_s)

        expect(source1).to eq source2
      end

      specify 'lexically same symbol procs should be equal even when declared within different scopes' do
        object1 = Object.new.tap do |object|
          object.define_singleton_method(:prc) { proc(&:to_s) }
        end

        object2 = Object.new.tap do |object|
          object.define_singleton_method(:prc) { proc(&:to_s) }
        end

        source1 = ProcSource.new object1.prc
        source2 = ProcSource.new object2.prc

        expect(source1).to eq source2
      end

      specify 'lexically different symbol procs should not be equal' do
        source1 = ProcSource.new(&:to_s)
        source2 = ProcSource.new(&:inspect)

        expect(source1).to_not eq source2
      end
    end

    describe 'procs where sources cannot be extracted' do
      specify 'should not be equal' do
        # rubocop:disable Style/Semicolon
        #
        # Source cannot be extracted because the sourcify gem detects multiple procs declared on the same line.
        proc1   = proc { 1 }; proc2 = proc { 1 }
        source1 = ProcSource.new proc1
        source2 = ProcSource.new proc2

        expect(source1).to_not eq source2
      end
    end

    specify 'blocks with different bindings should be equal' do
      object1 = Class.new do
        @var = 42

        def meaning
          proc { @var }
        end
      end.new

      object2 = Class.new do
        @var = 41

        def meaning
          proc { @var }
        end
      end.new

      source1 = ProcSource.new object1.meaning
      source2 = ProcSource.new object2.meaning

      expect(source1).to eq source2
    end
  end

  # rubocop:disable Style/CaseEquality
  describe '===' do
    specify 'procs with empty code should be equal' do
      source1 = ProcSource.new {}
      source2 = ProcSource.new {}

      expect(source1 === source2).to be true
    end
  end
end
