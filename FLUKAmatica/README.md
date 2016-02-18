# FLUKAmatica

[![release v1.0.0](http://img.shields.io/badge/release-v0.1.0-red.svg)](https://github.com/dih5/FLUKAmatica/releases/latest)
[![license MIT](https://img.shields.io/badge/license-MIT%20License-blue.svg)](https://github.com/dih5/FLUKAmatica/blob/master/LICENSE.txt)


A package to import FLUKA-generated files in Mathematica. 

* [Features](#features)
* [Usage example](#usage-example)
* [Installation](#installation)
    * [Automatic installation](#automatic-installation)
    * [Manual installation](#manual-installation)
    * [No installation](#no-installation)
* [Documentation](#documentation)
* [License](#license)
* [Versioning](#versioning)

## Features
Support for USRTRACK and singly-differential USRBDX detectors.
Partial support for doubly-differential USRBDX detectors.

## Usage example

Check the [demo notebook](https://github.com/dih5/FLUKAmatica/blob/master/demo.nb).

## Installation


### Automatic installation

To install the FLUKAmatica package evaluate:
```Mathematica
Get["https://raw.githubusercontent.com/dih5/FLUKAmatica/master/BootstrapInstall.m"]
```

This method uses [MathematicaBootstrapInstaller](https://github.com/jkuczm/MathematicaBootstrapInstaller) and will also install the
[ProjectInstaller](https://github.com/lshifr/ProjectInstaller) package if you don't have it already installed.

To load the FLUKAmatica package evaluate: ``Needs["FLUKAmatica`"]``.


### Manual installation

1. Download latest released
   [FLUKAmatica.zip](https://github.com/dih5/FLUKAmatica/releases/download/v0.1.0/FLUKAmatica.zip)
   file.

2. Extract downloaded `FLUKAmatica.zip` to any directory which is on the Mathematica `$Path`,
   e.g. to install for the current user `FileNameJoin[{$UserBaseDirectory,"Applications"}]`,
   for all users `FileNameJoin[{$BaseDirectory,"Applications"}]`.

3. To load the package evaluate: ``Needs["FLUKAmatica`"]``.


### No installation

To use package directly from the Web, without installation, evaluate:
```Mathematica
Get["https://raw.githubusercontent.com/dih5/FLUKAmatica/master/FLUKAmatica/FLUKAmatica.m"]
```


## Documentation

This application does not include Mathematica Documentation Center compatible documentation yet.

Some help is available by means of usage message. Try for example
```Mathematica
?ImportSingleBDX
```Mathematica





## License

This package is released under
[The MIT License](https://github.com/dih5/FLUKAmatica/master/LICENSE).



## Versioning

Releases of this package will be numbered using
[Semantic Versioning guidelines](http://semver.org/).

Note the API is not stable in initial development releases(0.y.z).
Expect it to change indeed.
