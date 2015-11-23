require 'spec_helper'

# rubocop:disable Metrics/LineLength
module RSpec
  describe 'equal_proc' do
    let(:proc1) do
      proc {}
    end

    it 'proc with no args should be "equal proc { }"' do
      expect(equal_proc(proc {}).description).to eq 'equal "proc { }"'
    end

    it 'should use ProcSource#inspect in the description"' do
      expect(equal_proc(proc1).description).to eq 'equal "proc { }"'
    end

    it 'the same procs should be equal' do
      expect(proc1).to equal_proc proc1
    end

    it 'procs with the same source should be equal' do
      expect(proc1).to equal_proc proc {}
    end

    it 'procs with different source should not be equal' do
      expect(proc1).to_not equal_proc proc { 42 }
    end

    it 'lambdas should not be equal procs' do
      expect(proc1).to_not equal_proc -> {}
    end

    it 'procs with same effective source but different parameters should not be equal' do
      proc1 = proc { |a| a.to_s }

      expect(proc1).to_not equal_proc proc { |b| b.to_s }
    end

    it 'should show proc source code in failure message' do
      proc2 = proc { 42 }
      expect { expect(proc1).to equal_proc proc2 }.to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected "proc { }" to equal "proc { 42 }"')
    end

    it 'should show proc source code in failure message when negated' do
      expect { expect(proc1).to_not equal_proc proc1 }.to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected "proc { }" not to equal "proc { }"')
    end
  end
end
