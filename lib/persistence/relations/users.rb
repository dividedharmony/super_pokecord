# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class Users < ROM::Relation[:sql]
      schema(:users, infer: true) do
        associations do
          has_many :fight_events
          has_many :spawned_pokemons
          belongs_to :spawned_pokemon, combine_key: :current_pokemon_id, as: :current_pokemon
          has_many :trades, foreign_key: :user_1_id, as: :initiated_trades
          has_many :trades, foreign_key: :user_2_id, as: :reciprocated_trades
        end
      end

      auto_struct(true)

      def listing
        select(:id, :discord_id, :created_at)
      end
    end
  end
end
