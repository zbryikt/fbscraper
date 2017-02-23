require! <[fs request bluebird fs-extra ./secret]>

fields = <[id]>

pageId = 387816094628136

get-token = -> new bluebird (res, rej) ->
  (e,r,b) <- request {
    url: "https://graph.facebook.com/oauth/access_token"
    method: \GET
    qs: {client_id: secret.id, client_secret: secret.secret} <<< {grant_type: "client_credentials"}
  }, _
  if e => return rej e
  res b

get-id-list = (token, pageId) -> new bluebird (res, rej) ->
  list = []
  get-ids = (url) -> new bluebird (res, rej) ->
    (e,r,b) <- request {url: url, method: \GET}
    if e => return rej!
    try
      obj = JSON.parse(b)
      res obj
    catch e
      rej e
  wrapper = (url) ->
    get-ids url
      .then (obj) ->
        list := list.concat obj.data.map(->it.id)
        console.log "#{list.length} fetched."
        if obj.paging and obj.paging.next => wrapper obj.paging.next
        else
          console.log obj
          res list
      .catch (e) -> rej e
  wrapper(
    "https://graph.facebook.com/#pageId/feed?" +
    ["limit=200","fields=#{fields.join(",")}",token].join(\&)
  )

get-articles = (token, list) ->
  get-item = (url) -> new bluebird (res, rej) ->
    (e,r,b) <- request {url: url, method: \GET}
    if e => return rej e
    res b
  get-items = ->
    console.log "remains: ", list.length
    if list.length == 0 => return res!
    item = list.splice(0, 1).0
    get-item "https://graph.facebook.com/#item"
      .then (str) ->
        str = unescape str.replace(
          /\\u([\d\w]{4})/gi
          (m, g) -> String.fromCharCode parseInt(g, 16)
        )
        fs.write-file-sync "item/#item", ret
        get-items!
      .catch -> rej!
  get-items!

token = null

get-token!
  .then (ret) ->
    token := ret
    get-id-list token, pageId
  .then (list) ->
    fs.write-file-sync \list.json, JSON.stringify(list)
    get-articles token, list
  .then -> console.log \done.
