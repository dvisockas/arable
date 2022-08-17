require_relative "paths"

module Arable::Columns::FromStructure
  module_function

  def call(table_name)
    return if structure.blank?

    table_definition_match = structure.match(/CREATE TABLE\s\w+\.#{table_name}.*?\n(.*?)\n *\);/m)

    table_definition_match[1]
      .lines
      .map(&:strip)
      .map { |line| line.match(/(\w*)\s/)[1] }
  end

  private

  def structure
    @structure ||= begin
      return unless File.exist?(Arable::Columns::Paths::STRUCTURE)

      File.read(Arable::Columns::Paths::STRUCTURE)
    end
  end
end
