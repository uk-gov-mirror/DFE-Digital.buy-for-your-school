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

    respond_to do |format|
      format.html
      format.docx do
        render docx: "specification.docx", content: @template.render(@answers)
      end
      format.pdf do
        send_data WickedPdf.new.pdf_from_string(@template.render(@answers)), filename: "specfification.pdf"
      end
      format.odt do
        send_data Html2Odt::Document.new(html: @template.render(@answers)).data, filename: "specfification.odt"
      end
    end
  end

  private

  def journey_id
    params[:id]
  end
end
