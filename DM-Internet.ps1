# Function: Get-DMUrlFromShortUrl
# Purpose:  Resolve full URL from short URL
# Usage:    $resolvedUrl = Get-DMUrlFromShortUrl -url "https://dm.wtf/test"
Function Get-DMUrlFromShortUrl ($url) {
    (((Invoke-WebRequest -UseBasicParsing –Uri $url).baseresponse).ResponseUri).AbsoluteUri
}