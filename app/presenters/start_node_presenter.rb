class StartNodePresenter < NodePresenter
  def initialize(node, flow_presenter, state = nil, options = {})
    super(node, flow_presenter, state)
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory,
      template_name: "start",
    )
  end

  def title
    @renderer.content_for(:title)
  end

  def meta_description
    @renderer.content_for(:meta_description)
  end

  def body
    @renderer.content_for(:body)
  end

  def post_body
    @renderer.content_for(:post_body)
  end

  def start_button_text
    custom_button_text = @renderer.content_for(:start_button_text)
    custom_button_text.presence || "Start now"
  end

  def view_template_path
    "smart_answers/landing"
  end
end
