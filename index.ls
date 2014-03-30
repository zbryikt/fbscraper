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
    template-url: '/loading.html'
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
          $scope.generate-download!

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
    $scope.start-get-wall = (is-me,scroll) ->
      if $scope.running => return
      if scroll => 
        des = ($(\#backup-btn)offset!top - 200)
        $(\body)scroll-to des, des, {queue: true}
      if is-me => $scope.is-fanpage = false
      if $scope.is-fanpage =>
        page-id = /https?:\/\/[^\/]+\/([^\/?]+)\??[^/]*/.exec $scope.fanpage
        if page-id => page-id = page-id.1
      else page-id = \me
      console.log page-id
      if page-id =>
        $scope.page-id = page-id
        $scope.running = true
        $scope.finish = false
        get-wall "https://graph.facebook.com/#{$scope.page-id}/feed?access_token=#{$scope.access-token}"
    $scope.generate-download = ->
      link-json = $(\#download-json)
      json-to-download = btoa unescape encodeURIComponent JSON.stringify $scope.wall
      link-json.attr \href, "data:application/octet-stream;charset=utf-8;base64,#{json-to-download}"
      link-html = $(\#download-html)
      content = "<html><head><meta charset='utf-8'>"
      content += "<link rel='stylesheet' type='text/css' href='http://zbryikt.github.io/fbscraper/index.css'></head><body>"
      content += $(\#posts)html! + "</body></html>"
      html-to-download = btoa unescape encodeURIComponent content
      link-html.attr \href, "data:application/octet-stream;charset=utf-8;base64,#{html-to-download}"
    attribution-data = [
      '<a href="http://thenounproject.com/term/click/39120/"</a>"Click", Ahmed Trochilidae, BY-CC 3.0'
      '<a href="http://thenounproject.com/term/book/5526/"</a>"Book", Olivier Guin, BY-CC 3.0'
      '<a href="http://thenounproject.com/term/cloud-download/18257/"</a>"Cloud Download", irene hoffman, BY-CC 3.0'
      '<a href="http://thenounproject.com/term/stone-wall/36294/"</a>"Stone Wall", Albert Vila, BY-CC 3.0'
      '<a href="http://thenounproject.com/term/scraper/25913/"</a>"Paint Scraper", factor[e] design initiative, BY-CC 3.0'
      '<a href="http://thenounproject.com/term/star/21280/"</a>"Star", Nick Abrams, BY-CC 3.0'
    ]
    $(\#attribution)popover do
      placement: \top
      html: \true
      title: "Attributions to Icons"
      content: attribution-data.join \<br>
    $(\#eula)popover do
      placement: \top
      html: \true
      title: "Term of Use"
      content: "Coming Soon"

    $(\#privacy)popover do
      placement: \top
      html: \true
      title: "Privacy Policy"
      content: "Coming Soon"

    $(\#about)popover do
      placement: \top
      html: \true
      title: "About Us"
      content: "Coming Soon"

