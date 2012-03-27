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
//= require jquery.multi-accordion-1.5.3
//= require auto
//= require_tree .

$(document).ready(function(){
  $('#multiAccordion').multiAccordion();
  swidjit.mainmenu();
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

  $("#moreLink").toggle(function(){
      $(".profileBio").animate({height:$("#btxt").height()}, {queue:false, duration: 500});
      $('#moreLink').html('View Less <img src="img/arrowUP.png" border="0" alt="" />');
    },
    function(){
      $(".profileBio").animate({height: "100px"}, {queue:false, duration: 500})
      $('#moreLink').html('View Full Bio <img src="img/arrowDN.png" border="0" alt="" />');
    }
  );

});


$("#add_user_to_list_dropdown a").live('click',function(){
  var user_id = $("#user_id_for_list").val();
  var list_id = $(this).attr('data-list-id');
  var url = base_list_url.replace('/0','/'+list_id) + '/add_user';
  $.ajax({
    type: 'POST',
    url: url,
    data: { user_id: user_id },
    success: function(data){
      $("span.notice").text(data.notice);
    },
    error: function(xhr,status,data){
    }
  });
});

$("#add_item_button").live('click', function(){
  if( $("#add_item_form_wrapper").height() > 0 ){
    $("#add_item_form_wrapper").animate({height: "0"}, {queue:false, duration: 500});
  } else {
    $(".add_item_txt.item_first").click();
  }
  return false;
});

$(".add_item_txt").live("click",function(){
  $("#add_item_form").load($(this).attr('href'),function(){
    $('#add_item_form .datepicker').datepicker();
    $('#add_item_form .timepicker').timepicker({showPeriod: true});
    var target_height = $("#add_item_form").height() + parseInt($("#add_item_form").css('padding-top')) + parseInt($("#add_item_form").css('padding-bottom'));
    $("#add_item_form_wrapper").animate({height:target_height}, {queue:false, duration: 1000});
  });
  return false;
});

$(".comment_block a.reply").live("click",function(){
  $(this).parent().siblings('.comment-reply').slideToggle();
});

var swidjit = function() {
  return {
    updateVisibilityForm : function(sel) {
      var val = $(sel).val();
      if (val === '') { val = 0 }

      $.get('/users/' + val + '/visibility_options', function(data) {
        $('.item_visibility').replaceWith(data);
      });
    },
    mainmenu : function(){
      $(" .menu_with_dropdowns ul ").css({display: "none"}); // Opera Fix
      $(" .menu_with_dropdowns li").hover(function(){
          $(this).children('div').fadeIn(400, queue=false);
        },function(){
          $(this).children('div').hide();
      });
    },
    addTitle : function() {
      comm = $('#comments').val();
      comm = comm.substring(0,15);
      $('#title').val(comm);
    },
    updateOfferDisplay : function(sel, item_id) {
      var selected = $(sel).val();
      if (selected) {
        $("#offer_display").load('/items/' + item_id + '/users/' + selected + '/offers')
      } else {
        $("#offer_display").empty();
      }
    }
  };
}();
