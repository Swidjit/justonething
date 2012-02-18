class DatePickerInput < Formtastic::Inputs::StringInput
  def input_html_optoins
    super.merge(:class => 'ui-datepicker')
  end
end