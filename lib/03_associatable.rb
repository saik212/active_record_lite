require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    self.class_name.constantize
  end

  def table_name
    # ...
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    defaults = {
      foreign_key: "#{name}_id".to_sym,
      class_name: name.to_s.camelcasem
      primary_key: :id
    }

    defaults.merge(options).each do |key, val|
      self.send("#{key}=", val)
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
     defaults = {
      foreign_key: "#{self_class_name}_id".to_sym,
      class_name: name.to_s.camelcasem
      primary_key: :id
    }

    defaults.merge(options).each do |key, val|
      self.send("#{key}=", val)
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do

      options = self.class.assoc_options[name]
      val = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => key).first

    end
  end

  def has_many(name, options = {})
    # ...
    assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do

      options = self.class.assoc_options[name]
      val = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => key).first

    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
