require "ostruct"

module SmartAnswer
  class Flow
    attr_reader :nodes
    attr_writer :status

    def self.build(&block)
      flow = new

      if block_given?
        flow.instance_eval(&block)
      else
        flow.define
      end

      flow
    end

    def initialize
      @nodes = []
      @additional_parameters = []
      @setup = nil
      status(:draft)
    end

    def append(flow)
      flow.nodes.each do |node|
        node.flow = self
        add_node(node)
      end
    end

    def content_id(id = nil)
      @content_id = id unless id.nil?
      @content_id
    end

    def name(name = nil)
      @name = name unless name.nil?
      @name
    end

    def response_store(response_store = nil)
      @response_store = response_store unless response_store.nil?
      @response_store
    end

    def additional_parameters(additional_parameters = nil)
      @additional_parameters = additional_parameters unless additional_parameters.nil?
      @additional_parameters
    end

    def status(potential_status = nil)
      if potential_status
        raise Flow::InvalidStatus unless %i[published draft].include? potential_status

        @status = potential_status
      end

      @status
    end

    def setup(&block)
      return @setup unless block_given?

      @setup = block
    end

    def radio(name, &block)
      add_node Question::Radio.new(self, name, &block)
    end

    def radio_with_intro(name, &block)
      add_node Question::RadioWithIntro.new(self, name, &block)
    end

    def country_select(name, options = {}, &block)
      add_node Question::CountrySelect.new(self, name, options, &block)
    end

    def date_question(name, &block)
      add_node Question::Date.new(self, name, &block)
    end

    def year_question(name, &block)
      add_node Question::Year.new(self, name, &block)
    end

    def value_question(name, options = {}, &block)
      add_node Question::Value.new(self, name, options, &block)
    end

    def money_question(name, &block)
      add_node Question::Money.new(self, name, &block)
    end

    def salary_question(name, &block)
      add_node Question::Salary.new(self, name, &block)
    end

    def checkbox_question(name, &block)
      add_node Question::Checkbox.new(self, name, &block)
    end

    def postcode_question(name, &block)
      add_node Question::Postcode.new(self, name, &block)
    end

    def outcome(name, &block)
      add_node Outcome.new(self, name, &block)
    end

    def outcomes
      @nodes.select(&:outcome?)
    end

    def questions
      @nodes.select(&:question?)
    end

    def node_exists?(node_or_name)
      @nodes.any? { |n| n.name == node_or_name.to_sym }
    end

    def node(node_or_name)
      @nodes.find { |n| n.name == node_or_name.to_sym } || raise("Node '#{node_or_name}' does not exist")
    end

    def start_node
      StartNode.new(self, name.underscore.to_sym)
    end

    def define; end

    class InvalidStatus < StandardError; end

  private

    def add_node(node)
      raise "Node #{node.name} already defined" if node_exists?(node)

      @nodes << node
    end
  end
end
