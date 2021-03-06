class ClientEnrollmentsController < AdminController
  load_and_authorize_resource

  include ClientEnrollmentConcern
  include FormBuilderAttachments

  def index
    program_streams = ProgramStreamDecorator.decorate_collection(ordered_program)
    @program_streams = Kaminari.paginate_array(program_streams).page(params[:page]).per(20)
  end

  def new
    if @program_stream.has_rule?
      if @program_stream.has_program_exclusive? || @program_stream.has_mutual_dependence?
        client_enrollment_index_path unless valid_client? && valid_program?
      else
        client_enrollment_index_path unless valid_client?
      end
    elsif @program_stream.has_program_exclusive? || @program_stream.has_mutual_dependence?
      client_enrollment_index_path unless valid_program?
    end

    @client_enrollment = @client.client_enrollments.new(program_stream_id: @program_stream)
    @attachment        = @client_enrollment.form_builder_attachments.build
  end

  def edit
  end

  def update
    if @client_enrollment.update_attributes(client_enrollment_params)
      add_more_attachments(@client_enrollment)
      redirect_to client_client_enrollment_path(@client, @client_enrollment, program_stream_id: @program_stream), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
  end

  def create
    @client_enrollment = @client.client_enrollments.new(client_enrollment_params)
    authorize @client_enrollment
    if @client_enrollment.save
      redirect_to client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: @program_stream), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def destroy
    name = params[:file_name]
    index = params[:file_index].to_i
    params_program_streams = params[:program_streams]
    if name.present? && index.present?
      delete_form_builder_attachment(@client_enrollment, name, index)
      redirect_to request.referer, notice: t('.delete_attachment_successfully')
    else
      @client_enrollment.destroy
      redirect_to report_client_client_enrollments_path(@client, program_stream_id: @program_stream), notice: t('.successfully_deleted')
    end
  end

  def report
    @enrollments = @program_stream.client_enrollments.enrollments_by(@client).order(created_at: :DESC)
  end

  private

  def program_stream_order_by_enrollment
    program_streams = []
    client_enrollments_exited     = ProgramStream.inactive_enrollments(@client).complete
    client_enrollments_inactive   = ProgramStream.without_status_by(@client).complete
    program_streams               = client_enrollments_exited + client_enrollments_inactive
  end
end
