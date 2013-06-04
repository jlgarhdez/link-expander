###
# @author jlgarhdez <jlgarcia.me>
###

textarea = document.getElementById 'textarea'

pasteHandler = (event) ->
  pattern = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!-\/]))?/
  data = event.clipboardData.getData 'text/plain'
  if pattern.test data
    expandLink data
  @

textarea.addEventListener 'paste', pasteHandler, false
#
submitButton = document.getElementById 'submit'
submitButton.onclick = () ->
  expandLink 'http://jlgarcia.me'

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

      expandedInfo.appendChild title
      expandedInfo.appendChild description
      expandedInfo.style.display = 'block'

  xhr.send null


console.log typeof submitButton
