class ClientHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :object, type: Hash
  field :tenant, type: String, default: ->{ Organization.current.short_name }

  embeds_many :agency_client_histories
  embeds_many :client_family_histories
  embeds_many :case_client_histories
  embeds_many :client_custom_field_property_histories
  embeds_many :client_quantitative_case_histories

  after_save :create_agency_client_history, if: 'object.key?("agency_ids")'
  after_save :create_client_quantitative_case_history, if: 'object.key?("quantitative_case_ids")'
  after_save :create_case_client_history,   if: 'object.key?("case_ids")'
  after_save :create_client_family_history, if: 'object.key?("family_ids")'
  after_save :create_client_custom_field_property_history, if: 'object.key?("custom_field_property_ids")'

  def self.initial(client)
    attributes = client.attributes
    attributes = attributes.merge('quantitative_case_ids' => client.quantitative_case_ids) if client.quantitative_case_ids.any?
    attributes = attributes.merge('agency_ids' => client.agency_ids) if client.agency_ids.any?
    attributes = attributes.merge('case_ids' => client.case_ids) if client.case_ids.any?
    attributes = attributes.merge('family_ids' => client.family_ids) if client.family_ids.any?
    attributes = attributes.merge('custom_field_property_ids' => client.custom_field_properties.ids) if client.custom_field_properties.any?
    create(object: attributes)
  end

  private

  def create_client_quantitative_case_history
    object['quantitative_case_ids'].each do |quantitative_case_id|
      quantitative_case = QuantitativeCase.find_by(id: quantitative_case_id).try(:attributes)
      client_quantitative_case_histories.create(object: quantitative_case)
    end
  end

  def create_agency_client_history
    object['agency_ids'].each do |agency_id|
      agency = Agency.find_by(id: agency_id).try(:attributes)
      agency_client_histories.create(object: agency)
    end
  end

  def create_case_client_history
    object['case_ids'].each do |case_id|
      c_case = Case.find_by(id: case_id).try(:attributes)
      case_client_histories.create(object: c_case)
    end
  end

  def create_client_custom_field_property_history
    object['custom_field_property_ids'].each do |ccfp_id|
      custom_field_property = CustomFieldProperty.find_by(id: ccfp_id).try(:attributes)
      client_custom_field_property_histories.create(object: custom_field_property)
    end
  end

  def create_client_family_history
    object['family_ids'].each do |family_id|
      family = Family.find_by(id: family_id).try(:attributes)
      client_family_histories.create(object: family)
    end
  end
end