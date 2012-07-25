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