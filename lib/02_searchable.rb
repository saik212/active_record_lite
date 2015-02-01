require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # Grab keys array for columns
    # Grab vals array for values
    # Create Where line variable to insert into query

    where_line = params.keys.map(|key| "#{key} = ?").join(" AND ")
  end
end

class SQLObject
  # Mixin Searchable here...
end
