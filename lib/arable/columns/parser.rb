require_relative "from_schema"
require_relative "from_structure"
require_relative "paths"

module Arable::Columns::Parser
  WARN_MESSAGE = "No schema definition found, looked in #{Arable::Columns::Paths::ALL.join(', ')}".freeze

  module_function

  def call(table_name)
    Arable::Columns::FromSchema.call(table_name) ||
      Arable::Columns::FromStructure.call(table_name) ||
      Rails.logger.warn(WARN_MESSAGE)
  end
end
