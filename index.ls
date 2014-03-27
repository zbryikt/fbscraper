main = ($scope, $http) ->
  uid = ""
  $scope.accessToken = ""
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
    FB.get-login-status (res) ->
      console.log "response..."
      if res.status == "connected" =>
        {uid,accessToken} = res.auth-response{userID, accessToken}
        $scope.$apply -> $scope.access-token = access-token
        console.log access-token
      else
        console.log "please login"

  get-wall = (url) ->
    $http.get url .success (data) ->
      console.log data
      console.log data.paging.next
      $scope.wall ++= data.data
      if data.paging and data.paging.next => 
        set-timeout (-> get-wall data.paging.next), 100
      else
        $scope.finish = true
        $scope.running = false

  $ \#FBLogin .click ->
    FB.login (-> 
      get-access-token!  
    ), {scope: ""}

  get-access-token!
  $ \#show .click ->
    $scope.running = true
    get-wall "https://graph.facebook.com/#{$scope.page-id}/feed?access_token=#{$scope.access-token}"
