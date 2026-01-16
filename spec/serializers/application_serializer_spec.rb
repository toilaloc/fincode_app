# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationSerializer, type: :serializer do
  it 'is a valid ActiveModel::Serializer' do
    expect(described_class).to be < ActiveModel::Serializer
  end
end