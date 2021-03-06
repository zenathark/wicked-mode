# state.coffee --- Contains the base class of a *MODE*
# Author: Zenathark
# Mantainer: Zenathark
#
# Version 0.0.1
# Date 2015-11-19
#
# As with vim and emacs, wicked-mode defines *modes* of operation for
# the atom editor. Each mode has its own properies and behavior.
# Also, keybindings must be defined for each mode.

_ = require 'underscore-plus'
name = 'wicked:mode'
log = require('./logger') name
assert = require('chai').assert
# localStorage.debug = '*'
  # debug = require('debug')
  # debug.disable('test')
  # log = debug('test')
  # log.log = console.error.bind(console)


module.exports =
  # Base class for modes
  #
  # This is the base class for all modes of wicked-mode. This class is
  # heavily inspired on the evil-define-macro of evil-mode for emacs.
  #
  # Properties:
  #   * `tag` Mode status line indicator
  #   * `message` Echo message when changing to mode
  #   * `cursor` Type of cursor for mode
  #   * `entry_hook` Functions to run when activating mode
  #   * `exit_hook` Functions to run when deactivating mode
  #   * `enable` Modes to enable when mode is enable
  #
  # Methods:
  #   * `activateMode` Activate this mode
  #   * `deactivateMode` Deactivate this mode
  #   * `activate` If presents, the method is invoked when activating
  #     mode
  #   * `deactivate` If presents, the method is invoked when
  #     deactivating mode
  #   * `addEntryHook` Adds a function to the entry hooks
  #   * `addExitHook` Adds a function to the exit hooks
  #   * `addAllEntryHooks` Adds a list of functions to the entry hook
  #   * `addAllExitHooks` Adds a list of functions to the exit hook
  #   * `addEnable` Adds a mode to enable
  #   * `addAllEnable` Adds a list of modes to enable
  #
  #
  # When mode is activate through `activateMode`, all functions in
  # entry-hook are invoked. Also, each mode listed in `enable` is also
  # activated in order.
  # Because each mode in `enable` is activated before this mode, any
  # changes made by the extra mode in `enable` can be potentially overwrited
  # by this mode.
  # When mode is deactivate through `deactivateMode`, all functions in
  # exit-hook are invoked and all modes in `enable` are deactivated in
  # order.
  class Mode
    tag:        null
    message:    null
    cursor:     null
    entry_hook: null
    exit_hook:  null
    enable:     null
    selector:   null

    constructor: (@selector, @tag='', @message='', @cursor='.block') ->
      @entry_hook = new Set
      @exit_hook  = new Set
      @enable     = new Set

    activateMode: (editor) ->
      log "Activate called"
      assert.ok(editor, 'editor is empty')
      editor_view = atom.views.getView editor
      editor_view.classList.add @selector
      @activate editor if @activate?
      @entry_hook.forEach (hook) => hook.call this
      @enable.forEach (extra) -> extra.activateMode editor

    deactivateMode: (editor) ->
      log "Activate called"
      assert.ok(editor, 'editor is empty')
      editor_view = atom.views.getView(editor)
      editor_view.classList.remove @selector
      @deactivate editor if @deactivate?
      @exit_hook.forEach (hook) => hook.call this
      @enable.forEach (extra) -> extra.deactivateMode editor

    addEntryHook: (f) ->
      log "Added entry hook #{f}"
      @entry_hook.add f

    addExitHook: (f) ->
      log "Added exit hook #{f}"
      @exit_hook.add f

    addAllEntryHooks: (fs) ->
      log " Added multiple entry hooks #{fs}"
      fs.forEach (i) => @addEntryHook i

    addAllExitHooks: (fs) ->
      log "Added multiple exit hooks #{fs}"
      fs.forEach (i) => @addExitHook i

    addEnable: (f) ->
      log "Added mode #{f} to extra enable modes"
      @enable.add f
