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
//= require jquery
//= require jquery_ujs
//= require jquery.tokeninput
//= require jquery.ui.datepicker
//= require jquery.ui.timepicker
//= require ajaxupload
//= require item
//= require_self

jQuery(function() {
	jQuery.support.placeholder = false;
	test = document.createElement('input');
	if('placeholder' in test) jQuery.support.placeholder = true;
});

(function( $ ) {
  $.fn.placeholderFix = function(){
    if (!$.support.placeholder){
        $(this).find('[placeholder]').focus(function() {
            var input = $(this);
            if (input.val() == input.attr('placeholder')) {
                input.val('');
                input.removeClass('placeholder');
            }
        }).blur(function() {
            var input = $(this);
            if (input.val() == '' || input.val() == input.attr('placeholder')) {
                input.addClass('placeholder');
                input.val(input.attr('placeholder'));
            }
        }).blur().parents('form').submit(function() {
            $(this).find('[placeholder]').each(function() {
                var input = $(this);
                if (input.val() == input.attr('placeholder')) {
                    input.val('');
                }
            })
        });
    }
  };
})( jQuery );

$(document).ready(function(){
  $(document).placeholderFix();
  
  $('.posting-form').each(function(k, p) {
    Swidjit.prepPostingForm($(p));
  }).submit(Swidjit.submitPostingForm);

  $('.datepicker').datepicker();
  $('.timepicker').timepicker({showPeriod: true});

  $('.add_item a').click(function(e) {
    var $this = $(this);
    console.log('aargh');
    if ($this.data('item-type')) {
      var tags = $this.data('tags').split(',');
      var $form = $('.posting-form');
      var type = $form.find('#item_type').val();
      if (type === '' || type === $this.data('item-type')) {
        console.log($this.data('item-type'));
        Swidjit.setCategory($form, $('.type-opt-'+$this.data('item-type')).get(0));
        Swidjit.showPostingForm($form);
        $form.find('.item-add-tags').hide();
        $form.find('.field-tags').show();
        var $tagfield = $form.find('.field-tags .tag-input');
        for (var i = 0; i < tags.length; i++) {
          $tagfield.tokenInput('add', {id: tags[i], name: tags[i]});
        }
      }
    }
  });
});

