{Range} = require 'atom'
{spawn} = require 'child_process'
CommandView = require './command-view'

module.exports =
  activate: ->
    atom.workspaceView.command 'pipe:run', => @run()

  run: ->
    editor = atom.workspace.getActiveEditor()
    view = atom.workspaceView.getActiveView()
    return if not editor?

    new CommandView (commandString) ->
      if not commandString
        view.focus()
        return

      range = editor.getSelectedBufferRange()
      stdout = ''
      stderr = ''

      proc = spawn process.env.SHELL, ["-l", "-c", commandString]

      proc.stdout.on 'data', (text) ->
        stdout += text

      proc.stderr.on 'data', (text) ->
        stderr += text

      proc.on 'close', (code) ->
        text = stderr || stdout
        if not text then return

        if text.slice(-1) is '\n'
          text = text.slice(0, -1)

        editor.setTextInBufferRange(range, text)
        editor.setSelectedBufferRange(new Range(range.start, range.start))
        view.focus()

      proc.stdin.write(editor.getSelectedText())
      proc.stdin.end()
