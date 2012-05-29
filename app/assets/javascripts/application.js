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
//= require jquery.pageless
//= require jquery.xdomainajax
//= require lightbox
//= require_directory .

$(document).ready(function(){
  $('#multiAccordion').accordion({autoHeight: false});
  swidjit.mainmenu();
  $('.datepicker').datepicker();
  $('.timepicker').timepicker({showPeriod: true});
  $("#ui-datepicker-div").hide();

  $("#new_list").ajaxForm({
    success: function(data){
      $("#new_list_errors").text("");
      var new_link = $("<a>").attr("href",base_list_url.replace('/0','/'+data.id)).text(data.name);
      var new_li = $("<li></li>").html(new_link);
      $("#new_list").closest('li').before(new_li);
    }, error: function(xhr,status,data){
      $("#new_list_errors").text("List name already in use");
    }
  });

  var autocompete_user = { 'cache': {}, 'lastXhr': '' };
  $(".autocomplete-user").autocomplete({
    minLength: 1,
    source: function( request, response ) {
      var term = request.term;
      if ( term in autocompete_user['cache'] ) {
        response( autocompete_user['cache'][ term ] );
        return;
      }
      autocompete_user['lastXhr'] = $.getJSON( swidjit.user_suggestion_url(term), function( data, status, xhr ) {
        autocompete_user['cache'][ term ] = data.users;
        if ( xhr === autocompete_user['lastXhr'] ) {
          response( data.users );
        }
      });
    }
  });

  swidjit.userSuggestify($(".user-suggestion"));

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
    $("#add_item_form_wrapper").css('overflow','hidden').animate({height: "0"}, {queue:false, duration: 500});
  } else {
    $(".add_item_txt.item_first").click();
  }
  return false;
});

$(".add_item_txt").live("click",function(){
  swidjit.loadAddItemForm($(this).attr('href'));
  return false;
});
$("#link_link").live('input paste', function(e) {
  populateTitleAndDescription($(this).val());
});
$("#link_link").live("change",function(e){
  populateTitleAndDescription($(this).val())
});

function populateTitleAndDescription(targetUrl) {
  if(targetUrl.indexOf("http") === 0) {
    $.ajax({
      url: targetUrl,
      type: 'GET',
      success: function(res) {
        var scrapedValues = getTitleAndDescription($(res.responseText));
        $('#link_description').html(scrapedValues.description);
        $('#link_title').attr('value',scrapedValues.title);
      }
    });
  }
}

function getTitleAndDescription(obj) {
  var retObject = {title:"", description:""}
  $.each( obj, function(i, n){
    if ($(n).prop('tagName') && $(n).prop('tagName').toLowerCase() == 'title') {
      retObject.title = $(n).text();
    } else if ($(n).attr('name') == "description") {
      retObject.description = $(n).attr('content');
    }
  });
  return retObject;
}

$(".comment_block a.reply").live("click",function(){
  $(this).parent().siblings('.comment-reply').slideToggle();
  return false;
});

$(".toggle-offer-wrapper").live("click", function() {
  var img_tag = $(this).children().first();
  var slider = $(this).siblings('.offer_wrapper');

  swidjit.toggleWithArrow(img_tag,slider);
  return false;
});

$(".toggle-offer-reply").live("click",function(){
  $(this).siblings('.offer_reply_form').slideToggle();
  return false;
});

$(".toggle-user-edit").live("click",function(){
  var img_tag = $(this).children().first();
  var slider = $(this).parent().siblings('.user_edit');

  swidjit.toggleWithArrow(img_tag,slider);
  return false;
});

$(".item_description").live("change",function(){
  comm = $(this).val();
  comm = comm.substring(0,40);
  $title = $(this).closest('fieldset').find('.item_title')
  if($title.val() == ""){
    $title.val(comm);
  }
});

$("#calendar_select_date").live("click", function() {
  $("#calendar_select_date_hidden").focus();
  return false;
});
$("#calendar_select_date_hidden").live("change", function() {
  window.location.href = '/' + swidjit.currentCity() + '/calendar/date/' + $(this).val();
});

