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
//= require ajaxupload
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
    });
    $form.find('.field-button').click(function() {
      $form.find('.'+$(this).data('field')).show();
      this.parentNode.removeChild(this);
      Swidjit.adjustPageTop($form.outerHeight());
    });

    $form.find('.publish-item').click(function() {
      $form.submit();
    });

    $tags = $form.find('.field-tags');
    $tags.find('.tag-input').tokenInput(
      $tags.data('autocomplete'), {
        hintText: 'Tag your item',
        preventDuplicates:'true',
        minChars:2
      }
    );
    $geotags = $form.find('.field-geotags');
    $geotags.find('.tag-input').tokenInput(
      $geotags.data('autocomplete'), {
        hintText: 'Add location tags',
        preventDuplicates: 'true',
        minChars: 2
      }
    );
  },

  adjustPageTop: function(h) {
    $('#page_content').css('top',h);
  },

  updateTitle: function($form, e) {
    if (!this.titleModified) {
      $form.find('.field-title textarea').val($(e.target).val().substring(0,40));
    }
  },

  setCategory: function($form, cat) {
    $form.find('.category-selection').find('.category-title').text($(cat).find('.category-title').text());
    $form.find('.category-selection').find('.category-desc').text($(cat).find('.category-desc').text());
    $form.find('#item_type').val($(cat).data('type'));

    $form.attr('action', $(cat).data('url'));
  },

  showPostingForm: function($form) {
    $form.addClass('expanded');
    Swidjit.adjustPageTop($form.outerHeight());
  }
}