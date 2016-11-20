require "spec_helper"

describe BubBot::RackHandler do
  it 'returns 200' do
    result = subject.call(double('env'))
    expect(result[0]).to eq 200
  end
end
