$(document).ready ->
    $('#event_start_date').live 'change', ->
        value = $(this).val()
        if value?
            date = new Date(value)
            day_of_week = date.getDay()
            week_of_month = Math.ceil(date.getDate() / 7)
            $('#event_weekly_day, #event_monthly_day').val day_of_week
            $('#event_monthly_week').val week_of_month
            $('#event_monthly_date').val date.getDate()
            
    swidjit.activateEvent = ->
        $('#has-end-time').click ->
            if not $(this).prop('checked')
                $('#event_end_date, #event_end_time').prop 'disabled', yes
                $('#event_end_date_input, #event_end_time_input').hide()
            else
                $('#event_end_date, #event_end_time').prop 'disabled', no
                $('#event_end_date_input, #event_end_time_input').show()

        if ($('#has-end-time:checked').size() > 0)
            $('#event_end_date, #event_end_time').prop 'disabled', no
            $('#event_end_date_input, #event_end_time_input').show()
        else
            $('#event_end_date, #event_end_time').prop 'disabled', yes

        template = '''
            <div class="additional-time">
              <input class="datepicker time_start_date" name="event[times][][start_date]" placeholder="Start Date" type="text">
              <input class="timepicker" name="event[times][][start_time]" placeholder="Start Time" type="text">
              <a href="#" class="remove-time">Remove</a>
            </div>
            '''
        
        $('#add-another-time').click (e) ->
            new_html = $ template
            $('#new-event-time-form').after(new_html)
            $('input.datepicker').datepicker()
            $('input.timepicker').timepicker showPeriod: yes

        $('a.remove-time').live 'click', (e) ->
            e.preventDefault()
            $(this).closest('.additional-time').remove()
    