require "rails_helper"

RSpec.describe CreateJourneyStep do
  describe "#call" do
    context "when the new step is of type step" do
      it "creates a local copy of the new step" do
        journey = create(:journey, :catering)
        fake_entry = fake_contentful_step_entry(
          contentful_fixture_filename: "radio-question-example.json"
        )

        step = described_class.new(journey: journey, contentful_entry: fake_entry).call

        expect(step.title).to eq("Which service do you need?")
        expect(step.help_text).to eq("Tell us which service you need.")
        expect(step.contentful_model).to eq("question")
        expect(step.contentful_type).to eq("radios")
        expect(step.options).to eq(["Catering", "Cleaning"])
        expect(step.raw).to eq(fake_entry.raw)
      end

      it "updates the journey with a new next_entry_id" do
        journey = create(:journey, :catering)
        fake_entry = fake_contentful_step_entry(
          contentful_fixture_filename: "has-next-question-example.json"
        )

        _step = described_class.new(journey: journey, contentful_entry: fake_entry).call

        expect(journey.next_entry_id).to eql("5lYcZs1ootDrOnk09LDLZg")
      end
    end

    context "when the question is of type 'short_text'" do
      it "sets help_text and options to nil" do
        journey = create(:journey, :catering)
        fake_entry = fake_contentful_step_entry(
          contentful_fixture_filename: "short-text-question-example.json"
        )

        step = described_class.new(journey: journey, contentful_entry: fake_entry).call

        expect(step.options).to eq(nil)
      end

      it "replaces spaces with underscores" do
        journey = create(:journey, :catering)
        fake_entry = fake_contentful_step_entry(
          contentful_fixture_filename: "short-text-question-example.json"
        )

        step = described_class.new(journey: journey, contentful_entry: fake_entry).call

        expect(step.contentful_type).to eq("short_text")
      end
    end

    context "when the new step does not have a following step" do
      it "updates the journey by setting the next_entry_id to nil" do
        journey = create(:journey, :catering)
        fake_entry = fake_contentful_step_entry(
          contentful_fixture_filename: "radio-question-example.json"
        )

        _step = described_class.new(journey: journey, contentful_entry: fake_entry).call

        expect(journey.next_entry_id).to eql(nil)
      end
    end

    context "when the new entry has a body field" do
      it "updates the step with the body" do
        journey = create(:journey, :catering)
        fake_entry = fake_contentful_step_entry(
          contentful_fixture_filename: "static-content-example.json"
        )

        step, _answer = described_class.new(
          journey: journey, contentful_entry: fake_entry
        ).call

        expect(step.body).to eq("Procuring a new catering contract can \
take up to 6 months to consult, create, review and award. \n\nUsually existing \
contracts start and end in the month of September. We recommend starting this \
process around March.")
      end
    end

    context "when the new entry has an unexpected content model" do
      it "raises an error" do
        journey = create(:journey, :catering)
        fake_entry = fake_contentful_step_entry(
          contentful_fixture_filename: "an-unexpected-model-example.json"
        )

        expect { described_class.new(journey: journey, contentful_entry: fake_entry).call }
          .to raise_error(CreateJourneyStep::UnexpectedContentfulModel)
      end

      it "raises a rollbar event" do
        journey = create(:journey, :catering)

        fake_entry = fake_contentful_step_entry(
          contentful_fixture_filename: "an-unexpected-model-example.json"
        )

        expect(Rollbar).to receive(:warning)
          .with("An unexpected Contentful type was found",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
            contentful_entry_id: "6EKsv389ETYcQql3htK3Z2",
            content_model: "unmanagedPage",
            step_type: "radios",
            allowed_content_models: CreateJourneyStep::ALLOWED_CONTENTFUL_MODELS.join(", "),
            allowed_step_types: CreateJourneyStep::ALLOWED_CONTENTFUL_ENTRY_TYPES.join(", "))
          .and_call_original
        expect { described_class.new(journey: journey, contentful_entry: fake_entry).call }
          .to raise_error(CreateJourneyStep::UnexpectedContentfulModel)
      end
    end

    context "when the new step has an unexpected step type" do
      it "raises an error" do
        journey = create(:journey, :catering)
        fake_entry = fake_contentful_step_entry(
          contentful_fixture_filename: "an-unexpected-question-type-example.json"
        )

        expect { described_class.new(journey: journey, contentful_entry: fake_entry).call }
          .to raise_error(CreateJourneyStep::UnexpectedContentfulStepType)
      end

      it "raises a rollbar event" do
        journey = create(:journey, :catering)

        fake_entry = fake_contentful_step_entry(
          contentful_fixture_filename: "an-unexpected-question-type-example.json"
        )

        expect(Rollbar).to receive(:warning)
          .with("An unexpected Contentful type was found",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
            contentful_entry_id: "8as7df68uhasdnuasdf",
            content_model: "question",
            step_type: "telepathy",
            allowed_content_models: CreateJourneyStep::ALLOWED_CONTENTFUL_MODELS.join(", "),
            allowed_step_types: CreateJourneyStep::ALLOWED_CONTENTFUL_ENTRY_TYPES.join(", "))
          .and_call_original
        expect { described_class.new(journey: journey, contentful_entry: fake_entry).call }
          .to raise_error(CreateJourneyStep::UnexpectedContentfulStepType)
      end
    end
  end
end
