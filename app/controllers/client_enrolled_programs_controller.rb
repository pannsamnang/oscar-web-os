class ClientEnrolledProgramsController < AdminController
  load_and_authorize_resource :ClientEnrollment

  include ClientEnrollmentConcern
  include FormBuilderAttachments

  def index
    program_streams = ProgramStreamDecorator.decorate_collection(ordered_program)
    @program_streams = Kaminari.paginate_array(program_streams).page(params[:page]).per(20)
  end

  # def new
  #   if @program_stream.rules.present?
  #     if @program_stream.program_exclusive.any? || @program_stream.mutual_dependence.any?
  #       redirect_to client_client_enrolled_programs_path(@client), alert: t('.client_not_valid') unless valid_client? && valid_program?
  #     else
  #       redirect_to client_client_enrolled_programs_path(@client), alert: t('.client_not_valid') unless valid_client?
  #     end
  #   elsif @program_stream.mutual_dependence.any? || @program_stream.program_exclusive.any?
  #     redirect_to client_client_enrolled_programs_path(@client), alert: t('.client_not_valid') unless valid_program?
  #   end
  #   @client_enrollment = @client.client_enrollments.new(program_stream_id: @program_stream)
  # end

  def edit
  end

  def update
    if @client_enrollment.update_attributes(client_enrollment_params)
      add_more_attachments(@client_enrollment)
      redirect_to client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: @program_stream), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
  end

  # def create
  #   @client_enrollment = @client.client_enrollments.new(client_enrollment_params)
  #   authorize @client_enrollment
  #   if @client_enrollment.save
  #     redirect_to client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: @program_stream), notice: t('.successfully_created')
  #   else
  #     render :new
  #   end
  # end

  def destroy
    name = params[:file_name]
    index = params[:file_index].to_i
    params_program_streams = params[:program_streams]
    if name.present? && index.present?
      delete_form_builder_attachment(@client_enrollment, name, index)
      redirect_to request.referer, notice: t('.delete_attachment_successfully')
    else
      @client_enrollment.destroy
      redirect_to report_client_client_enrolled_programs_path(@client, program_stream_id: @program_stream), notice: t('.successfully_deleted')
    end
  end

  def report
    @enrollments = @program_stream.client_enrollments.where(client_id: @client).order(created_at: :DESC)
  end

  private

  def program_stream_order_by_enrollment
    ProgramStream.active_enrollments(@client).complete
  end
end
