angular.module \core, <[ngAnimate]>
  ..directive \delayBk, -> do
    restrict: \A
    link: (scope, e, attrs, ctrl) ->
      url = attrs["delayBk"]
      $ \<img/> .attr \src url .load ->
        $(@)remove!
        e.css background: "url(#url)"
        e.toggle-class \visible
  ..directive \loading, -> do
    restrict: \E
    template: '<div class="bubblingG"><span class="bubblingG_1"></span><span class="bubblingG_2"></span><span class="bubblingG_3"></span></div>'
    link: (scope, e, attrs, ctrl) ->
  ..controller \main, <[$scope $interval $http]> ++ ($scope, $interval, $http) ->
    $scope.uid = ""
    $scope.username = ""
    $scope.fanpage = ""
    $scope.is-fanpage = false
    $scope.accessToken = ""
    $scope.loading = false
    $scope.wall = []
    $scope.page-id = \NtuNewsEForum
    $scope.running = false
    $scope.finish = false
    FB.init do
      appId: "1490131354539691"
      status: true
      cookie: true
      xfbml: true
      oauth: true

    get-access-token = ->
      console.log "get login status..."
      $scope.loading = true
      FB.get-login-status (res) ->
        console.log "response..."
        if res.status == "connected" =>
          console.log res
          {userID,accessToken} = res.auth-response{userID, accessToken}
          $scope.$apply ->
            $scope.uid = userID
            $scope.access-token = access-token
            console.log $scope.uid
          $http.get "http://graph.facebook.com/#{$scope.uid}/profile" .success (data) ->
            if data.data and data.data.0 => $scope.username = data.data.0.name
        else
          console.log "please login"
        $scope.$apply -> $scope.loading = false

    get-wall = (url) ->
      $http.get url .success (data) ->
        console.log data
        $scope.wall ++= data.data
        if data.paging and data.paging.next => 
          set-timeout (-> get-wall data.paging.next), 100
        else
          $scope.finish = true
          $scope.running = false

    $scope.enlarge = -> if it => it.to-string!replace /_s\./, "_n."
    $scope.set-fanpage = -> $scope.is-fanpage = it
    $scope.logout = -> if $scope.access-token => FB.logout ->
      $scope.username = ""
      $scope.access-token = ""
      $scope.loading = false
      $scope.running = false
    $scope.login = ->
      FB.login (-> 
        get-access-token!  
      ), {scope: ""}

    get-access-token!
    $scope.start-get-wall = (is-me) ->
      if is-me => $scope.is-fanpage = false
      if $scope.is-fanpage =>
        page-id = /https?:\/\/[^\/]+\/([^\/?]+)\??[^/]*/.exec $scope.fanpage
        if page-id => page-id = page-id.1
      else page-id = \me
      console.log page-id
      if page-id =>
        $scope.page-id = page-id
        $scope.running = true
        get-wall "https://graph.facebook.com/#{$scope.page-id}/feed?access_token=#{$scope.access-token}"
