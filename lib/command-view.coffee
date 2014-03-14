{View, EditorView} = require 'atom'

module.exports =
class CommandView extends View
  @placeholders: [
    'sort -n'
    'tac'
    'sed \'s/^/\\/\\//g\''
    'grep foo'
    'tee ~/temp.txt'
  ]

  @content: ->
    @div class: 'pipe-command', =>
      @subview 'commandLine', new EditorView(
        mini: true
        placeholderText: @samplePlaceholder()
      )

  @samplePlaceholder: ->
    @placeholders[Math.floor(Math.random()*@placeholders.length)]

  initialize: (callback) ->
    @on 'core:cancel core:close', =>
      callback(null)
      @detach()
    @on 'core:confirm', =>
      callback(@commandLine.getText())
      @detach()

    atom.workspaceView.append(this)
    @commandLine.focus()
