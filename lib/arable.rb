# frozen_string_literal: true

require_relative 'arable/version'
require_relative 'arable/columns/parser'

module Arable
  class Error < StandardError; end

  SKIP_ARABLE_COLUMNS_CLASS_VAR_NAME = :@@skip_arable_columns

  def self.models
    ApplicationRecord
      .models
      .reject { |model| model.class_variable_defined?(SKIP_ARABLE_COLUMNS_CLASS_VAR_NAME) }
  end

  def self.included(klass)
    return if klass.class_variable_defined?(SKIP_ARABLE_COLUMNS_CLASS_VAR_NAME)

    column_names = Arable::Columns::Parser.call(klass.table_name).map(&:to_sym)
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

  module ActiveRecordExtension
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
end
