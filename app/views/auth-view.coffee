View = require 'views/base/view'
template = require 'views/templates/auth'
Auth = require 'lib/github-auth'
Config = require 'config'

module.exports = class AuthView extends View
  autoRender: yes
  className: 'auth'
  region: 'auth'
  id: 'auth'
  template: template

  initialize: ->
    super
    @delegate('click', 'button', @onAuth)
    @auth = (new Auth).initialize(Config)

  login: ->
    window.location = @auth.authURL()

  logout: ->
    @auth.logout()
    window.location.reload()

  onAuth: (evt) ->
    evt.preventDefault()
    if @auth.isAuthenticated()
      @logout()
    else
      @login()

  getTemplateData: ->
    authed: @auth.isAuthenticated()
