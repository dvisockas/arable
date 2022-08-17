require_relative "../columns"

module Arable::Columns::Paths
  SCHEMA = 'db/schema.rb'.freeze
  STRUCTURE = 'db/structure.sql'.freeze

  ALL = [
    SCHEMA,
    STRUCTURE,
  ].freeze
end
