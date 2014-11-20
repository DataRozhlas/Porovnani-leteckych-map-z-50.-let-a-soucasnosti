window.ig.ShareDialog = class ShareDialog
  (@parentElement) ->
    @createShareArea!
    @createShareButton!
    @parentElement
      ..appendChild @shareBtn
      ..appendChild @shareArea
    ig.Events @
    @hash = ""

  createShareArea: ->
    @shareArea = document.createElement \div
      ..id = "shareArea"
      ..className = ''
      ..innerHTML = "Odkaz ke sdílení
      <a href='#' class='close'>Zavřít</a>
      <input type='text'>
      <a class='social' target='_blank' href='https://www.facebook.com/sharer/sharer.php?u='><img src='https://samizdat.cz/tools/icons/facebook.png' alt='Sdílet na Facebooku' /></a>
      <a class='social' target='_blank' href=''><img src='https://samizdat.cz/tools/icons/twitter.png' alt='Sdílet na Twitteru' /></a>
      "
    @shareArea.querySelector "a.close" .onclick = @~hideShareDialog

  createShareButton: ->
    @shareBtn = document.createElement \a
      ..innerHTML = "Sdílet toto místo"
      ..id = "shareBtn"
      ..onclick = (evt) ~>
        evt.preventDefault!
        @displayShareDialog!

  displayShareDialog: ->
    referrer = document.referrer || document.location.toString!
    referrer = referrer.split '#' .0
    @shareArea.className = "visible"
    @emit "hashRequested"
    ref = referrer
    ref += '#' + @hash if @hash
    refSoc = ref.replace '#' '%23'
    @shareArea.querySelector "input"
      ..value = ref
      ..focus!
      ..setSelectionRange 0, ref.length
    for elm, index in @shareArea.querySelectorAll ".social"
      elm.href = unless index
         "https://www.facebook.com/sharer/sharer.php?u=" + refSoc
      else
        "https://twitter.com/home?status=" + refSoc + " // @dataRozhlas"

  hideShareDialog: ->
    @shareArea.className = ""

  setHash: (@hash) ->
