$ ->
  if document.getElementById('is_business_signup') && document.getElementById('is_business_signup').checked
    do $('#bname_signup').show
    $('#fname_signup label').text 'Contact first name'
    $('#lname_signup label').text 'Contact last name'

  $('input#is_business_signup').change ->
    if this.checked
      do $('#bname_signup').show
      $('#fname_signup label').text 'Contact first name'
      $('#lname_signup label').text 'Contact last name'
    else
      do $('#bname_signup').hide
      $('#fname_signup label').text 'First name'
      $('#lname_signup label').text 'Last name'
