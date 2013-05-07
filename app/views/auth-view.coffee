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

  render: ->
    super
    if @auth.isLoading()
      $button = @$('button').addClass('loading')
      @spinner = new Spinner(@spinnerOptions()).spin($button.parent()[0])
    this

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

  spinnerOptions: ->
    lines: 9 # The number of lines to draw
    length: 4 # The length of each line
    width: 2 # The line thickness
    radius: 3 # The radius of the inner circle
    corners: 1 # Corner roundness (0..1)
    rotate: 0 # The rotation offset
    direction: 1 # 1: clockwise, -1: counterclockwise
    color: '#000' # #rgb or #rrggbb
    speed: 2 # Rounds per second
    trail: 40 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: true # Whether to use hardware acceleration
    className: 'spinner' # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)
    top: '3' # Top position relative to parent in px
    left: '25' # Left position relative to parent in px
