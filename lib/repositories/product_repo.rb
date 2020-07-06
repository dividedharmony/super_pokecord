# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class ProductRepo < ROM::Repository[:products]
    commands :create, update: :by_pk, delete: :by_pk

    def purchasable_products(page_num)
      products.
        where(page_num: page_num, visible: true).
        order(:position, :name)
    end
  end
end
