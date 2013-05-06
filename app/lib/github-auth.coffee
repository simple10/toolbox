# Helper class for authenticating via Github OAuth

module.exports = class GithubAuth
  BASE_AUTH_URL: 'https://github.com/login/oauth/authorize'
  LS_TOKEN_KEY: 'oauth-token'
  @token = null

  initialize: (options) ->
    _.defaults options,
      oauth_client_id: null
      oauth_scope: 'public_repo'
      sanitize_url: true
      token: null

    token = options.token
    @options = _.omit(options, 'token')

    token ||= window.location.search.match(/([\?&])(code=([^&]+))/)
    if _.isArray(token)
      _.defer(@sanitizeURL, token[1], token[2]) if @options.sanitize_url
      token = token[3]
    token ||= localStorage.getItem(@LS_TOKEN_KEY) if localStorage

    @login(token)
    this

  authURL: ->
    # todo: add state param to prevent CSRF
    @BASE_AUTH_URL +
      "?client_id=#{@options.oauth_client_id}" +
      "&redirect_uri=#{@redirectURL()}" +
      "&scope=#{@options.oauth_scope}"

  redirectURL: ->
    encodeURIComponent(window.location.href)

  isAuthenticated: ->
    !!@token

  login: (token) ->
    @token = token
    localStorage.setItem(@LS_TOKEN_KEY, token) if localStorage

  logout: ->
    @token = null
    localStorage.removeItem(@LS_TOKEN_KEY) if localStorage

  sanitizeURL: (separator, remove) ->
    return false unless Backbone && Backbone.history._hasPushState
    remove = "&#{remove}" if separator == '&'
    frag = window.location.search.replace(remove, '')
    frag = '' if frag == '?'
    frag = window.location.pathname + frag
    Backbone.history.history.replaceState({}, document.title, frag)
