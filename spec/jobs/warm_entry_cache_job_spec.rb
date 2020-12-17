require "rails_helper"

RSpec.describe WarmEntryCacheJob, type: :job do
  include ActiveJob::TestHelper

  before(:each) { ActiveJob::Base.queue_adapter = :test }

  around do |example|
    ClimateControl.modify(
      CONTENTFUL_ENTRY_CACHING: "true"
    ) do
      example.run
    end
  end

  describe ".perform_later" do
    it "enqueues a job asynchronously on the caching queue" do
      expect {
        described_class.perform_later
      }.to have_enqueued_job.on_queue("caching")
    end

    it "asks GetAllContentfulEntries for the Contentful entries" do
      stub_get_contentful_entries(
        entry_id: "5kZ9hIFDvNCEhjWs72SFwj",
        fixture_filename: "multiple-entries-example.json"
      )

      described_class.perform_later
      perform_enqueued_jobs

      expect(RedisCache.redis.get("contentful:entry:5kZ9hIFDvNCEhjWs72SFwj"))
        .to eql(
          "\"{\\\"sys\\\":{\\\"space\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Space\\\",\\\"id\\\":\\\"rwl7tyzv9sys\\\"}},\\\"id\\\":\\\"5kZ9hIFDvNCEhjWs72SFwj\\\",\\\"type\\\":\\\"Entry\\\",\\\"createdAt\\\":\\\"2020-12-02T10:48:35.748Z\\\",\\\"updatedAt\\\":\\\"2020-12-02T10:48:35.748Z\\\",\\\"environment\\\":{\\\"sys\\\":{\\\"id\\\":\\\"develop\\\",\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Environment\\\"}},\\\"revision\\\":1,\\\"contentType\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"ContentType\\\",\\\"id\\\":\\\"staticContent\\\"}},\\\"locale\\\":\\\"en-US\\\"},\\\"fields\\\":{\\\"slug\\\":\\\"/timelines\\\",\\\"title\\\":\\\"When you should start\\\",\\\"body\\\":\\\"Procuring a new catering contract can take up to 6 months to consult, create, review and award. \\\\n\\\\nUsually existing contracts start and end in the month of September. We recommend starting this process around March.\\\",\\\"type\\\":\\\"paragraphs\\\",\\\"next\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Entry\\\",\\\"id\\\":\\\"hfjJgWRg4xiiiImwVRDtZ\\\"}}}}\""
        )
      expect(RedisCache.redis.get("contentful:entry:52Ni9UFvZj8BYXSbhs373C"))
        .to eql(
          "\"{\\\"sys\\\":{\\\"space\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Space\\\",\\\"id\\\":\\\"rwl7tyzv9sys\\\"}},\\\"id\\\":\\\"52Ni9UFvZj8BYXSbhs373C\\\",\\\"type\\\":\\\"Entry\\\",\\\"createdAt\\\":\\\"2020-11-04T12:28:30.442Z\\\",\\\"updatedAt\\\":\\\"2020-11-26T16:39:54.188Z\\\",\\\"environment\\\":{\\\"sys\\\":{\\\"id\\\":\\\"develop\\\",\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Environment\\\"}},\\\"revision\\\":6,\\\"contentType\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"ContentType\\\",\\\"id\\\":\\\"question\\\"}},\\\"locale\\\":\\\"en-US\\\"},\\\"fields\\\":{\\\"slug\\\":\\\"/dev-start-which-service\\\",\\\"title\\\":\\\"Which service do you need?\\\",\\\"helpText\\\":\\\"Tell us which service you need.\\\",\\\"type\\\":\\\"radios\\\",\\\"options\\\":[\\\"Catering\\\",\\\"Cleaning\\\"],\\\"next\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Entry\\\",\\\"id\\\":\\\"hfjJgWRg4xiiiImwVRDtZ\\\"}}}}\""
        )
    end
  end
end