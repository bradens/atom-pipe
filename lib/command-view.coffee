{View, TextEditorView} = require 'atom-space-pen-views'


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
      @subview 'commandLine', new TextEditorView(
        mini: true
        placeholderText: @samplePlaceholder()
      )

  @samplePlaceholder: ->
    @placeholders[Math.floor(Math.random()*@placeholders.length)]

  initialize: (history, callback) ->
    historyPos = history.length
    cur = ''

    @on 'core:cancel core:close', =>
      callback(null)
      @detach()
    @on 'core:confirm', =>
      callback(@commandLine.getText())
      @detach()
    @commandLine.on 'keydown', (e) =>
      if history.length is 0 then return

      switch e.keyCode
        when 38 # up
          unless historyPos <= 0
            historyPos--
            @commandLine.setText history[historyPos]

        when 40 # down
          if historyPos >= history.length-1
            historyPos = history.length
            @commandLine.setText cur
          else
            historyPos++
            @commandLine.setText history[historyPos]

        else
          if historyPos >= history.length
            cur = @commandLine.getText()

    atom.workspaceView.append(this)
    @commandLine.focus()
