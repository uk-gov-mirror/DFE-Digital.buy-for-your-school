require "rails_helper"

RSpec.describe "Cache invalidation", type: :request do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_WEBHOOK_API_KEY: "an API key"
    ) do
      example.run
    end
  end

  it "removes any matching entry ID from the cache" do
    RedisCache.redis.set("contentful:entry:6zeSz4F4YtD66gT5SFpnSB", "a dummy value")

    fake_contentful_webook_payload = {
      "entityId": "6zeSz4F4YtD66gT5SFpnSB",
      "spaceId": "rwl7tyzv9sys",
      "parameters": {
        "text": "Entity version: 62"
      }
    }

    headers = {"HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic
      .encode_credentials("api", ENV["CONTENTFUL_WEBHOOK_API_KEY"])}

    post "/api/contentful/entry_updated", {
      params: fake_contentful_webook_payload,
      headers: headers,
      as: :json
    }

    expect(response).to have_http_status(:ok)
    expect(RedisCache.redis.get("contentful:entry:6zeSz4F4YtD66gT5SFpnSB")).to eq(nil)
  end

  context "when no basic auth was provided" do
    it "does not delete anything from the cache and returns 401" do
      RedisCache.redis.set("contentful:entry:6zeSz4F4YtD66gT5SFpnSB", "a dummy value")

      fake_contentful_webook_payload = {
        "entityId": "6zeSz4F4YtD66gT5SFpnSB",
        "spaceId": "rwl7tyzv9sys",
        "parameters": {
          "text": "Entity version: 62"
        }
      }

      # No basic auth
      post "/api/contentful/entry_updated",
        params: fake_contentful_webook_payload,
        as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(RedisCache.redis.get("contentful:entry:6zeSz4F4YtD66gT5SFpnSB"))
        .to eq("a dummy value")
    end
  end
end