# this transforms a Behavior class into an Elemental-ready function
App.registerBehavior = (behaviorName) ->
  App[behaviorName] = (domElement) ->
    new Behavior[behaviorName](domElement)
