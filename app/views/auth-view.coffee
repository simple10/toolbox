View = require 'views/base/view'
template = require 'views/templates/auth'

module.exports = class AuthView extends View
  autoRender: yes
  className: 'auth'
  region: 'auth'
  id: 'auth'
  template: template

  initialize: ->
    super
    @delegate('click', 'button.login', @login)

  login: ->
    debugger
