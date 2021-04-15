feature "Users can see the service banners" do
  scenario "A beta phase banner helps set expectations of the service" do
    visit root_path

    expect(page).to have_content(I18n.t("banner.beta.tag"))
    expect(page).to have_content("This is a new service – your feedback will help us to improve it.")
    expect(page).to have_link("feedback", href: "mailto:schools.digital@education.gov.uk")
  end

  context "when the app is configured as a Contenetful preview app" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_PREVIEW_APP: "true"
      ) do
        example.run
      end
    end

    it "renders a preview banner" do
      visit root_path

      expect(page).to have_content(I18n.t("banner.preview.tag"))
      expect(page).to have_content(I18n.t("banner.preview.message"))
    end
  end
end
