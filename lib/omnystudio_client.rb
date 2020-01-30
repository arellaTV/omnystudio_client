require "omnystudio_client/episode_collection"
require "omnystudio_client/episode"
require "omnystudio_client/podcast_collection"
require "omnystudio_client/podcast"

# @author Jay Arella
module OmnyStudioClient
  class ConnectionError < StandardError
  end

  class << self
    attr_accessor :api_base_url, :token

    # @option options [String] :api_base_url The api base url
    # @option options [String] :token The api token taken from OmnyStudio's developer settings (https://api.omnystudio.com/api-docs/index)
    # @return a new instance of OmnyStudioClient
    # @example Initialize OmnyStudioClient into a variable
    #   omnystudio = OmnyStudioClient.new({
    #     token: '910'
    #   })
    #   omnystudio #=> new OmnyStudioClient

    def new options={}
      @api_base_url = options[:api_base_url] || "https://api.omnystudio.com"
      @token = options[:token]

      self
    end

    # @option options [Symbol] :method  Request method
    # @option options [Hash] :params Request params in a hash
    # @option options [String] :payload If the request method is `POST`, the body of the post
    # @option options [String] :url Request url
    # @note This is a generalized REST method that is used by both the Episode and Podcast class.
    #   If it's successful, it returns a struct representing the data. If it fails, it raises a ConnectionError.
    # @example Get a list of podcasts with #connection
    #   omnystudio.connection({
    #     method: :get,
    #     url: "https://cms.omnystudio.fm/api/podcasts"
    #   })
    #   #=> Array of structs representing podcasts

    def connection options={}
      request_headers = default_headers.merge({ params: options[:params] })

      begin
        response = RestClient::Request.execute(
          url: options[:url],
          method: options[:method],
          headers: request_headers,
          payload: options[:body].to_json
        )
      rescue RestClient::ExceptionWithResponse => err
        raise ConnectionError.new("OmnyStudio ConnectionError: #{err.response.description}, Request: #{err.response.request.method} #{err.response.request.url}")
      end

      JSON.parse(response.body, object_class: OpenStruct)
    end

    # @return a hash with the default request headers, includes the token
    # @example Calling #default_headers after initializing with a token
    #   omnystudio = OmnyStudioClient.new({
    #     token: '910'
    #   })
    #   omnystudio.default_headers #=> { content_type: "application/json", authorization: "Token token=910", params: {} }

    def default_headers
      {
        content_type: "application/json",
        authorization: "OmnyToken #{@token}",
        params: {}
      }
    end

    # @return a new instance of OmnyStudioClient::EpisodeCollection
    # @example Make a new Episodes instance
    #   omnystudio.episodes #=> new OmnyStudioClient::EpisodeCollection

    def episodes
      self::EpisodeCollection.new
    end

    # @return a new instance of OmnyStudioClient::Podcast
    # @example Make a new Podcast instance
    #   omnystudio.podcast("12345") #=> new OmnyStudioClient::Podcast with id 12345

    def podcast(id=nil)
      self::Podcast.new(id)
    end

    # @return a new instance of OmnyStudioCilent::PodcastCollection
    # @example Make a new Podcasts instance
    #   omnystudio.podcasts #=> new OmnyStudioClient::PodcastCollection

    def podcasts
      self::PodcastCollection.new
    end
  end
end