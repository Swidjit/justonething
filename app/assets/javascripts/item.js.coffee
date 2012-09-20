setExpirationDate = ->
  expires_on_name = @name.replace /\[\w{3,5}_date/, '[expires_on'
  nextDayDate = $(@).datepicker 'getDate'
  nextDayDate.setDate nextDayDate.getDate() + 1
  $('input[name="' + expires_on_name + '"]').datepicker 'setDate', nextDayDate

$('.event_start_date').live 'change', ->
  end_date_name = @name.replace 'start_date', 'end_date'
  $('input[name="' + end_date_name + '"]').val($(@).val()).change()
  setExpirationDate.apply this

$('.event_end_date').live 'change', ->
  setExpirationDate.apply this



