require 'rails_helper'

RSpec.describe 'Sample test', type: :model do
  it 'should pass' do
    expect(1 + 1).to eq(2)
  end

  it 'should work with Rails environment' do
    expect(Rails.env.test?).to be true
  end
end
