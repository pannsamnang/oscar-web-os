module AdvancedSearches
  class EnrollmentSqlBuilder

    def initialize(program_stream_id, rule)
      @program_stream_id = program_stream_id
      field     = rule['field']
      @field    = field.split('_').last.gsub("'", "''")
      @operator = rule['operator']
      @value    = format_value(rule['value'])
      @type     = rule['type']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      client_enrollments = ClientEnrollment.where(program_stream_id: @program_stream_id)

      case @operator
      when 'equal'
        properties_result = client_enrollments.where("properties -> '#{@field}' ? '#{@value}' ")
      when 'not_equal'
        properties_result = client_enrollments.where.not("properties -> '#{@field}' ? '#{@value}' ")
      when 'less'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{'::int' if integer? } < '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'less_or_equal'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{ '::int' if integer? } <= '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'greater'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{ '::int' if integer? } > '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'greater_or_equal'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{ '::int' if integer? } >= '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'contains'
        properties_result = client_enrollments.where("properties ->> '#{@field}' ILIKE '%#{@value}%' ")
      when 'not_contains'
        properties_result = client_enrollments.where("properties ->> '#{@field}' NOT ILIKE '%#{@value}%' ")
      when 'is_empty'
        properties_result = client_enrollments.where("properties -> '#{@field}' ? '' ")
      when 'is_not_empty'
        properties_result = client_enrollments.where.not("properties -> '#{@field}' ? '' ")
      when 'between'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{ '::int' if integer? } BETWEEN '#{@value.first}' AND '#{@value.last}' AND properties ->> '#{@field}' != ''")
      end
      client_ids = properties_result.pluck(:client_id).uniq
      { id: sql_string, values: client_ids }
    end

    private
    def integer?
      @type == 'integer'
    end

    def format_value(value)
      value.is_a?(Array) ? value : value.gsub("'", "''")
    end
  end
end
