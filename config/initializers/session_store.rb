Rails.application.config.session_store(
  :cookie_store,
  key: "_buy_for_your_school_session",
  secure: Rails.env.production?
)
