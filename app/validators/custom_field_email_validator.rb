class CustomFieldEmailValidator < ActiveModel::Validator

  def initialize(record)
    @record = record
  end

  def validate
    return unless @record.properties
    @record.custom_field.field_objs.each do |field|
      if field['subtype'] == 'email'
        unless @record.properties_objs[field['name']] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
          @record.errors.add(field['name'], "input is not an email")
        end
      end
    end
  end

end