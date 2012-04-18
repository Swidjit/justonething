$ ->
  thumb = $('.thumbnail')

  # https://github.com/valums/ajax-upload
  window.logoUploader = new AjaxUpload('thumbnail', {
    name         : 'thumbnail'
    action       : '/images/generate'
    responseType : 'json'

    # Tell the controller which param contains the image file.
    data : {'image_param': 'thumbnail'}

    onSubmit: (file, extension) ->
      $('.thumbnail').addClass('loading')

    onComplete: (file, response) ->
      image_url = response.url
      image_id  = response.id

      # Replace logo image source, but don't remove its 'loading'
      # class until the new image is fully loaded.
      if (thumb.find('img').length == 0)
        thumb.append('<img />')
      thumb.find('img').load ->
        image = $(this)
        image.parent('.thumbnail').removeClass('loading')
        image.unbind()
      thumb.find('img').attr('src', image_url)

      # Update the hidden field with the uploaded image's ID for
      # form submission.
      $('#thumbnail_id').val(image_id)
  })