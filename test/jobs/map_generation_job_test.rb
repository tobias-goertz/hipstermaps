require "test_helper"

class MapGenerationJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  test "enqueues job" do
    assert_enqueued_with(job: MapGenerationJob) do
      MapGenerationJob.perform_later(1)
    end
  end
end
