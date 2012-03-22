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

  var user_suggestion_url = function(text){
    return '/users/' + text + '/suggestions.json'
  }

  var autocompete_user = { 'cache': {}, 'lastXhr': '' };
  $(".autocomplete-user").autocomplete({
    minLength: 1,
    source: function( request, response ) {
      var term = request.term;
      if ( term in autocompete_user['cache'] ) {
        response( autocompete_user['cache'][ term ] );
        return;
      }
      console.log(request);
      autocompete_user['lastXhr'] = $.getJSON( user_suggestion_url(term), function( data, status, xhr ) {
        autocompete_user['cache'][ term ] = data.users;
        if ( xhr === autocompete_user['lastXhr'] ) {
          response( data.users );
        }
      });
    }
  });

  $(".user-suggestion").at_autocomplete({ mode: "outer", on: { query: function(text, cb) {
    $(".user-suggestion").autocomplete({ mode: "outer", on: { query: function(text, cb) {
      if (text.length === 0) return;

      $.getJSON(user_suggestion_url(text), function(json) {
        cb(json.users);
      });
    } } });

    if (text.length === 0) return;

    $.getJSON(user_suggestion_url(text), function(json) {
      cb(json.users);
    });
  } } });
});
