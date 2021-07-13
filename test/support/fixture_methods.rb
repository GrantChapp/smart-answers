module FixtureMethods
  def fixture_file(filename)
    Rails.root.join("test/fixtures/#{filename}")
  end

  def read_fixture_file(filename)
    File.read(fixture_file(filename))
  end

  def setup_fixture_flows
    stub_request(:get, %r{#{Plek.new.find("content-store")}/content/(.*)})
      .to_return(status: 404, body: {}.to_json)

    fixture_flows_path = Rails.root.join("test/fixtures/smart_answer_flows")
    # require each of the flows since they're outside the autload path
    Dir[fixture_flows_path.join("*.rb")].map { |path| require path }

    @preload_flows = SmartAnswer::FlowRegistry.instance.preloaded?
    SmartAnswer::FlowRegistry.reset_instance(
      preload_flows: false,
      smart_answer_load_path: fixture_flows_path,
    )
  end

  def teardown_fixture_flows
    SmartAnswer::FlowRegistry.reset_instance(preload_flows: @preload_flows)
  end
end
