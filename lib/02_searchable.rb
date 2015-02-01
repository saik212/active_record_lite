require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # Grab keys array for columns
    # Grab vals array for values
    # Create Where line variable to insert into query
    # Parse results

    where_line = params.keys.map(|key| "#{key} = ?").join(" AND ")

    results = DBConnection.execute(<<-SQL, *params.keys)
    	SELECT
    		*
    	FROM
    		#{self.table_name}
    	WHERE
    		#{where_line}
    SQL

    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
