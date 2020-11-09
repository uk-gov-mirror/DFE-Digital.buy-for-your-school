# frozen_string_literal: true

class QuestionsController < ApplicationController
  rescue_from GetContentfulEntry::EntryNotFound do |exception|
    render "errors/contentful_entry_not_found", status: 500
  end

  rescue_from CreatePlanningQuestion::UnexpectedContentType do |exception|
    render "errors/unexpected_contentful_type", status: 500
  end

  def new
    @plan = Plan.find(plan_id)

    redirect_to plan_path(@plan) unless @plan.next_entry_id.present?

    @question = CreatePlanningQuestion.new(plan: @plan).call
    @answer = Answer.new
  end

  private

  def plan_id
    params[:plan_id]
  end
end