class Podio::Promotion < ActivePodio::Base
  property :promotion_id, :integer
  property :status, :string
  property :display_type, :string
  property :display_data, :hash
  property :context, :string
  property :contextual, :boolean
  property :priority, :integer
  property :max_views, :integer
  property :max_uses, :integer
  property :max_duration, :integer
  property :sleep, :integer
  property :condition_set_ids, :array

  alias_method :id, :promotion_id

  class << self
    def find_all(options={})
      list Podio.connection.get { |req|
        req.url("/promotion/", options)
      }.body
    end

    def find(promotion_id)
      member Podio.connection.get("/promotion/#{promotion_id}").body
    end

    def create(attributes)
      member Podio.connection.post { |req|
        req.url("/promotion/")
        req.body = attributes
      }.body
    end

    def update(promotion_id, attributes)
      member Podio.connection.put { |req|
        req.url("/promotion/#{promotion_id}")
        req.body = attributes
      }.body
    end

    def enable(promotion_id)
      member Podio.connection.post("/promotion/#{promotion_id}/enable").body
    end

    def disable(promotion_id)
      member Podio.connection.post("/promotion/#{promotion_id}/disable").body
    end

    def delete(promotion_id)
      Podio.connection.delete("/promotion/#{promotion_id}")
    end
  end

end
