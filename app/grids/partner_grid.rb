class PartnerGrid
  include Datagrid

  scope do
    Partner.includes(:province).order(:name)
  end

  filter(:name, :string, header: -> { I18n.t('datagrid.columns.partners.name') }) do |value, scope|
    scope.name_like(value)
  end

  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.partners.id') })

  filter(:contact_person_name, :string, header: -> { I18n.t('datagrid.columns.partners.contact_name') }) do |value, scope|
    scope.contact_person_name_like(value)
  end

  filter(:contact_person_email, :string, header: -> { I18n.t('datagrid.columns.partners.contact_email') }) do |value, scope|
    scope.contact_person_email_like(value)
  end

  filter(:contact_person_mobile, :string, header: -> { I18n.t('datagrid.columns.partners.contact_mobile') }) do |value, scope|
    scope.contact_person_mobile_like(value)
  end

  filter(:organisation_type, :enum, select: :organisation_type_options, header: -> { I18n.t('datagrid.columns.partners.organisation_type') })

  def organisation_type_options
    Partner.organisation_type_are
  end

  filter(:affiliation, :string, header: -> { I18n.t('datagrid.columns.partners.affiliation') }) do |value, scope|
    scope.affiliation_like(value)
  end

  filter(:engagement, :string, header: -> { I18n.t('datagrid.columns.partners.engagement') }) do |value, scope|
    scope.engagement_like(value)
  end

  filter(:background, :string, header: -> { I18n.t('datagrid.columns.partners.background') }) do |value, scope|
    scope.background_like(value)
  end

  filter(:province_id, :enum, select: :province_options, header: -> { I18n.t('datagrid.columns.partners.province') })
  def province_options
    Partner.province_are
  end

  filter(:address, :string, header: -> { I18n.t('datagrid.columns.partners.address') }) do |value, scope|
    scope.address_like(value)
  end

  filter(:start_date, :date, range: true, header: -> { I18n.t('datagrid.columns.partners.start_date') })

  column(:id, header: -> { I18n.t('datagrid.columns.partners.id') })

  column(:name, html: true, order: 'LOWER(partners.name)', header: -> { I18n.t('datagrid.columns.partners.name') }) do |object|
    link_to(entity_name(object), partner_path(object))
  end

  column(:name, html: false, header: -> { I18n.t('datagrid.columns.partners.name') })

  column(:contact_person_name, header: -> { I18n.t('datagrid.columns.partners.contact_name') })

  column(:contact_person_email, order: 'LOWER(partners.contact_person_email)', header: -> { I18n.t('datagrid.columns.partners.contact_email') }) do |object|
    format(object.contact_person_email) do |object_email|
      mail_to(object_email)
    end
  end

  column(:contact_person_mobile, header: -> { I18n.t('datagrid.columns.partners.contact_mobile') }) do |object|
    object.contact_person_mobile.split('/').map { |b| b.phony_formatted(normalize: :KH, format: :international) }.join(' / ') if object.contact_person_mobile
  end

  column(:organisation_type, header: -> { I18n.t('datagrid.columns.partners.type') }, html: true)
  column(:organisation_type, header: -> { I18n.t('datagrid.columns.partners.organisation_type') }, html: false)

  column(:start_date, header: -> { I18n.t('datagrid.columns.partners.start_date') })
  column(:affiliation, header: -> { I18n.t('datagrid.columns.partners.affiliation') })
  column(:engagement, header: -> { I18n.t('datagrid.columns.partners.engagement') })
  column(:background, header: -> { I18n.t('datagrid.columns.partners.background') })
  column(:address, header: -> { I18n.t('datagrid.columns.partners.address') })

  column(:province, order: 'provinces.name', header: -> { I18n.t('datagrid.columns.partners.province') }) do |object|
    object.province.try(:name)
  end

  column(:manage, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.partners.manage') }) do |object|
    render partial: 'partners/actions', locals: { object: object }
  end

  column(:changelog, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.partners.changelogs') }) do |object|
    link_to t('datagrid.columns.partners.view'), partner_version_path(object)
  end
end
