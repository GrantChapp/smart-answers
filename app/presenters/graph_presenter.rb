class GraphPresenter
  delegate :title, to: :start_node_presenter

  def initialize(flow)
    @flow = flow
  end

  def labels
    Hash[@flow.nodes.map { |node| [node.name, graph_label_text(node)] }]
  end

  def adjacency_list
    @adjacency_list ||= begin
      adjacency_list = {}
      @flow.questions.each do |node|
        adjacency_list[node.name] = []
        node.permitted_next_nodes.each do |permitted_next_node|
          existing_next_nodes = adjacency_list[node.name].map(&:first)
          unless existing_next_nodes.include?(permitted_next_node)
            adjacency_list[node.name] << [permitted_next_node, ""]
          end
        end
      end
      @flow.outcomes.each do |node|
        adjacency_list[node.name] = []
      end
      adjacency_list
    end
  end

  def visualisable?
    @flow.questions.all? do |node|
      node.permitted_next_nodes.any?
    end
  end

  def to_hash
    {
      labels: labels,
      adjacencyList: adjacency_list,
    }
  end

private

  def graph_label_text(node)
    text = "#{node.class.to_s.split('::').last}\n-\n"
    case node
    when SmartAnswer::Question::Radio
      text << word_wrap(node_title(node))
      text << "\n\n"
      text << node.permitted_options.map { |o| "( ) #{o}" }.join("\n")
    when SmartAnswer::Question::Checkbox
      text << word_wrap(node_title(node))
      text << "\n\n"
      text << node.options.map { |o| "[ ] #{o}" }.join("\n")
    when SmartAnswer::Question::Base
      text << word_wrap(node_title(node))
    when SmartAnswer::Outcome
      text << word_wrap(node.name.to_s)
    else
      text << "Unknown node type"
    end
    text
  end

  def word_wrap(text, line_width = 40)
    lines = text.split("\n").collect! do |line|
      line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip : line
    end
    lines * "\n"
  end

  module MethodMissingHelper
    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(method, *_args, &_block)
      MethodMissingObject.new(method)
    end
    # rubocop:enable Style/MissingRespondToMissing
  end

  def node_title(node)
    presenter = QuestionPresenter.new(node, nil, {}, helpers: [MethodMissingHelper])
    presenter.title
  end

  def start_node_presenter
    @start_node_presenter ||= StartNodePresenter.new(@flow.start_node)
  end
end
