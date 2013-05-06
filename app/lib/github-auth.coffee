# Helper class for authenticating via Github OAuth

module.exports = class GithubAuth
  BASE_AUTH_URL: 'https://github.com/login/oauth/authorize'
  LS_TOKEN_KEY: 'github-oauth-token'
  @token = null

  initialize: (options) ->
    _.defaults options,
      oauth_client_id: null
      oauth_scope: 'public_repo'
      sanitize_url: true
      oauth_gatekeeper: null
      onchange: null
      token: null
      code: null

    token = options.token
    code = options.code
    @options = _.omit(options, 'token', 'code')

    code ||= @checkForCode()
    if code && !token
      @exchangeForToken(code)
    else
      token ||= localStorage.getItem(@LS_TOKEN_KEY) if localStorage

    @login(token)
    this

  checkForCode: ->
    code = window.location.search.match(/([\?&])(code=([^&]+))/)
    if _.isArray(code)
      _.defer(@sanitizeURL, code[1], code[2]) if @options.sanitize_url
      code[3]
    else
      null

  exchangeForToken: (code) ->
    $.getJSON @options.oauth_gatekeeper + code, (data) =>
      @login(data.token)
      if _.isFunction(@options.onchange)
        @options.onchange()

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
    return unless localStorage
    if token
      localStorage.setItem(@LS_TOKEN_KEY, token)
    else
      @logout()

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
