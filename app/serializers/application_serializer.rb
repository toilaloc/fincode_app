# frozen_string_literal: true

class ApplicationSerializer < ActiveModel::Serializer
  # Base serializer class for all serializers in the app
  # Add common attributes or methods here if needed

  # Example: Include timestamps if needed
  # attributes :created_at, :updated_at

  # def created_at
  #   object.created_at.iso8601 if object.created_at
  # end

  # def updated_at
  #   object.updated_at.iso8601 if object.updated_at
  # end
end
