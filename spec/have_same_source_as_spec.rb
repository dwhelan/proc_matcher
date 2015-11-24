require 'spec_helper'

# rubocop:disable Metrics/LineLength
module RSpec
  describe 'have_same_source_as' do
    let(:proc1) do
      proc {}
    end

    it 'proc with no args should be "have same source a proc { }"' do
      expect(have_same_source_as(proc1).description).to eq 'have same source as "proc { }"'
    end

    it 'should use include parameter names in the description"' do
      expect(have_same_source_as(proc1).ignoring_parameter_names.description).to eq 'have same source as "proc { }" ignoring parameter names'
    end

    it 'the same procs should be equal' do
      expect(proc1).to have_same_source_as proc1
    end

    it 'procs with the same source should be equal' do
      expect(proc1).to have_same_source_as proc {}
    end

    it 'procs with different source should not be equal' do
      expect(proc1).to_not have_same_source_as proc { 42 }
    end

    it 'lambdas should not be equal procs' do
      expect(proc1).to_not have_same_source_as -> {}
    end

    it 'procs with same effective source but different parameters should not be equal' do
      proc1 = proc { |a| a.to_s }

      expect(proc1).to_not have_same_source_as proc { |b| b.to_s }
    end

    it 'procs with same effective source but different parameters should not be equal' do
      proc1 = proc { |a| a.to_s }

      expect(proc1).to have_same_source_as(proc { |b| b.to_s }).ignoring_parameter_names
    end

    it 'should show proc source code in failure message' do
      proc2 = proc { 42 }
      expect { expect(proc1).to have_same_source_as proc2 }.to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected "proc { }" to have same source as "proc { 42 }"')
    end

    it 'should show proc source code in failure message when negated' do
      expect { expect(proc1).to_not have_same_source_as proc1 }.to raise_error(RSpec::Expectations::ExpectationNotMetError, 'expected "proc { }" not to have same source as "proc { }"')
    end
  end
end
