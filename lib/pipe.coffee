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

      range = editor.getSelectedBufferRange()
      stdout = ''
      stderr = ''

      commandString = "cd #{atom.project.path} && #{commandString}"
      proc = spawn process.env.SHELL, ["-l", "-c", commandString]

      proc.stdout.on 'data', (text) ->
        stdout += text

      proc.stderr.on 'data', (text) ->
        stderr += text

      proc.on 'close', (code) ->
        editor.setTextInBufferRange(range, stderr || stdout)
        editor.setSelectedBufferRange(new Range(range.start, range.start))
        view.focus()

      proc.stdin.write(editor.getSelectedText())
      proc.stdin.end()
