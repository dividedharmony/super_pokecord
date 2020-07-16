# frozen_string_literal: true

require 'rom/struct'

module Entities
  class Pokemon < ROM::Struct
    def stylized_pokedex_number
      pokedex_number.to_s.rjust(3, '0')
    end

    # relative to the root dir
    #
    def relative_image_path
      "./pokemon_info/images/#{stylized_pokedex_number}.png"
    end
  end
end
