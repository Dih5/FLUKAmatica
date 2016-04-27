(* ::Package:: *)

Get["https://raw.githubusercontent.com/jkuczm/MathematicaBootstrapInstaller/v0.1.1/BootstrapInstaller.m"]


BootstrapInstall[
	"SyntaxAnnotations",
	"https://github.com/dih5/FLUKAmatica/releases/download/v0.1.0/FLUKAmatica.zip",
	"AdditionalFailureMessage" ->
		Sequence[
			"You can ",
			Hyperlink[
				"install the FLUKAmatica package manually",
				"https://github.com/dih5/FLUKAmatica#manual-installation"
			],
			"."
		]
]