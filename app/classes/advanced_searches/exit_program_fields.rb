module AdvancedSearches
  class ExitProgramFields

    include AdvancedSearchHelper

    def initialize(program_ids)
      @program_ids = program_ids

      @number_type_list     = []
      @text_type_list       = []
      @date_type_list       = []
      @drop_down_type_list  = []
      @exit_data_list       = []

      generate_field_by_type
    end

    def render
      number_fields       = @number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_label(item), format_optgroup(item)) }
      text_fields         = @text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_label(item), format_optgroup(item)) }
      date_picker_fields  = @date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_label(item), format_optgroup(item)) }
      drop_list_fields    = @drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_label(item.first) , item.last, format_optgroup(item.first)) }

      results = text_fields + drop_list_fields + number_fields + date_picker_fields

      results.sort_by { |f| f[:label].downcase }

      @exit_data_list.map{ |item|results.unshift AdvancedSearches::FilterTypes.date_picker_options(item, format_label(item), format_optgroup(item)) }
      
      results
    end

    def generate_field_by_type
      program_streams = ProgramStream.where(id: @program_ids)

      program_streams.each do |program_stream|
        @exit_data_list << "programexitdate_#{program_stream.name}_Exit Date"
        program_stream.exit_program.each do |json_field|
          if json_field['type'] == 'text' || json_field['type'] == 'textarea'
            @text_type_list << "exitprogram_#{program_stream.name}_#{json_field['label']}"
          elsif json_field['type'] == 'number'
            @number_type_list << "exitprogram_#{program_stream.name}_#{json_field['label']}"
          elsif json_field['type'] == 'date'
            @date_type_list << "exitprogram_#{program_stream.name}_#{json_field['label']}"
          elsif json_field['type'] == 'select' || json_field['type'] == 'checkbox-group' || json_field['type'] == 'radio-group'
            drop_list_values = []
            drop_list_values << "exitprogram_#{program_stream.name}_#{json_field['label']}"
            drop_list_values << json_field['values'].map{|value| { value['label'] => value['label'] }}
            @drop_down_type_list << drop_list_values
          end
        end
      end
    end

    private
    def format_label(value)
      value.split('_').last
    end

    def format_optgroup(value)
      name = value.split('_').second
      key_word = format_header('exit_program')
      "#{name} | #{key_word}"
    end
  end
end
