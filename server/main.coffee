jsonpHead = 
  "Content-type": "application/javascript;charset=utf-8"
  "Cache-Control": "must-revalidate, max-age=1"

btoa = (str) ->
  buffer = undefined
  if str instanceof Buffer
    buffer = str
  else
    buffer = new Buffer(str.toString(), "binary")
  buffer.toString "base64"

getCounts = (network, callback, val1, val2) ->
  debugNetwork = "-"
  try
    settings = switch network
      when "bitcoin" #JSON to JSONP - No API with JSONP found
        url: "https://blockchain.info/address/#{val1}?format=json"
      when "stumbleupon" #JSON to JSONP - No API with JSONP found
        url: "http://www.stumbleupon.com/services/1.01/badge.getinfo?url=#{val1}"
      when "githubProfile" # serverside caused by clientSecret
        url: "https://api.github.com/users/#{val1}?client_id=50c2e06ef26d78601337&client_secret=20b87f9f28b3c605087db311968cde67fa6e979c"
      when "githubRepository" # serverside caused by clientSecret
        url: "https://api.github.com/repos/#{val1}/#{val2}?client_id=50c2e06ef26d78601337&client_secret=20b87f9f28b3c605087db311968cde67fa6e979c"
      when "twitterProfile" #Scraping - No API without API-Key
        timestamp = ~~(+new Date() / 1000)
        screenName = encodeURIComponent val1
        consumerKey = encodeURIComponent "ujSWbQ7XE7rQKBt4f7mQ"
        consumerSecret = encodeURIComponent "8O6VIniFBRbvjTxEEBLXDlpdTiUe0ymf5tG09V2AifE"
        accessToken = encodeURIComponent "1117398733-N7G2I1bxGtLu7i4Lb83RacLVgmbMkpeMj1HOm6b"
        accessTokenSecret = encodeURIComponent "QWLwl6Dc9CX3BnnAbLrINV4HkzNcl4Z4K1Xx8SSEWLgIa"
        signingBase = "GET&https%3A%2F%2Fapi.twitter.com%2F1.1%2Fusers%2Fshow.json&oauth_consumer_key%3DujSWbQ7XE7rQKBt4f7mQ%26oauth_nonce%3D71e808885f3038baee59b85f6eb0730a%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D#{timestamp}%26oauth_token%3D1117398733-N7G2I1bxGtLu7i4Lb83RacLVgmbMkpeMj1HOm6b%26oauth_version%3D1.0%26screen_name%3D#{screenName}"
        signingKey = "#{consumerSecret}&#{accessTokenSecret}"
        signingString = encodeURIComponent CryptoJS.enc.Base64.stringify(CryptoJS.HmacSHA1(signingBase, signingKey))
        url: "https://api.twitter.com/1.1/users/show.json?screen_name=#{screenName}" #Scraping - No API found
        options:
          headers:
            Authorization: """
              OAuth oauth_consumer_key="ujSWbQ7XE7rQKBt4f7mQ", oauth_nonce="71e808885f3038baee59b85f6eb0730a", oauth_signature="#{signingString}", oauth_signature_method="HMAC-SHA1", oauth_timestamp="#{timestamp}", oauth_token="1117398733-N7G2I1bxGtLu7i4Lb83RacLVgmbMkpeMj1HOm6b", oauth_version="1.0"
            """
      when "pinterestPins" #Scraping - No official API
        url: "http://www.pinterest.com/#{val1}"
        regexp: /pinterestapp:pins.*?([\d]+)/
      when "pinterestFollower" #Scraping - No official API
        url: "http://www.pinterest.com/#{val1}"
        regexp: /pinterestapp:followers.*?([\d]+)/
      when "instagram"
        url: "http://instagram.com/#{val1}"
        regexp: /followed_by.*?([\d]+)/
      when "googleplus" #Scraping - No API without API-Key
        url: "https://plusone.google.com/_/+1/fastbutton?url=#{val1}"
        regexp: /window\.__SSR = {c: ([\d]+)/
      when "buffer" #Scraping - No API without API-Key
        url: "http://widgets.bufferapp.com/button/?id=0d98d3d464f640bd&url=#{val1}&count=vertical&placement=button"
        regexp: /id="buffer_count">([\d]+)/
      when "flattr" #Scraping - No Client JSONP API found
        url: "http://api.flattr.com/button/view/?url=#{val1}"
        regexp: /flattr-count"><span>([\d]+)/
      when "pocket" #Scraping - No API without Key found
        url: "https://widgets.getpocket.com/v1/button?label=pocket&count=vertical&url=#{val1}"
        regexp: /id="cnt">([\d]+)/
      when "codepenProfile" #Scraping - No API found
        url: "http://codepen.io/#{val1}"
        regexp: new RegExp "href=\"/#{val1}/followers\">\\n? *?<strong>([\\d]+)"
      when "codepenPen"
        url: "http://codepen.io/#{val1}/details/#{val2}"
        regexp: /<strong>([\d]+)<\/strong>\n *?Heart/
      when "xing" #Scraping - No Client JSONP API found - counts with letters (eg. 2k) wont work
        url: "https://www.xing-share.com/app/share?op=get_share_button;url=#{val1};counter=top;lang=en;type=iframe;hovercard_position=2;shape=rectangle"
        regexp: /xing-count top">([\d]+)/
      when "hackernews" #JSON to JSONP - No (working, keyless) API with JSONP found
        url: "https://news.ycombinator.com/item?id=#{val1}"
        regexp: new RegExp "id=score_#{val1}>([\\d]+)"
      when "surfingbird"
        url: "http://surfingbird.ru/fix/parsing/#{val1}"
        regexp: /likers-count">([\d]+)/
      when "litecoin" #Scraping - No API with JSON found
        url: "http://explorer.litecoin.net/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "feathercoin" #Scraping - No API with JSON found
        url: "http://explorer.feathercoin.com/address/#{val1}"
        regexp: /Transactions in:<\/th><td>([\d]+)/
      when "freicoin" #Scraping - No API with JSON found
        url: "http://frc.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "terracoin" #Scraping - No API with JSON found
        url: "http://trc.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "peercoin" #Scraping - No API with JSON found
        url: "http://ppc.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "novacoin" #Scraping - No API with JSON found
        url: "http://nvc.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "bbqcoin" #Scraping - No API with JSON found
        url: "http://bbq.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "bytecoin" #Scraping - No API with JSON found
        url: "http://bte.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "bitbar" #Scraping - No API with JSON found
        url: "http://btb.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "digitalcoin" #Scraping - No API with JSON found
        url: "http://dgc.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "jkcoin" #Scraping - No API with JSON found
        url: "http://jkc.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "frankos" #Scraping - No API with JSON found
        url: "http://frk.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "goldcoin" #Scraping - No API with JSON found
        url: "http://gld.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "worldcoin" #Scraping - No API with JSON found
        url: "http://wdc.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "craftcoin" #Scraping - No API with JSON found
        url: "http://crc.cryptocoinexplorer.com/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      when "quarkcoin" #Scraping - No API with JSON found
        url: "http://block.lowend.fm/address/#{val1}"
        regexp: /Transactions in: ([\d]+)/
      else {}
    options = settings.options or {}
    options.headers ||= {}
    options.headers["User-Agent"] = "Meteor/1.0 (http://getshar.es)" 
    if settings.regexp?
      res = HTTP.get settings.url, options
      if network is debugNetwork
        console.log settings
        console.log res.content
      return [
        200
        jsonpHead
        """
          #{callback}(
            #{JSON.stringify(settings.regexp.exec(res.content)[1])}
          );
        """
      ]
    else
      res = HTTP.get settings.url, options
      if network is debugNetwork
        console.log settings
        console.log res
      return [
        200
        jsonpHead
        """
          #{callback}(
            #{res.content}
          );
        """
      ]
  catch error
    if network is debugNetwork
      console.log settings
      console.log error.stack
    return [
      200
      jsonpHead
      "#{callback}(0);"
    ]

Meteor.Router.add "/counts/:network/:val1"      , "GET", (network, val1      ) -> getCounts network, (@request?.query?.callback || "console.log"), val1
Meteor.Router.add "/counts/:network/:val1/:val2", "GET", (network, val1, val2) -> getCounts network, (@request?.query?.callback || "console.log"), val1, val2
