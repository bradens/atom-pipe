{Range} = require 'atom'
{spawn} = require 'child_process'
CommandView = require './command-view'

history = []

module.exports =
  activate: ->
    atom.workspaceView.command 'pipe:run', => @run()

  run: ->
    editor = atom.workspace.getActiveEditor()
    view = atom.workspaceView.getActiveView()
    return if not editor?

    new CommandView history, (commandString) ->
      if not commandString
        view.focus()
        return

      history.push commandString
      if history.length > 300
        history.shift()

      commandString = "cd '#{atom.project.rootDirectory.path}' && #{commandString}"
      properties = { reversed: true, invalidate: 'never' }

      for range in editor.getSelectedBufferRanges()
        marker = editor.markBufferRange range, properties
        processRange marker, editor, commandString

      view.focus()

processRange = (marker, editor, commandString) ->
  stdout = ''
  stderr = ''

  proc = spawn process.env.SHELL, ["-l", "-c", commandString]

  proc.stdout.on 'data', (text) ->
    stdout += text

  proc.stderr.on 'data', (text) ->
    stderr += text

  proc.on 'close', (code) ->
    text = stderr || stdout
    editor.setTextInBufferRange(marker.getBufferRange(), text)

  proc.stdin.write(editor.getTextInBufferRange(marker.getBufferRange()))
  proc.stdin.end()
