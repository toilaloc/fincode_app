# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UserSerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:serializer) { described_class.new(user) }

  subject { serializer.serializable_hash }

  it 'includes the expected attributes' do
    expect(subject.keys).to contain_exactly(:id, :display_name, :email, :avatar_url)
  end

  it 'serializes the id' do
    expect(subject[:id]).to eq(user.id)
  end

  it 'serializes the display_name' do
    expect(subject[:display_name]).to eq(user.display_name)
  end

  it 'serializes the email' do
    expect(subject[:email]).to eq(user.email)
  end

  it 'does not include sensitive attributes' do
    expect(subject).not_to have_key(:password)
    expect(subject).not_to have_key(:password_digest)
    expect(subject).not_to have_key(:first_name)
    expect(subject).not_to have_key(:last_name)
  end
end