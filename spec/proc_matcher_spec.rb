require 'spec_helper'

# rubocop:disable Metrics/LineLength
module RSpec
  describe ProcMatcher do
    it 'has a version number' do
      expect(ProcMatcher::VERSION).not_to be nil
    end

    describe '===', :focus do
    end

    describe 'description' do
      it 'proc with no args should be "equal proc { }"' do
        expect(equal_proc(proc {}).description).to eq 'equal "proc { }"'
      end

      it 'lamda with no args should be "equal -> { }"' do
        expect(equal_proc(-> {}).description).to eq 'equal "-> { }"'
      end

      it 'proc with arguments "arg" should be "equal proc { |arg| }"' do
        expect(equal_proc(proc { |arg| }).description).to eq 'equal "proc { |arg| }"'
      end

      it 'proc with arguments "arg" and body "arg.to_s" should be "equal proc { |arg| arg.to_s }"' do
        expect(equal_proc(proc { |arg| arg.to_s }).description).to eq 'equal "proc { |arg| arg.to_s }"'
      end

      it 'proc with arguments "arg1, *arg2" should be "equal proc { |arg1, *arg2| }"' do
        expect(equal_proc(proc { |arg1, *arg2| }).description).to eq 'equal "proc { |arg1, *arg2| }"'
      end
    end

    describe 'failure_message' do
      it 'when procs differ' do
        proc1 = proc {}
        proc2 = proc { |arg| }

        expect { expect(proc1).to equal_proc(proc2) }.to raise_error(Expectations::ExpectationNotMetError, 'expected "proc { }" to equal "proc { |arg| }"')
      end

      it 'when expected is a lambda but is a proc' do
        lambda = -> {}
        proc   = proc {}

        expect { expect(lambda).to equal_proc(proc) }.to raise_error(Expectations::ExpectationNotMetError, 'expected "-> { }" to equal "proc { }"')
      end

      it 'when expected is a proc but is a lambda' do
        lambda = -> {}
        proc   = proc {}

        expect { expect(proc).to equal_proc(lambda) } .to raise_error(Expectations::ExpectationNotMetError, 'expected "proc { }" to equal "-> { }"')
      end
    end

    describe 'failure_message_when_negated' do
      it 'when procs differ' do
        proc1 = proc {}
        proc2 = proc {}

        expect { expect(proc1).not_to equal_proc(proc2) }.to raise_error(Expectations::ExpectationNotMetError, 'expected "proc { }" not to equal "proc { }"')
      end
    end
  end
end
