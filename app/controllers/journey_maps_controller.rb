# frozen_string_literal: true

class JourneyMapsController < ApplicationController
  rescue_from BuildJourneyOrder::RepeatEntryDetected do |exception|
    render "errors/repeat_step_in_the_contentful_journey", status: 500, locals: {error: exception}
  end

  rescue_from BuildJourneyOrder::TooManyChainedEntriesDetected do |exception|
    render "errors/too_many_steps_in_the_contentful_journey", status: 500, locals: {error: exception}
  end

  def new
    entries = GetAllContentfulEntries.new.call
    category_entry = GetContentfulEntry.new(
      entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]
    ).call
    @journey_map = BuildJourneyOrder.new(
      entries: entries.to_a,
      category_entry: category_entry
    ).call
  end
end
