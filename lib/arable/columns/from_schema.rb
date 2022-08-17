require_relative "../columns"
require_relative "paths"

module Arable::Columns::FromSchema
  module_function

  def call(table_name)
    return if schema.blank?

    table_definition_match = schema.match(/create_table "#{table_name}".*?\n(.*?)\n *end/m)

    columns =
      table_definition_match[1]
        .lines
        .reject { |line| line.include?("t.index") }
        .map { |line| line.match(/t\.[a-z]* "([a-z_]*)"/)[1] }

    return columns if table_definition_match[0].include?("id: false")

    ["id"] + columns
  end

  private

  def self.schema
    @schema ||= begin
      return unless File.exist?(Arable::Columns::Paths::SCHEMA)

      File.read(Arable::Columns::Paths::SCHEMA)
    end
  end
end
