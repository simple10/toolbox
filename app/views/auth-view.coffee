View = require 'views/base/view'
template = require 'views/templates/auth'

module.exports = class AuthView extends View
  BASE_AUTH_URL: 'https://github.com/login/oauth/authorize'
  # Github app client id https://github.com/settings/applications
  CLIENT_ID: '72bffff9e7764cf8a202'
  # OAuth scopes http://developer.github.com/v3/oauth/#scopes
  SCOPE: 'public_repo'

  autoRender: yes
  className: 'auth'
  region: 'auth'
  id: 'auth'
  template: template
  token: null

  initialize: ->
    super
    # use delegate instead of backbone's events hash to better support class hierarchies
    @delegate('click', 'button', @onAuth)

  getTemplateData: ->
    @setToken()
    authed: !!@token

  onAuth: (evt) ->
    evt.preventDefault()
    if @token
      @logout()
    else
      @login()

  login: ->
    window.location = @getAuthURL()

  logout: ->
    localStorage.removeItem('oauth-token') if localStorage
    window.location.reload()

  setToken: ->
    @token = window.location.search.match(/([\?&])(code=([^&]+))/)
    if @token
      _.defer(@sanitizeURL, @token[1], @token[2])
      @token = @token[3]
      localStorage.setItem('oauth-token', @token) if localStorage
    else
      @token = localStorage.getItem('oauth-token') if localStorage

  getAuthURL: ->
    # todo: add state param to prevent CSRF
    @BASE_AUTH_URL +
      "?client_id=#{@CLIENT_ID}" +
      "&redirect_uri=#{@getRedirectURL()}" +
      "&scope=#{@SCOPE}"

  getRedirectURL: ->
    encodeURIComponent(window.location.href)

  sanitizeURL: (separator, remove) ->
    return false unless Backbone.history._hasPushState
    remove = "&#{remove}" if separator == '&'
    frag = window.location.search.replace(remove, '')
    frag = '' if frag == '?'
    frag = window.location.pathname + frag
    Backbone.history.history.replaceState({}, document.title, frag)