var Swidjit = {
  titleModified: false,
  prepPostingForm: function($form) {
    $form.find('.field-desc textarea').focus(this.showPostingForm.bind(this, $form)).keyup(this.updateTitle.bind(this, $form));
    $form.find('.field-title textarea').change(function() {
      Swidjit.titleModified = true;
    });
    $form.find('.category-dropdown').click(function(e) {
      $form.find('.dropdown-menu').toggle();
    });
    $form.find('.dropdown-opt').mousedown(function() {
      Swidjit.setCategory($form, this);
      return false;
    });
    $form.find('.field-button').click(function() {
      $form.find('.'+$(this).data('field')).show();
      this.parentNode.removeChild(this);
      Swidjit.adjustPageTop($form.outerHeight());
      return false;
    });
    $form.find('.visibility-button').click(function() {
      $form.find('.field-visibility').show();
      this.parentNode.removeChild(this);
      Swidjit.adjustPageTop($form.outerHeight());
      return false;
    });

    $form.find('.publish-item').click(function() {
      $form.submit();
    });

    $form.find('.visibility-tokens').on('click', 'li a', function() {
      $this = $(this);
      Swidjit.removeVisRule($form, $this.data('vistype'), $this.data('visid'));
      this.parentNode.parentNode.removeChild(this.parentNode);
    });

    $form.find('.add-visibility').click(function() {
      var $dd = $form.find('.visibility-rule-dropdown');
      $dd.css('top', $(this.parentNode).outerHeight());
      $dd.toggle();
    });
    $form.find('.visibility-rule-dropdown').on('click', '.rule-name', function() {
      var $this = $(this);
      var $ruleset = $form.find('#item_'+$this.data('vistype')+'_ids');
      var id = $this.data('visid');
      var v = $ruleset.val();
      if (!v.match(new RegExp('\b'+id+'\b'))) {
        v = v.substring(0, v.length-1)+(v.length > 0 ? ',' : '')+id;
        $ruleset.val(v);
        $form.find('.visibility-tokens').append($('<li>'+$this.text()+'<a href="#" data-vistype="'+$this.data('vistype')+'" data-visid="'+$this.data('visid')+'">&times;</a></li>'));
      }
      $form.find('.visibility-rule-dropdown').hide();
    });

    var $tags = $form.find('.field-tags');
    $tags.find('.tag-input').tokenInput(
      $tags.data('autocomplete'), {
        hintText: 'Tag your item',
        preventDuplicates:'true',
        minChars:2
      }
    );
    $tags.find('.presets a').click(function() {
      $tags.find('.tag-input').tokenInput('add', {id: $(this).text(), name: $(this).text()});
    });
    var $geotags = $form.find('.field-geotags');
    $geotags.find('.tag-input').tokenInput(
      $geotags.data('autocomplete'), {
        hintText: 'Add location tags',
        preventDuplicates: 'true',
        minChars: 2
      }
    );
  },

  adjustPageTop: function(h) {
    $('#page_content').css('top',h+20);
  },

  updateTitle: function($form, e) {
    if (!this.titleModified) {
      $form.find('.field-title textarea').val($(e.target).val().substring(0,40));
    }
  },

  removeVisRule: function($form, type, id) {
    var v = $form.find('#item_'+type+'_ids').val();
    if (v.indexOf(id+',') > -1) {
      v = v.replace(id+',', '');
    } else {
      v = v.replace(id, '');
    }
    console.log(v);
    $form.find('#item_'+type+'_ids').val(v);
  },

  setCategory: function($form, cat) {
    $form.find('.category-selection').find('.category-title').text($(cat).find('.category-title').text());
    $form.find('.category-selection').find('.category-desc').text($(cat).find('.category-desc').text());
    $form.find('#item_type').val($(cat).data('type'));

    if ($(cat).data('type') === 'event') {
      $form.find('.expiration-field').hide();
      $form.find('.event-location').show();
      $form.find('.event-time-field').show();
    } else {
      $form.find('.event-time-field').hide();
      $form.find('.event-location').hide();
      $form.find('.expiration-field').show();
    }
    $form.find('.presets').hide();
    $form.find('.presets-'+$(cat).data('type')).show();
    console.log('.presets-'+$(cat).data('type'));
    Swidjit.adjustPageTop($form.outerHeight());

    $form.attr('action', $(cat).data('url'));
  },

  showPostingForm: function($form) {
    $form.addClass('expanded');
    Swidjit.adjustPageTop($form.outerHeight());
  },

  ensureField: function(section, input, button) {
    $(section).show();
    if (button !== undefined) {
      $(button).hide();
    }
    if ($(input).val() === '') {
      $(input).css('border-color', '#dd0000');
      return false;
    }
    $(input).css('border-color', '');
    return true;
  },

  showErrors: function($form, errors) {
    if (Array.isArray(errors)) {
      $form.find('.field-errors').show().text(errors.join('<br />'));
    } else {
      $form.find('.field-errors').show().text(errors);
    }
  },

  submitPostingForm: function() {
    $form = $(this);
    var type = $form.find('#item_type').val();
    if (type === 'event') {
      var valid = true;
      valid = Swidjit.ensureField('.field-title', '#item_title') && valid;
      valid = Swidjit.ensureField('.field-geotags', '#item_location', '.item-add-location') && valid;
      valid = Swidjit.ensureField('.field-time', '#item_start_date', '.item-add-time') && valid;
      valie = Swidjit.ensureField('.field-time', '#item_start_time', '.item-add-time') && valid;
      if (!valid) {
        Swidjit.showErrors($form, 'Please fill in the highlighted fields');
      }
      return valid;
    } else if (type === '') {
      Swidjit.showErrors($form, 'Please select an item category');
      return false;
    } else {
      if (Swidjit.ensureField('.field-title', '#item_title')) {
        $form.find('#item_start_date').remove();
        $form.find('#item_start_time').remove();
        $form.find('#item_end_date').remove();
        $form.find('#item_end_time').remove();
        $form.find('#item_location').remove();
      } else {
        Swidjit.showErrors($form, 'Please fill in the highlighted fields');
        return false;
      }
    }
  }
}