class QuestionPresenter < NodePresenter
  def title
    translate!('title') || @node.name.to_s.humanize
  end

  def error
    if @state.error.present?
      translate!(@state.error.to_sym) || error_message || I18n.translate('flow.defaults.error_message')
    end
  end

  def error_message
    translate!('error_message')
  end

  def has_error_message?
    !!error_message
  end

  def hint
    translate!('hint')
  end

  def has_hint?
    !!hint
  end

  def label
    translate!('label')
  end

  def has_label?
    !!label
  end

  def suffix_label
    translate!('suffix_label')
  end

  def has_suffix_label?
    !!suffix_label
  end

  def has_labels?
    !!label or !!suffix_label
  end

  def response_label(value)
    value
  end

  def partial_template_name
    "#{@node.class.name.demodulize.underscore}_question"
  end

  def multiple_responses?
    false
  end
end
