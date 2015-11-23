require 'spec_helper'

require 'core_extensions/proc/inspect'

Proc.include CoreExtensions::Proc::Inspect

describe Proc do
  specify '#inspect should delegate to ProcSource#inspect' do
    proc = proc {}

    source = stub_proc_source(proc)
    source_contents = Object.new
    expect(source).to receive(:inspect) { source_contents }

    expect(proc.inspect).to be source_contents
  end

  def stub_proc_source(proc)
    double('source').tap do |source|
      expect(ProcSource).to receive(:new).with(proc) { source }
    end
  end
end
