#= require trix/elements/trix_toolbar_element
#= require trix/elements/trix_document_element
#= require trix/controllers/editor_controller
#= require trix/controllers/editor_element_controller

{makeElement} = Trix

Trix.defineElement class extends Trix.Element
  @tagName: "trix-editor"

  attachedCallback: ->
    super

    unless contentType = @getAttribute("content-type")
      contentType = "text/html"
      @setAttribute("content-type", contentType)

    toolbarElement = findOrCreateToolbarElement(this)
    documentElement = findOrCreateDocumentElement(this)
    inputElement = findOrCreateInputElement(this)

    @editorController ?= new Trix.EditorController
      toolbarElement: toolbarElement
      documentElement: documentElement
      document: Trix.deserializeFromContentType(inputElement.value, contentType)
      delegate: new Trix.EditorElementController this, documentElement, inputElement

    @editorController.registerSelectionManager()

  detachedCallback: ->
    super
    @editorController.unregisterSelectionManager()

  findOrCreateToolbarElement = (parentElement) ->
    unless element = parentElement.querySelector("trix-toolbar")
      element = makeElement("trix-toolbar")
      parentElement.insertBefore(element, parentElement.firstChild)
    element

  findOrCreateDocumentElement = (parentElement) ->
    unless element = parentElement.querySelector("trix-document")
      placeholder = parentElement.getAttribute("placeholder")
      element = makeElement("trix-document", {placeholder})
      if parentElement.hasAttribute("autofocus")
        parentElement.removeAttribute("autofocus")
        element.setAttribute("autofocus", "")
      parentElement.insertBefore(element, null)
    element

  findOrCreateInputElement = (parentElement) ->
    unless element = parentElement.querySelector("input[type=hidden]")
      name = parentElement.getAttribute("name")
      value = parentElement.getAttribute("value")
      element = makeElement("input", type: "hidden")
      element.name = name if name?
      element.value = value if value?
      parentElement.insertBefore(element, null)
    element
