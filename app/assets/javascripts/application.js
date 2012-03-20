// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery_ujs
//= require jquery.tokeninput
//= require jquery.caret
//= require auto
//= require_tree .

$(document).ready(function(){
  $('.datepicker').datepicker();
  $('.timepicker').timepicker({showPeriod: true});
  $("#ui-datepicker-div").hide();

  $("#new_list").ajaxForm({
    success: function(data){
      $("#new_list_errors").text("");
      var new_link = $("<a>").attr("href",base_list_url.replace('/0','/'+data.id)).text(data.name);
      $("#new_list").before(new_link);
    }, error: function(xhr,status,data){
      $("#new_list_errors").text("List name already in use");
    }
  });

  $("#add_user_to_list_dropdown").change(function(){
    var user_id = $("#user_id_for_list").val();
    var list_id = this.value;
    var url = base_list_url.replace('/0','/'+list_id) + '/add_user';
    $.ajax({
      type: 'POST',
      url: url,
      data: { user_id: user_id },
      success: function(data){
        $("#add_user_to_list_message").text(data.notice);
        $("#add_user_to_list_dropdown").val("");
      },
      error: function(xhr,status,data){
      }
    });
  });
});
