class Preview::EntriesController < ApplicationController
  before_action :check_app_is_running_in_preview_env

  def show
    @journey = Journey.create(
      category: "catering",
      user: current_user,
      liquid_template: "<p>N/A</p>"
    )

    contentful_entry = GetEntry.new(entry_id: entry_id).call
    @step = CreateJourneyStep.new(
      journey: @journey, contentful_entry: contentful_entry
    ).call

    redirect_to journey_step_path(@journey, @step)
  end

  private

  def entry_id
    params[:id]
  end

  def check_app_is_running_in_preview_env
    return if ENV["CONTENTFUL_PREVIEW_APP"].eql?("true")
    render file: "public/404.html", status: :not_found, layout: false
  end
end
