window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function TrackResults ($module) {
    this.$module = $module
    this.flowName = this.$module.getAttribute('data-flow-name')
    this.page = document.location.pathname
  }

  TrackResults.prototype.init = function () {
    this.trackCompletedFlow()
    this.trackInternalLinks()
  }

  TrackResults.prototype.trackCompletedFlow = function () {
    var options = {
      label: this.flowName,
      nonInteraction: true,
      page: this.page
    }
    GOVUK.analytics.trackEvent('Smart Answer', 'Completed', options)
  }

  TrackResults.prototype.trackInternalLinks = function () {
    var currentHost = document.location.protocol + '//' + document.location.hostname
    var internalLinkSelector = 'a[href^="' + currentHost + '"], a[href^="/"]'
    var internalResultLinks = document.querySelectorAll(internalLinkSelector)

    for (var i = 0; i < internalResultLinks.length; i++) {
      internalResultLinks[i].addEventListener('click', this.trackClickEvent.bind(this))
    }
  }

  TrackResults.prototype.trackClickEvent = function (event) {
    var $link = event.target
    var options = { transport: 'beacon' }
    var href = $link.getAttribute('href')
    var linkText = $link.innerText.trim()

    if (linkText) {
      options.label = linkText
    }
    GOVUK.analytics.trackEvent('Internal Link Clicked', href, options)
  }

  Modules.TrackResults = TrackResults
})(window.GOVUK.Modules)
