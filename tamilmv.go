package main


import (
	"fmt"
	"os"
	"net/http"
//	"net/url"
	"encoding/json"
	"strconv"

	"./pup"
	"github.com/fatih/color"
)
type TamilMV struct {
	SearchResults []struct {
		Href string `json:"href"`
		Text string `json:"text"`
	}

	DownloadResults []struct {
		Href string `json:"href"`
	}

}

var (
	searchURL string = "https://www.tamilmv.cz/index.php?/search/"
	TAMILMV = TamilMV{}
)

func SearchTamilMovies(query string){
	//resp,err := http.PostForm(searchURL,url.Values{"type":{"all"},"q":{query}})
	resp,err := http.Get(searchURL+"&q="+UrlEncoded(query)+"&nodes=1,2,3")
	if err != nil {
		onHttpError(err)
	}
	os.Args = []string{
		"anbuksv",
		"li.ipsStreamItem > div > div > div > h2 > div > a json{}",
	}
	searchResultNodes := pup.Run(resp.Body)
	json.Unmarshal(searchResultNodes,&TAMILMV.SearchResults)
	moviesResultCheck(len(TAMILMV.SearchResults))
	fmt.Printf("%s",listTamilMVMovies())
	downloadIndex := getConformation(len(TAMILMV.SearchResults))
	torrentHtml := downloadHTML(TAMILMV.SearchResults[downloadIndex].Href)
	os.Args = []string{
		"anbuksv",
		".ipsAttachLink json{}",
	}
	torrentHtmlNode := pup.Run(torrentHtml)
	json.Unmarshal(torrentHtmlNode,&TAMILMV.DownloadResults)
	color.Set(color.FgYellow, color.Bold)
	if len(TAMILMV.DownloadResults) > 0 {
		fmt.Println(TAMILMV.DownloadResults[0].Href)
	} else {
		fmt.Println("Sorry,We are unable to process your request")
	}
	color.Unset()
}

func listTamilMVMovies() string {
	var _movies string = ""
	for index,movie := range(TAMILMV.SearchResults){
		_movies = _movies + strconv.Itoa(index+1) + ". " + movie.Text+ "\n"
	}
	return _movies
}
