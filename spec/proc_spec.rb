require 'spec_helper'

describe Proc do
  specify '#match should delegate to ProcSource#==' do
    proc1 = proc {}
    proc2 = proc {}

    source1 = stub_proc_source(proc1)
    source2 = stub_proc_source(proc2)

    result = Object.new
    expect(source1).to receive(:==).with(source2) { result }

    expect(proc1.match proc2).to be result
  end

  specify '#inspect should delegate to ProcSource#inspect' do
    proc = proc {}

    source = stub_proc_source(proc)
    source_contents = Object.new
    expect(source).to receive(:inspect) { source_contents }

    expect((proc).inspect).to be source_contents
  end

  def stub_proc_source(proc)
    double('source').tap do |source|
      expect(ProcSource).to receive(:new).with(proc) { source }
    end
  end
end
