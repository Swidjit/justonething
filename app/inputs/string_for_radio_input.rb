class StringForRadioInput < Formtastic::Inputs::StringInput
  def to_html
    builder.text_field(method, input_html_options)
  end
end