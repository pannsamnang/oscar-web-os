module AbleScreens
  module QuestionSubmissions
    class AbleScreeningQuestionsController < AdminController
      load_and_authorize_resource
      before_action :set_able_screening_question, only: [:edit, :update]

      def new
        @able_screening_question = AbleScreeningQuestion.new
      end

      def create
        @able_screening_question = AbleScreeningQuestion.new(able_screening_question_params)
        if @able_screening_question.save
          redirect_to able_screens_question_submissions_stages_path, notice: t('.successfully_created')
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @able_screening_question.update_attributes(able_screening_question_params)
          redirect_to able_screens_question_submissions_stages_path, notice: t('.successfully_updated')
        else
          render :edit
        end
      end

      private

      def able_screening_question_params
        params.require(:able_screening_question)
              .permit(:question, :mode, :question_group_id, :alert_manager, attachments_attributes: [:id, :image])
      end

      protected

      def set_able_screening_question
        @able_screening_question = AbleScreeningQuestion.non_stage.find(params[:id])
      end
    end
  end
end
