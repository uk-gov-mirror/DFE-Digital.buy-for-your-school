class CreateJourney
  attr_accessor :category

  def initialize(category:)
    self.category = category
  end

  def call
    # Move to using GetContentfulEntry instead of GetAllContentfulEntries (except for cache warming)
    # We reduce the majority of fixtures but reduce the testing boundary to stubbing a category model
    # in most cases.
    # category.entries => [Contentful::Entry]

    category = GetCategory.call(ENV)
    # steps = category.steps.each do |step|
    #   GetStep.call(step) #
    # end
    # or steps = GetContentfulSteps.call(category)

    journey = Journey.create(category:1)
    category.entries.map{|step| CreateJourneyStep.call(journey, step) }
    return journey

    # testing
    # 1. We always need a category fixture that has {category, steps}
    # 2. We always need at least one step fixture that has {step, data}
    # 3. Both above must be connected, easy to work with but not fragile
    def stub_a_contentful_entry(category:)
      category = File.open category_fixture
      allow(GetCategory).to receive(:call).and_return category

      category.steps.each do |step|
        step = File.open step_fixture
        # error if step.id != category step reference to help us manage the complexity?
        allow(GetStep).to receive(:call).and_return step
      end

  end

  private def liquid_template
    FindLiquidTemplate.new(category: category).call
  end
end
#
# category = GetContentfulCategory.new(entry_id: ENV).call
# entries = GetContentfulEntries.new(entry_ids: [category.steps.map(&:entry.id)]).call
#
# class GetContentfulCategory
#   def call
#     # Do the caching and allow us a class to stub and return a fixture where this class is used
#     GetContentfulEntry.new(entry_id: "category-id").call
#   end
# end
#
# class GetContentfulEntries
#   def call
#     entry_ids.each do |entry_id|
#       GetContentfulEntry.new(entry_id: entry_id).call
#     end
#   end
# end
#
# stub_get_contentful_category(entry_id: category_id, fixture: "/category/broken-step")
# stub_get_contentful_step(entry_id: broken_step_id, fixture: "/step/broken-step")
