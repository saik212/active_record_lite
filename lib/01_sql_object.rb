require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # return columns if it already exists (save time from further processing)
    @columns if @columns

    # otherwise find the columns and turn them to symbols
    columns = DBCONNECTION.execute2(
      "SELECT *
       FROM #{self.table_name}"
      )[0] # first el in array is just col names

    columns.map!(&:to_sym)
    @columns = columns

  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) {instance_variable_get("@#{column}")}

      define_method("#{column}=") {|value| instance_variable_get("@#{columns}", value)}
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    # Make SQL query for all rows of a table
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    parse_all(results)

  end

  def self.parse_all(results)
    # Take each row when .all is called, and instantiate new instances
    # of class with respective attributes passed as params

    results.map {|result| self.new (result)}
  end

  def self.find(id)
    # Pass in id as arg for SQL query
    # parse whatever result from DB query

    results = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL

    parse_all(results).first
  end

  def initialize(params = {})
    # take in params
    # assign values to columns
    # throw error if column name doesn't exist

    params.each do |attr, val|

      if self.class.columns.include?(attr.to_sym)
        self.send("#{attr.to_sym}=", val)
      else
        raise "#{attr} is not a recognized attribute"
      end

    end
  end

  def attributes
    @attributes || {}
  end

  def attribute_values
    # get array of values of columns
    self.class.columns.map {|col| self.send(col)}
  end

  def insert
    # Grab table columns and convert to symbols
    # use ?'s in SQL query: number ? == number columns
    cols = self.class.columns.map(&:to_sym).join(", ")
    q_marks = []

    self.class.columns.count.times {q_marks << "?"}
    q_marks.join!(", ")

    DBConnection.execute(<<-SQL)
      INSERT INTO
        #{self.class.table_name} (#{cols})
      VALUES
        (#{q_marks})
    SQL

    # Record inserted into DB with id; update SQLObject
    # with id

    self.id = DBConnection.last_insert_row_id
  end

  def update
    # set variable for SET line in SQL query
    # create SQL update query
    cols = self.class.columns.map{|col| "#{col}= ?"}.join(',  ')

    # pass in attribute values since num of values is variable
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{cols}
      WHERE
        id = ?
    SQL
  end

  def save
    # save instance to DB
    # insert if new, update if existing
    if id.nil?
      self.insert
    else
      self.update
    end
  end

end
