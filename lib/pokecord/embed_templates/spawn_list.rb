# frozen_string_literal: true

require 'discordrb'

require_relative '../embed_templates'

module Pokecord
  module EmbedTemplates
    class SpawnList
      def initialize(username, list_payload)
        @username = username
        @list_payload = list_payload
      end

      def to_embed
        embed = Discordrb::Webhooks::Embed.new(
          color: Pokecord::EmbedTemplates::EMBED_COLOR,
          title: "#{username}'s Pokémon",
          description: rows_of_spawns
        )
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
          text: "Displaying page #{list_payload.page_number} of #{list_payload.total_pages}"
        )
        embed
      end

      private

      attr_reader :username, :list_payload

      def rows_of_spawns
        list_payload.
          spawned_pokemons.
          map(&method(:spawn_row)).
          join("\n")
      end

      def spawn_row(spawn)
        pokemon = spawn.pokemon
        nickname_string = spawn.nickname.nil? ? '' : "nickname: #{spawn.nickname},"
        "**#{pokemon.name}** ---> #{nickname_string} Level: #{spawn.level}, Pokedex number: #{pokemon.pokedex_number}, catch number: #{spawn.catch_number}"
      end
    end
  end
end
