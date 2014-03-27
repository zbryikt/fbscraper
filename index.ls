main = ($scope, $http) ->
  uid = ""
  accessToken = ""
  $scope.wall = []
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
        {uid,accessToken} := res.auth-response{userID, accessToken}
        console.log access-token
      else
        console.log "please login"

  get-wall = (url) ->
    $http.get url .success (data) ->
      console.log data
      console.log data.paging.next
      $scope.wall ++= data.data
      if data.paging and data.paging.next => set-timeout (-> get-wall data.paging.next), 100

  $ \#FBLogin .click ->
    FB.login (-> 
      get-access-token!  
    ), {scope: ""}

  get-access-token!
  $ \#show .click ->
    get-wall "https://graph.facebook.com/NtuNewsEForum/feed?access_token=#{access-token}"
