# frozen_string_literal: true

module SerializerResolver
  extend ActiveSupport::Concern

  private

  def resolve_serializer(resource)
    model_class = extract_model_class(resource)
    return nil unless model_class

    serializer_class_name = "#{model_class.name}Serializer"

    # Try versioned serializer first (e.g., Api::V1::TransactionSerializer)
    versioned_serializer = try_versioned_serializer(serializer_class_name)
    return versioned_serializer if versioned_serializer

    # Fallback to base serializer
    serializer_class_name.safe_constantize
  end

  def extract_model_class(resource)
    case resource
    when ActiveRecord::Relation
      resource.klass
    when Array
      resource.first&.class
    when ActiveRecord::Base
      resource.class
    end
  end

  def try_versioned_serializer(serializer_name)
    version_namespace = extract_version_namespace
    return nil unless version_namespace

    "#{version_namespace}::#{serializer_name}".safe_constantize
  end

  def extract_version_namespace
    # Extract namespace from controller path (e.g., "api/v1/transactions" -> "Api::V1")
    controller_path.split('/').first(2).map(&:camelize).join('::')
  end
end
