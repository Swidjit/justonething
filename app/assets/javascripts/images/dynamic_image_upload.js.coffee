$ ->
  thumb = $('.thumbnail')
  up_container = $('.uploaded-image')

  thumb.find('.unload-image').click( ->
    up_container.removeClass('with-image')
    $('#thumbnail_id').val('')
  )

  # https://github.com/valums/ajax-upload
  window.logoUploader = new AjaxUpload('thumbnail', {
    name         : 'thumbnail'
    action       : '/images/generate'
    responseType : 'json'

    # Tell the controller which param contains the image file.
    data : {'image_param': 'thumbnail'}

    onSubmit: (file, extension) ->
      thumb.addClass('loading')

    onComplete: (file, response) ->
      image_url = response.url
      image_id  = response.id

      # Replace logo image source, but don't remove its 'loading'
      # class until the new image is fully loaded.
      if (up_container.find('img').length == 0)
        up_container.append('<img />')
      up_container.find('img').load ->
        image = $(this)
        image.parent('.thumbnail').removeClass('loading')
        image.unbind()
      up_container.find('img').attr('src', image_url)

      up_container.addClass('with-image')

      # Update the hidden field with the uploaded image's ID for
      # form submission.
      $('#item_thumbnail_id').val(image_id)
  })
