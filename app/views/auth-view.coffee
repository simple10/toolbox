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
    options = _.extend({}, Config, onchange: => @render())
    @auth = (new Auth).initialize(options)

  login: ->
    window.location = @auth.authURL()

  logout: ->
    @auth.logout()
    window.location.reload()

  onAuth: (evt) ->
    evt.preventDefault() if evt
    if @auth.isAuthenticated()
      @logout()
    else
      @login()

  getTemplateData: ->
    authed: @auth.isAuthenticated() || @auth.isLoading()
    loading: @auth.isLoading()
