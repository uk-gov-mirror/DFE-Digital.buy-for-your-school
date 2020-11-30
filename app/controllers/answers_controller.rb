# frozen_string_literal: true

class AnswersController < ApplicationController
  def create
    @journey = Journey.find(journey_id)
    @step = Step.find(step_id)

    @answer = AnswerFactory.new(step: @step).call
    @answer.assign_attributes(answer_params)
    @answer.step = @step

    if @answer.valid?
      @answer.save
      if @journey.next_entry_id.present?
        redirect_to new_journey_step_path(@journey)
      else
        redirect_to journey_path(@journey)
      end
    else
      render "steps/new.#{@step.contentful_type}"
    end
  end

  private

  def journey_id
    params[:journey_id]
  end

  def step_id
    params[:step_id]
  end

  def answer_params
    params.require(:answer).permit(:response)
  end
end
