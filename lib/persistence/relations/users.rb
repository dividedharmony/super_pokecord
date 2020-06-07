# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class Users < ROM::Relation[:sql]
      schema(:users, infer: true) do
        associations do
          has_many :spawned_pokemons
          belongs_to :spawned_pokemon, combine_key: :current_pokemon_id, as: :current_pokemon
        end
      end

      auto_struct(true)

      def listing
        select(:id, :discord_id, :created_at)
      end
    end
  end
end
