###*
* @author José Luis García <jlgarcia.me>
* @license MIT
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
  xhr = new XMLHttpRequest
  xhr.open "GET", "expander.php?url=#{url}", true
  xhr.onreadystatechange = (e) ->
    if xhr.readyState == 4
      response = JSON.parse xhr.responseText

      expandedInfo = document.getElementsByClassName('expanded-info')[0]

      link = document.createElement 'a'
      link.setAttribute 'href', url
      link.innerHTML = response.title

      title = document.createElement 'div'
      title.setAttribute 'class', 'title'
      title.appendChild link

      description = document.createElement 'div'
      description.setAttribute 'class', 'description'
      description.innerHTML = response.description

      imagesDiv = document.createElement 'div'
      imagesDiv.setAttribute 'id', 'images'
      imagesDiv.setAttribute 'style', 'width:150px;overflow:hidden;float: right;'

      flag = 0
      # loop the images array
      for imageUrl in response.images
        image = document.createElement 'img'
        image.setAttribute 'src', imageUrl

        if flag != 0
          image.style.display = 'none'
          image.setAttribute 'class', 'image'
        else
          image.setAttribute 'class', 'active image'

        image.setAttribute 'id', "image#{flag}"

        imagesDiv.appendChild image

        flag++

      nextImage = document.createElement 'div'
      nextImage.setAttribute 'class', 'arrow btn next-image'
      nextImage.innerHTML = '&rarr;'
      nextImage.onclick = nextImageClick

      previousImage = document.createElement 'div'
      previousImage.setAttribute 'class', 'arrow btn previous-image'
      previousImage.innerHTML = '&larr;'
      previousImage.onclick = previousImageClick

      imagesDiv.appendChild previousImage
      imagesDiv.appendChild nextImage

      expandedInfo.appendChild title
      expandedInfo.appendChild description
      expandedInfo.appendChild imagesDiv
      expandedInfo.style.display = 'block'

  xhr.send null

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
