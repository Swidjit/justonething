$('.event_start_date').live('change',function(){
  var end_date_name = this.name.replace('start_date','end_date');
  $('input[name="'+end_date_name+'"]').val($(this).val()).change();
});
$('.event_end_date').live('change',function(){
  var expires_on_name = this.name.replace('end_date','expires_on');
  var nextDayDate = $(this).datepicker('getDate');
  nextDayDate.setDate(nextDayDate.getDate() + 1);
  $('input[name="'+expires_on_name+'"]').datepicker('setDate', nextDayDate);
});

var swidjit = function() {
  return {
    updateVisibilityForm : function(sel) {
      var val = $(sel).val();
      if (val === '') { val = 0 }

      $.get('/users/' + val + '/visibility_options', function(data) {
        $('.item_visibility').replaceWith(data);
      });
    }
  };
}();
