# frozen_string_literal: true

require 'discordrb'

require_relative '../embed_templates'

module Pokecord
  module EmbedTemplates
    class Info
      def initialize(username, info_payload)
        @username = username
        @spawned_pokemon = info_payload.spawned_pokemon
        @pokemon = info_payload.pokemon
      end

      def to_embed
        embed = Discordrb::Webhooks::Embed.new(
          color: Pokecord::EmbedTemplates::EMBED_COLOR,
          title: "#{username}'s #{familiar_name}",
          description: "Level #{spawned_pokemon.level} #{pokemon.name}"
        )
        poke_fields.each do |field|
          embed.add_field(field.merge(inline: true))
        end
        embed
      end

      private

      attr_reader :username, :spawned_pokemon, :pokemon

      def familiar_name
        if spawned_pokemon.nickname.nil?
          pokemon.name
        else
          spawned_pokemon.nickname
        end
      end

      def poke_fields
        [
          {
            name: 'Pokedex No.',
            value: pokemon.stylized_pokedex_number
          },
          {
            name: 'HP',
            value: pokemon.base_hp
          },
          {
            name: 'Attack',
            value: pokemon.base_attack
          },
          {
            name: 'Defense',
            value: pokemon.base_defense
          },
          {
            name: 'Sp. Attack',
            value: pokemon.base_sp_attack
          },
          {
            name: 'Sp. Defense',
            value: pokemon.base_sp_defense
          },
          {
            name: 'Speed',
            value: pokemon.base_speed
          },
          {
            name: 'Caught At',
            value: spawned_pokemon.caught_at.strftime('%Y-%m-%d')
          },
        ]
      end
    end
  end
end
