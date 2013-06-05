###*
* @author José Luis García <jlgarcia.me>
* @license MIT <https://raw.github.com/jlgarhdez/link-expander/master/LICENSE>
###

textarea = document.getElementById 'textarea'

pasteHandler = (event) ->
  pattern = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!-\/]))?/
  data = event.clipboardData.getData 'text/plain'
  if pattern.test data
    expandLink data
  @

textarea.addEventListener 'paste', pasteHandler, false

# This function does the AJAX request to the expander script and parses the
# received information
expandLink = (url) ->
  # initializes the XHR object
  xhr = new XMLHttpRequest

  # set the config options for the XHR
  xhr.open "GET", "expander.php?url=#{url}", true

  # onreadystatechange callback
  xhr.onreadystatechange = (e) ->
    if xhr.readyState == 4
      response = JSON.parse xhr.responseText

      expandedInfo = document.getElementsByClassName('expanded-info')[0]

      # Create the anchor item for the title
      link = document.createElement 'a'
      link.setAttribute 'href', url
      link.innerHTML = response.title

      # Create title div
      title = document.createElement 'div'
      title.setAttribute 'class', 'title'
      title.appendChild link

      # Create de title description
      description = document.createElement 'div'
      description.setAttribute 'class', 'description'
      description.innerHTML = response.description

      # Create the container for the images
      imagesDiv = document.createElement 'div'
      imagesDiv.setAttribute 'id', 'images'
      imagesDiv.setAttribute 'style', 'width:150px;overflow:hidden;float: right;'

      # loop the images array
      flag = 0
      for imageUrl in response.images
        image = document.createElement 'img'
        image.setAttribute 'src', imageUrl

        # checks if we are creating the first img element
        if flag++ != 0
          image.style.display = 'none'
          image.setAttribute 'class', 'image'
        else
          image.setAttribute 'class', 'active image'

        image.setAttribute 'id', "image#{flag}"

        imagesDiv.appendChild image

      # Creates the next image button
      nextImage = document.createElement 'div'
      nextImage.setAttribute 'class', 'arrow btn next-image'
      nextImage.innerHTML = '&rarr;'
      nextImage.onclick = nextImageClick

      # Creates the previous image button
      previousImage = document.createElement 'div'
      previousImage.setAttribute 'class', 'arrow btn previous-image'
      previousImage.innerHTML = '&larr;'
      previousImage.onclick = previousImageClick

      # Checks if we have images for displaying hte next and previous buttons
      if response.images.length > 0
        imagesDiv.appendChild previousImage
        imagesDiv.appendChild nextImage

      # Add all the previously created elements to the expanded info box
      expandedInfo.appendChild title
      expandedInfo.appendChild description
      expandedInfo.appendChild imagesDiv
      expandedInfo.style.display = 'block'

  # Performs the xhr
  xhr.send null

# Callback for the next image button
nextImageClick = (event) ->
  activeImage = document.getElementsByClassName('active').item(0)
  activeImageId = activeImage.id.charAt activeImage.id.length - 1

  nextImageId = "image" + (++activeImageId)

  nextImage = document.getElementById nextImageId

  if nextImage isnt null
    nextImage.setAttribute 'class', 'active image'
    nextImage.style.display = 'block'
    activeImage.setAttribute 'class', 'image'
    activeImage.style.display = 'none'
  @

# Callback for the previous image button
previousImageClick = (event) ->
  activeImage = document.getElementsByClassName('active').item(0)
  activeImageId = activeImage.id.charAt activeImage.id.length - 1

  previousImageId = "image" + (--activeImageId)

  previousImage = document.getElementById previousImageId

  if previousImage isnt null
    previousImage.setAttribute 'class', 'active image'
    previousImage.style.display = 'block'
    activeImage.setAttribute 'class', 'image'
    activeImage.style.display = 'none'
  @
