# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CategorySerializer, type: :serializer do
  let(:category) { create(:category) }
  let(:serializer) { described_class.new(category) }

  subject { serializer.serializable_hash }

  it 'includes the expected attributes' do
    expect(subject.keys).to contain_exactly(:id, :name, :category_type)
  end

  it 'serializes the id' do
    expect(subject[:id]).to eq(category.id)
  end

  it 'serializes the name' do
    expect(subject[:name]).to eq(category.name)
  end

  it 'serializes the category_type' do
    expect(subject[:category_type]).to eq(category.category_type)
  end

  context 'with income category' do
    let(:category) { create(:category, :income) }

    it 'serializes the correct category_type' do
      expect(subject[:category_type]).to eq('income')
    end
  end

  context 'with expense category' do
    let(:category) { create(:category, :expense) }

    it 'serializes the correct category_type' do
      expect(subject[:category_type]).to eq('expense')
    end
  end
end