$("#add_item_form .visibility_rule_remove").live('click',function(){
  var ruleType = $(this).attr('data-rule-type');
  var visibilityID = $(this).attr('data-visibility-id');
  var $idInput = $(this).closest('li').siblings('li[id*="'+ruleType+'"]').children('input');
  var $thisRule = $(this).closest('div');
  var arIds = $.unique($idInput.val().split(','));
  var i =0, arLen = arIds.length;
  while(i < arLen){
    if(arIds[i] == visibilityID){
      arIds.splice(i,1);
      break;
    }
    i++;
  }
  $idInput.val(arIds.join(','));
  $thisRule.remove();
  return false;
});

$("#add_item_form #add_visibility_rule a").live('click',function(){
  var ruleType = $(this).attr('data-rule-type');
  var visibilityID = $(this).attr('data-visibility-id');
  var existingRule = $(this).closest('ul').parent().find('.visibility_rule_remove[data-visibility-id="'+visibilityID+'"][data-rule-type="'+ruleType+'"]').length;
  if( existingRule == 0 ){
    var $idInput = $(this).closest('ul').closest('li').siblings('li[id*="'+ruleType+'"]').children('input');
    console.log($idInput);
    var arIds = $idInput.val().length > 0 ? $idInput.val().split(',') : new Array();
    arIds.push(visibilityID);
    var ruleName = $(this).text();
    $newRule = $("<div class='"+ruleType+"_token'>"+ruleName+" <a href='#' class='visibility_rule_remove'"+
      " data-visibility-id='"+visibilityID+"' data-rule-type='"+ruleType+"'>x</a></div>");
    $idInput.val($.unique(arIds).join(','));
    $(this).closest('ul').before($newRule);
  }
  return false;
});

$("a.add_item, .add_item a").live('click',function(){
  if (USER_LOGGED_IN) {
    var itemType = $(this).data("itemType");
    var setTags = $(this).data("tags").replace(/ /g,'');
    var href = $("#post_"+itemType).attr('href').split('?')[0];
    href = href+"?tag_list="+setTags;
    swidjit.loadAddItemForm(href);
    return false;
  } else {
    window.location.href = "/users/sign_in";
    return false;
  }
});

var swidjit = function() {
  return {
    currentCity : function(){
      return window.location.pathname.split('/')[1];
    },
    loadAddItemForm : function(href){
      $("#add_item_form").load(href, function(){
        $('#add_item_form .datepicker').datepicker();
        $('#add_item_form .timepicker').timepicker({showPeriod: true});
        swidjit.userSuggestify($("#add_item_form .user-suggestion"));
        var target_height = $("#add_item_form").height() + parseInt($("#add_item_form").css('padding-top')) + parseInt($("#add_item_form").css('padding-bottom'));
        $("#add_item_form_wrapper").animate(
          {height:target_height},
          {queue:false, duration: 1000, complete: function(){
              $("#add_item_form_wrapper").css({'overflow':'visible','height':'auto'})
            }
          }
        );
        $(".mainContentWrap").scrollTop(0);
      });
    },
    updateVisibilityForm : function(sel) {
      var val = $(sel).val();
      if (val === '') { val = 0 }

      $.get('/users/' + val + '/visibility_options', function(data) {
        $('.item_visibility').replaceWith(data);
      });
    },
    mainmenu : function(){
      $(" .menu_with_dropdowns ul, .inline_menu_with_dropdowns ul ").css({display: "none"}); // Opera Fix
      $(" .menu_with_dropdowns li, .inline_menu_with_dropdowns li ").hover(function(){
          $(this).children('div').fadeIn(400, queue=false);
        },function(){
          $(this).children('div').hide();
      });
    },
    updateOfferDisplay : function(sel, item_id) {
      var selected = $(sel).val();
      if (selected) {
        $("#offer_display").load('/' + currentCity + '/items/' + item_id + '/users/' + selected + '/offers')
      } else {
        $("#offer_display").empty();
      }
    },
    toggleWithArrow : function(arrow,area){
      if ($(area).css('display') === 'block') {
        arrow.attr('src', '/assets/right_arrow.png');
      } else {
        arrow.attr('src', '/assets/down_arrow.png');
      }

      area.slideToggle();
    },
    userSuggestify : function($selector){
      $selector.at_autocomplete({ mode: "outer", on: { query: function(text, cb) {
        if (text.length === 0) return;

        $.getJSON(swidjit.user_suggestion_url(text), function(json) {
          cb(json.users);
        });
      } } });
    },
    user_suggestion_url : function(text){
      return '/users/' + text + '/suggestions.json'
    },
    scrape_link : function(){
      alert($('#link_link').val());
    }
  };
}();
