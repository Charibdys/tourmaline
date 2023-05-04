module Tourmaline
  class InputMediaPhoto
    include JSON::Serializable
    include Tourmaline::Model

    @type = "photo"

    property media : String | File

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    property? has_spoiler : Bool?

    def initialize(@media, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity, @has_spoiler = nil)
    end
  end
end
