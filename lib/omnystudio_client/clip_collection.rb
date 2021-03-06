require "ostruct"
require "json"
require "rest-client"

module OmnyStudioClient

  # @author Jay Arella
  class ClipCollection

    # @return a OmnyStudioClient::ClipCollection instance
    # @note This is used to initialize the program id and clip id when creating a new Clip instance
    # @example Initialize a new instance of OmnyStudioClient::ClipCollection
    #   OmnyStudioClient::ClipCollection.new("{program_id}") #=> #<OmnyStudioClient::ClipCollection @id=nil, @program_id="{program_id}">

    def initialize(program_id=nil)
      @program_id = program_id
    end

    # @return a OmnyStudioClient
    # @note This is used as a way to access top level attributes

    def config
      @config ||= OmnyStudioClient
    end

    # @return an array of structs that represent a list of clips for a given program
    # @note If a @program_id is not given, it raises an error
    # @see OmnyStudioClient#connection
    # @example List a program's clips
    #   omnystudio.program("12345").clips.list
    #   #=> An array of structs representing a list of clips for a given program

    def list options={}
      if !@program_id
        raise ArgumentError.new("The @program_id variable is required.")
      end

      OmnyStudioClient.connection({
        :url => "#{config.api_base_url}/programs/#{@program_id}/clips",
        :method => :get
      })
    end
  end
end