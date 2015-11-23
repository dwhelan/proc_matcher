require 'spec_helper'

# rubocop:disable Metrics/LineLength
module RSpec
  describe 'match_proc' do
    let(:proc1) do
      proc {}
    end

    it 'proc with no args should be "match proc { }"' do
      expect(match_proc(proc {}).description).to eq 'match "proc { }"'
    end

    it 'should use ProcSource#inspect in the description"' do
      expect(match_proc(proc1).description).to eq 'match "proc { }"'
    end

    it 'the same procs should match' do
      expect(proc1).to match_proc proc1
    end

    it 'procs with the same source should match' do
      expect(proc1).to match_proc proc {}
    end

    it 'procs with different source should not match' do
      expect(proc1).to_not match_proc proc { 42 }
    end

    it 'lambdas should not match procs' do
      expect(proc1).to_not match_proc -> {}
    end

    it 'procs with same effective source but different parameters should match' do
      proc1 = proc { |a| a.to_s }

      expect(proc1).to match_proc proc { |b| b.to_s }
    end

    it 'should show proc source code in failure message' do
      proc2 = proc { 42 }
      expect { expect(proc1).to match_proc proc2 }.to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected "proc { }" to match "proc { 42 }"')
    end

    it 'should show proc source code in failure message when negated' do
      expect { expect(proc1).to_not match_proc proc1 }.to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected "proc { }" not to match "proc { }"')
    end
  end
end
