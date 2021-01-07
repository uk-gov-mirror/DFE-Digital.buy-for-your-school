# frozen_string_literal: true

class JourneysController < ApplicationController
  def new
    journey = Journey.create(category: "catering", next_entry_id: ENV["CONTENTFUL_PLANNING_START_ENTRY_ID"])
    redirect_to new_journey_step_path(journey)
  end

  def show
    @journey = Journey.includes(
      steps: [:radio_answer, :short_text_answer, :long_text_answer]
    ).find(journey_id)
    @steps = @journey.steps.map { |step| StepPresenter.new(step) }

    @answers = @steps.each_with_object({}) { |step, hash|
      hash["answer_#{step.contentful_id}"] = step.answer.response.to_s
    }

    source = File.open("lib/specifications/catering.liquid").read
    @template = Liquid::Template.parse(
      source, error_mode: :strict
    ) # Parses and compiles the template
  end

  private

  def journey_id
    params[:id]
  end
end
