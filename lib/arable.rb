# frozen_string_literal: true

require_relative "arable/version"

module Arable
  class Error < StandardError; end

  SKIP_ARABLE_COLUMNS_CLASS_VAR_NAME = :@@skip_arable_columns

  def self.models
    ApplicationRecord.models.reject { _1.class_variable_defined?(SKIP_ARABLE_COLUMNS_CLASS_VAR_NAME) }
  end

  def self.column_names_from_schema(table_name)
    table_definition_match =
      File
        .read('db/schema.rb')
        .match(/create_table "#{table_name}".*?\n(.*?)\n *end/m)

    columns =
      table_definition_match[1]
        .lines
        .reject { |line| line.include?('t.index') }
        .map { |line| line.match(/t\.[a-z]* "([a-z_]*)"/)[1] }

    if table_definition_match[0].include?('id: false')
      columns
    else
      ['id'] + columns
    end
  end

  def self.included(klass)
    return if klass.class_variable_defined?(SKIP_ARABLE_COLUMNS_CLASS_VAR_NAME)

    column_names = column_names_from_schema(klass.table_name).map(&:to_sym)
    illegal_names = column_names & klass.methods

    if illegal_names.any?
      Rails.logger.warn("#{klass} model has illegal column names: #{illegal_names}. Please rename these columns.")
    end

    (column_names - illegal_names).each do |name|
      klass.define_singleton_method(name) do
        klass.arel_table[name]
      end
    end
  end

  module ClassMethods
    def skip_arable_columns!
      class_variable_set(SKIP_ARABLE_COLUMNS_CLASS_VAR_NAME, true)
    end

    def star
      arel_table[Arel.star]
    end
  end
end

ActiveSupport.on_load(:active_record) do |active_record|
  def inherited(subclass)
    super

    subclass.extend(Arable::ClassMethods)

    # include Arable only when the class has finished defining itself
    TracePoint.trace(:end) do |trace|
      if subclass == trace.self
        subclass.include(Arable)
        trace.disable
      end
    end
  end
end
