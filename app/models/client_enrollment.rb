class ClientEnrollment < ActiveRecord::Base
  belongs_to :client
  belongs_to :program_stream

  has_many :client_enrollment_trackings, dependent: :destroy
  has_many :form_builder_attachments, as: :form_buildable, dependent: :destroy
  has_many :trackings, through: :client_enrollment_trackings
  has_one :leave_program, dependent: :destroy

  validates :enrollment_date, presence: true
  accepts_nested_attributes_for :form_builder_attachments, reject_if: proc { |attributes| attributes['name'].blank? &&  attributes['file'].blank? }

  has_paper_trail

  scope :enrollments_by,              ->(client)         { where(client_id: client) }
  scope :find_by_program_stream_id,   ->(value)          { where(program_stream_id: value) }
  scope :active,                      ->                 { where(status: 'Active') }
  scope :inactive,                    ->                 { where(status: 'Exited') }

  after_create :set_client_status
  after_destroy :reset_client_status

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'program_stream', 'enrollment').validate
    CustomFormNumericalityValidator.new(obj, 'program_stream', 'enrollment').validate
    CustomFormEmailValidator.new(obj, 'program_stream', 'enrollment').validate
  end

  def active?
    status == 'Active'
  end

  def has_client_enrollment_tracking?
    client_enrollment_trackings.present?
  end

  def self.properties_by(value)
    value = value.gsub("'", "''")
    field_properties = select("client_enrollments.id, client_enrollments.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  def set_client_status
    client = Client.find self.client_id
    client_status = 'Active' unless client.cases.exclude_referred.currents.present?
    client.update_attributes(status: client_status) if client_status.present?
  end

  def get_form_builder_attachment(value)
    form_builder_attachments.find_by(name: value)
  end

  def reset_client_status
    client = Client.find(client_id)
    return if client.active_case? || client.client_enrollments.active.any?

    client.update(status: 'Referred')
  end
end
