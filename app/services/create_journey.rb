class CreateJourney
  attr_accessor :category

  def initialize(category:)
    self.category = category
  end

  def call
    journey = Journey.create(
      category: category,
      liquid_template: liquid_template
    )
    entries = GetAllContentfulEntries.new.call
    category_entry = GetContentfulEntry.new(
      entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]
    ).call #gives us a Contentful::Entry
    question_entries = BuildJourneyOrder.new(
      category_entry: category_entry, entries: entries.to_a
    ).call
    question_entries.each do |entry|
      CreateJourneyStep.new(
        journey: journey, contentful_entry: entry
      ).call
    end
    journey
  end

  private def liquid_template
    FindLiquidTemplate.new(category: category).call
  end
end
