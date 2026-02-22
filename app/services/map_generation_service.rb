class MapGenerationService
  MAX_POLL_ATTEMPTS = 30
  POLL_INTERVAL = 2

  def initialize(map)
    @map = map
  end

  def call
    invoke_lambda
    wait_for_result
  rescue => e
    Rails.logger.error("Map generation failed for Map##{@map.id}: #{e.message}")
    @map.failed!
  end

  private

  def invoke_lambda
    lambda_client.invoke(
      function_name: ENV.fetch("LAMBDA_FN_NAME"),
      payload: lambda_payload.to_json
    )
  end

  def wait_for_result
    bucket = s3_resource.bucket(ENV.fetch("AWS_BUCKET_NAME"))

    MAX_POLL_ATTEMPTS.times do
      if bucket.object(@map.filename).exists?
        @map.available!
        return
      end
      sleep POLL_INTERVAL
    end

    @map.failed!
  end

  def lambda_payload
    {
      formatSize: @map.format,
      mapStyle: @map.style,
      lon: @map.lon,
      lat: @map.lat,
      bucketFile: @map.filename,
      title: @map.title,
      subtitle: @map.subtitle,
      coords: @map.coords,
      zoom: @map.zoom
    }
  end

  def lambda_client
    @lambda_client ||= Aws::Lambda::Client.new(aws_config)
  end

  def s3_resource
    @s3_resource ||= Aws::S3::Resource.new(aws_config)
  end

  def aws_config
    {
      region: ENV.fetch("AWS_REGION", "eu-central-1"),
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    }
  end
end
