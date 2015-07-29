/// 七牛客户端

package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"golang.org/x/net/context"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"qiniupkg.com/api.v7/kodocli"
)

const (
	UPTOKEN_URL = "http://qiniu-manager.herokuapp.com/uptoken"
	DOMAIN      = "7xkp7e.com1.z0.glb.clouddn.com"
)

type Uptoken struct {
	Value string `json:"uptoken"`
}

func usage() {
	fmt.Printf(`
Upload file to qiniu Server.

Usage:
	%s [-k key] filename

Options：
	-k  The filename used to save file on qiniu server.
	`, os.Args[0])
}

func main() {
	var key string
	flag.StringVar(&key, "key", "", "The key of upload file")
	flag.Parse()
	filename := flag.Arg(0)
	if filename == "" {
		usage()
		return
	}
	fileAbsPath, _ := filepath.Abs(filename)
	if _, err := os.Stat(fileAbsPath); os.IsNotExist(err) {
		fmt.Println("No such file to upload: ", filename)
		return
	}
	if key == "" {
		key = filepath.Base(fileAbsPath)
	}
	fmt.Println("Upload file with key: ", key)

	resp, err := http.Get(UPTOKEN_URL + "?key=" + key)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println(err)
		return
	}
	var uptoken Uptoken
	json.Unmarshal(body, &uptoken)

	zone := 0
	uploader := kodocli.NewUploader(zone, nil)
	ctx := context.Background()
	err = uploader.PutFile(ctx, nil, uptoken.Value, key, fileAbsPath, nil)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println("Upload file success, You can download it from:")
	fmt.Println(kodocli.MakeBaseUrl(DOMAIN, key))
}
