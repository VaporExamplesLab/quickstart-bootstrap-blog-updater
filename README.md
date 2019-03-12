# [quickstart-bootstrap-blog-updater][t]
[t]:https://github.com/VaporExamplesLab/quickstart-bootstrap-blog-updater

<p align="center">
    <a href="http://docs.vapor.codes/3.0/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.2-brightgreen.svg" alt="Swift 4.2">
    </a>
</p>

<a id="toc"></a>
[Getting Started](#GettingStarted) •
[Original Setup](#OriginalSetup) •
[Resources](#Resources) 

## Getting Started <a id="GettingStarted">[▴](#toc)</a>

**Prerequisites**

* [Install Xcode 10 ⇗](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)
* [Install homebrew ⇗](https://brew.sh/)
* [Install vapor toolbox ⇗](https://docs.vapor.codes/3.0/install/macos/)

**Download|Clone & Run**

Steps to download repository:

``` bash
## go to your working directory
cd <your-choosen-directory-path>

## download and unzip
wget https://github.com/VaporExamplesLab/quickstart-bootstrap-blog-updater/archive/master.zip
unzip master.zip -d quickstart-bootstrap-blog-updater
rm master.zip     # remove download

cd quickstart-bootstrap-blog-updater-master

# update dependencies 
# with `-y` yes to generate and open Xcode project
vapor update -y
```

Or, alternate steps to clone repository instead of download:

``` bash
## go to your working directory
cd <your-choosen-directory-path>

## either clone
##    add --bare option for an unattached instance
git clone git@github.com:VaporExamplesLab/quickstart-bootstrap-blog-updater.git 

cd quickstart-bootstrap-blog-updater

# update dependencies 
# with `-y` yes to generate and open Xcode project
vapor update -y
```

Set Xcode scheme to "Run > My Mac".

![](README_files/XcodeScheme.png)

Click the run button and check the results in a browser at `http://localhost:8080`.

![TBD:LandingPage](README_files/LandingPage.png)

## Original Setup <a id="OriginalSetup">[▴](#toc)</a>

The following steps were completed to create the `quickstart-bootstrap-blog-updater` example. 


``` bash
mkdir quickstart-bootstrap-blog-updater
cd quickstart-bootstrap-blog-updater
swift package init --type executable
swift package generate-xcodeproj
open quickstart-bootstrap-blog-updater.xcodeproj/
```

Setting "upload" creation dates 

``` bash
touch -t  201811220800 2018/11/FirstPost.md 
touch -mt 201811220900 2018/11/FirstPost.md 
```


## Resources <a id="Resources">[▴](#toc)</a>

* [Bootstrap ⇗](https://getbootstrap.com)


