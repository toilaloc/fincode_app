# frozen_string_literal: true

module ApiResponse
  extend ActiveSupport::Concern

  included do
    include SerializerResolver
  end

  def render_resource(resource, status: :ok)
    serializer = resolve_serializer(resource)
    render json: resource, serializer: serializer, status: status
  end

  def render_collection(resources, status: :ok)
    serializer = resolve_serializer(resources)
    render json: resources, each_serializer: serializer, status: status
  end

  def render_paginated_collection(resources, meta: {})
    serializer = resolve_serializer(resources)
    resource_key = resources.model_name.plural

    render json: {
      resource_key => resources.map { |r| serializer.new(r).as_json },
      'pagination' => build_pagination_meta(resources).merge(meta)
    }
  end

  def render_created(resource)
    serializer = resolve_serializer(resource)
    render json: serializer.new(resource).as_json, status: :created
  end

  def render_updated(resource)
    serializer = resolve_serializer(resource)
    resource_key = resource.class.model_name.singular
    
    render json: {
      resource_key => serializer.new(resource).as_json
    }, status: :ok
  end

  def render_deleted(model_class)
    model_name = model_class.model_name.human
    render json: {
      message: t('messages.success.deleted', model: model_name)
    }
  end

  def render_success(key)
    render json: { message: t("messages.success.#{key}") }
  end

  private

  def build_pagination_meta(collection)
    return {} unless collection.respond_to?(:current_page)

    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end

  def t(key, **options)
    I18n.t(key, **options)
  end
end
