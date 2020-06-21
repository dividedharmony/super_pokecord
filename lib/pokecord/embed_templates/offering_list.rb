# frozen_string_literal: true

module Pokecord
  module EmbedTemplates
    class OfferingList
      def initialize(user_id, trade_id)
        @user_id = user_id
        @trade_id = trade_id
        @spawn_repo = Repositories::SpawnedPokemonRepo.new(
          Db::Connection.registered_container
        )
      end

      def to_s
        "```#{list_array.join("\n")}```"
      end

      private

      attr_reader :user_id, :trade_id, :spawn_repo

      def spawns
        spawn_repo.
          spawned_pokemons.
          combine(:pokemon).
          where(user_id: user_id, trade_id: trade_id).
          to_a
      end

      def list_array
        spawns.map do |spawn|
          "Level #{spawn.level} #{spawn.pokemon.name}"
        end
      end
    end
  end
end
