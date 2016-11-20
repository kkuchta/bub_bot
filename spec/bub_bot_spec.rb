require "spec_helper"

describe BubBot do
  let(:env) { double('env') }
  it "has a version number" do
    expect(BubBot::VERSION).not_to be nil
  end

  it "proxies call to rack handler" do
    expect_any_instance_of(BubBot::RackHandler).to receive(:call).with(env)

    subject.call(env)
  end
end
