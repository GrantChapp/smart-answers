require_relative "../test_helper"

class FlowTest < ActiveSupport::TestCase
  test "Can set the name" do
    s = SmartAnswer::Flow.build do
      name "sweet-or-savoury"
    end

    assert_equal "sweet-or-savoury", s.name
  end

  test "can set response store type" do
    smart_answer = SmartAnswer::Flow.build do
      response_store(:session)
    end

    assert_equal smart_answer.response_store, :session
  end

  test "defaults to no response store" do
    smart_answer = SmartAnswer::Flow.build

    assert_nil smart_answer.response_store
  end

  test "cannot use hide-this-page if the response store isn't session" do
    exception = assert_raises RuntimeError do
      SmartAnswer::Flow.build { use_hide_this_page true }
    end

    assert_equal "This flow is not session based", exception.message
  end

  test "can use hide-this-page when response store is session" do
    smart_answer = SmartAnswer::Flow.build do
      response_store :session
      use_hide_this_page true
    end

    assert smart_answer.use_hide_this_page?
  end

  test "defaults to not use hide-this-page" do
    smart_answer = SmartAnswer::Flow.build

    assert_not smart_answer.use_hide_this_page?
  end

  test "can set flag to hide previous answers on results page" do
    smart_answer = SmartAnswer::Flow.build do
      hide_previous_answers_on_results_page true
    end

    assert smart_answer.hide_previous_answers_on_results_page?
  end

  test "can set flag to hide previous answers on results pagewith string" do
    smart_answer = SmartAnswer::Flow.build do
      hide_previous_answers_on_results_page "yes"
    end

    assert smart_answer.hide_previous_answers_on_results_page?
  end

  test "can set flag not to hide previous answers on results page" do
    smart_answer = SmartAnswer::Flow.build do
      hide_previous_answers_on_results_page "false"
    end

    assert_not smart_answer.hide_previous_answers_on_results_page?
  end

  test "defaults to show previous answers on results page" do
    smart_answer = SmartAnswer::Flow.build

    assert_not smart_answer.hide_previous_answers_on_results_page?
  end

  test "Can set the content_id" do
    s = SmartAnswer::Flow.build do
      content_id "587920ff-b854-4adb-9334-451b45652467"
    end

    assert_equal "587920ff-b854-4adb-9334-451b45652467", s.content_id
  end

  test "Can build outcome nodes" do
    s = SmartAnswer::Flow.build do
      outcome :you_dont_have_a_sweet_tooth
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.outcomes.size
    assert_equal [:you_dont_have_a_sweet_tooth], s.outcomes.map(&:name)
  end

  test "Can build outcomes where the whole flow uses ERB templates" do
    flow = SmartAnswer::Flow.build do
      name "flow-name"
      outcome :outcome_name
    end

    assert_equal 1, flow.outcomes.size
    assert flow.outcomes.first.template_directory.to_s.end_with?("flow-name")
  end

  test "Can build radio question nodes" do
    s = SmartAnswer::Flow.build do
      radio :do_you_like_chocolate? do
        option :yes
        option :no
        next_node do |response|
          case response
          when "yes" then outcome :sweet_tooth
          when "no" then outcome :savoury_tooth
          end
        end
      end

      outcome :sweet_tooth
      outcome :savoury_tooth
    end

    assert_equal 3, s.nodes.size
    assert_equal 2, s.outcomes.size
    assert_equal 1, s.questions.size
  end

  test "Can build country select question nodes" do
    stub_worldwide_api_has_locations(%w[afghanistan])

    s = SmartAnswer::Flow.build do
      country_select :which_country?
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal "afghanistan", s.questions.first.country_list.first.slug
  end

  test "Can build date question nodes" do
    s = SmartAnswer::Flow.build do
      date_question :when_is_your_birthday? do
        from { Date.parse("2011-01-01") }
        to { Date.parse("2014-01-01") }
      end
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal Date.parse("2011-01-01")..Date.parse("2014-01-01"), s.questions.first.range
  end

  test "Can build value question nodes" do
    s = SmartAnswer::Flow.build do
      value_question :what_colour_are_the_bottles? do
        on_response do |response|
          self.bottle_colour = response
        end
      end
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal :what_colour_are_the_bottles?, s.questions.first.name
  end

  test "Can build value question nodes with parse option specified" do
    s = SmartAnswer::Flow.build do
      value_question :how_many_green_bottles?, parse: Integer do
        on_response do |response|
          self.num_bottles = response
        end
      end
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
  end

  test "Can build money question nodes" do
    s = SmartAnswer::Flow.build do
      money_question :how_much? do
        on_response do |response|
          self.price = response
        end
      end
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal :how_much?, s.questions.first.name
  end

  test "Can build salary question nodes" do
    s = SmartAnswer::Flow.build { salary_question :how_much? }
    assert_equal [:how_much?], s.questions.map(&:name)
  end

  test "Can build checkbox question nodes" do
    s = SmartAnswer::Flow.build do
      checkbox_question :choose_some do
        option :foo
        next_node { outcome :done }
      end
      outcome :done
    end

    assert_equal 2, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal "SmartAnswer::Question::Checkbox", s.questions.first.class.name
  end

  test "Can build postcode question nodes" do
    flow = SmartAnswer::Flow.build { postcode_question :postcode? }

    assert_equal 1, flow.questions.size
    question = flow.questions.first
    assert_equal :postcode?, question.name
    assert_instance_of SmartAnswer::Question::Postcode, question
  end

  test "should default to a draft status" do
    s = SmartAnswer::Flow.build {}

    assert_equal :draft, s.status
  end

  test "supports setting a status" do
    s = SmartAnswer::Flow.build do
      status :published
    end

    assert_equal :published, s.status
  end

  test "should throw an exception if invalid status provided" do
    assert_raise SmartAnswer::Flow::InvalidStatus do
      SmartAnswer::Flow.build do
        status :bin
      end
    end
  end

  test "Can build a start node" do
    flow = SmartAnswer::Flow.build do
      name "my-flow"
      start_page
    end

    start_node = flow.nodes.first

    assert_instance_of SmartAnswer::StartNode, start_node
    assert start_node.name, "my_flow"
  end

  context "when another flow is appended to this one" do
    setup do
      other_flow = SmartAnswer::Flow.build do
        outcome :another_outcome
      end
      @flow = SmartAnswer::Flow.build do
        name "primary-flow"

        start_page
        value_question :question?
        outcome :outcome
        append(other_flow)
      end
    end

    should "have nodes from other flow after nodes in this flow" do
      assert_equal %i[primary_flow question? outcome another_outcome], @flow.nodes.map(&:name)
    end

    should "set flow on all nodes from other flow" do
      assert(@flow.nodes.all? { |node| node.flow == @flow })
    end
  end
end
