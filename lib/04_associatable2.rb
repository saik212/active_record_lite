require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...
    define_method(name) do
			through_options = self.class_name.assoc_options[through_name]
			source_options = 	through_options.model_class.assoc_options[source_name]
			through_table = through_options.table_name
			source_table = source_options.table_name    	
    end

    results = DBConnection.execute(<<-SQL, self.id)
    SELECT
    	#{source_table}.*
    FROM
    	#{through_table}
    JOIN
    	#{source_table}
    ON
    	#{through_table}.#{source_options.foreign_key} = #{source_table}.#{source_options.primary_key}
    WHERE
    	#{source_table}.#{source_options.primary_key} = ?
   SQL

   parse_all(results).first
  end
end
