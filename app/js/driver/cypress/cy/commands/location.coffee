$Cypress.register "Location", (Cypress, _, $) ->

  Cypress.Cy.extend
    _getLocation: (key) ->
      remoteUrl = @private("window").location.toString()
      location  = Cypress.Location.create(remoteUrl)

      if key
        location[key]
      else
        location

  Cypress.addParentCommand
    url: (options = {}) ->
      _.defaults options, {log: true}

      if options.log isnt false
        options._log = Cypress.Log.command
          message: ""

      getHref = =>
        @_getLocation("href")

      do resolveHref = =>
        Promise.try(getHref).then (href) =>
          @verifyUpcomingAssertions(href, options, {
            onRetry: resolveHref
          })

    hash: (options = {}) ->
      _.defaults options, {log: true}

      if options.log isnt false
        options._log = Cypress.Log.command
          message: ""

      getHash = =>
        @_getLocation("hash")

      do resolveHash = =>
        Promise.try(getHash).then (hash) =>
          @verifyUpcomingAssertions(hash, options, {
            onRetry: resolveHash
          })

    location: (key, options) ->
      ## normalize arguments allowing key + options to be undefined
      ## key can represent the options
      if _.isObject(key) and _.isUndefined(options)
        options = key

      options ?= {}

      _.defaults options, {log: true}

      getLocation = =>
        location = @_getLocation()

        ret = if _.isString(key)
          ## use existential here because we only want to throw
          ## on null or undefined values (and not empty strings)
          location[key] ?
            $Cypress.Utils.throwErrByPath("location.invalid_key", { args: { key } })
        else
          location

      if options.log isnt false
        options._log = Cypress.Log.command
          message: key ? ""

      do resolveLocation = =>
        Promise.try(getLocation).then (ret) =>
          @verifyUpcomingAssertions(ret, options, {
            onRetry: resolveLocation
          })
