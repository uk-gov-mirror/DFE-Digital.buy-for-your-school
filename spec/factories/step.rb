FactoryBot.define do
  factory :step do
    title { "What is your favourite colour?" }
    help_text { "Choose the primary colour closest to your choice" }
    raw { "{\"sys\":{}}" }

    association :journey, factory: :journey

    trait :radio do
      options { ["Red", "Green", "Blue"] }
      contentful_model { "question" }
      contentful_type { "radios" }
      association :radio_answer
    end

    trait :short_text do
      options { nil }
      contentful_model { "question" }
      contentful_type { "short_text" }
      association :short_text_answer
    end

    trait :long_text do
      options { nil }
      contentful_model { "question" }
      contentful_type { "long_text" }
      association :long_text_answer
    end

    trait :single_date do
      options { nil }
      contentful_model { "question" }
      contentful_type { "single_date" }
      association :single_date_answer
    end

    trait :checkbox_answers do
      options { ["Brown", "Gold"] }
      contentful_model { "question" }
      contentful_type { "checkboxes" }
      association :checkbox_answers
    end

    trait :static_content do
      options { nil }
      contentful_model { "staticContent" }
      contentful_type { "paragraphs" }
      association :paragraph_content
    end
  end
end