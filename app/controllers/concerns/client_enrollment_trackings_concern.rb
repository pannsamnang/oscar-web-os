module ClientEnrollmentTrackingsConcern
  extend ActiveSupport::Concern

  included do
    before_action :find_client, :find_enrollment, :find_program_stream
    before_action :find_tracking, except: [:index, :show, :destroy]
    before_action :find_client_enrollment_tracking, only: [:update, :destroy, :edit, :show]
    before_action :get_attachments, only: [:new, :create, :edit, :update]
  end

  def client_enrollment_tracking_params
    properties_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 } if properties_params.present?

    default_params = params.require(:client_enrollment_tracking).permit({}).merge!(tracking_id: params[:tracking_id])
    default_params = default_params.merge!(properties: properties_params) if properties_params.present?
    default_params = default_params.merge!(form_builder_attachments_attributes: params[:client_enrollment_tracking][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
    default_params
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find params[:client_id]
  end

  def find_enrollment
    emrollment_id = params[:client_enrollment_id] || params[:client_enrolled_program_id]
    @enrollment = @client.client_enrollments.find emrollment_id
  end

  def find_program_stream
    @program_stream = @enrollment.program_stream
  end

  def find_tracking
    @tracking = @program_stream.trackings.find(params[:tracking_id])
  end

  def find_client_enrollment_tracking
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.find(params[:id])
  end

  def get_attachments
    @client_enrollment_tracking ||= @enrollment.client_enrollment_trackings.new
    @attachments = @client_enrollment_tracking.form_builder_attachments
  end
end
